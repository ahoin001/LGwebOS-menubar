import Foundation
import Security
import CryptoKit

/// LG TVs usually have a private certificate. Explicit first-time approval pins
/// the leaf for this host; an existing pin must always match, including input sockets.
final class TVCertificateTrust: NSObject, URLSessionWebSocketDelegate, @unchecked Sendable {
    let host: String
    private let lock = NSLock()
    private var fingerprint: String?
    private var approval: (@Sendable (String, String) async -> Bool)?
    private var trustError: Error?
    private var opening: [Int: CheckedContinuation<Void, Error>] = [:]

    init(host: String) { self.host = host }

    func configure(fingerprint: String?, approval: (@Sendable (String, String) async -> Bool)?) {
        lock.lock()
        self.fingerprint = fingerprint
        self.approval = approval
        trustError = nil
        lock.unlock()
    }

    func approvedFingerprint() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return fingerprint
    }

    private func reject(_ message: String, _ completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        lock.lock()
        trustError = RemoteError.message(message)
        lock.unlock()
        completion(.cancelAuthenticationChallenge, nil)
    }

    private func approve(_ digest: String) {
        lock.lock()
        fingerprint = digest
        lock.unlock()
    }

    func open(_ task: URLSessionWebSocketTask) async throws {
        try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            opening[task.taskIdentifier] = continuation
            lock.unlock()
            task.resume()
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        lock.lock()
        let continuation = opening.removeValue(forKey: webSocketTask.taskIdentifier)
        lock.unlock()
        continuation?.resume()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        lock.lock()
        let continuation = opening.removeValue(forKey: task.taskIdentifier)
        let failure = trustError
        lock.unlock()
        continuation?.resume(throwing: failure ?? error ?? RemoteError.message("The TV connection closed before it opened."))
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        guard challenge.protectionSpace.host == host, challenge.protectionSpace.port == 3001,
              let trust = challenge.protectionSpace.serverTrust,
              let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let leaf = certificates.first else {
            reject("The TV did not provide a certificate for the selected local address.", completionHandler)
            return
        }
        let digest = SHA256.hash(data: SecCertificateCopyData(leaf) as Data).map { String(format: "%02x", $0) }.joined()
        lock.lock()
        let expected = fingerprint
        let requestApproval = approval
        lock.unlock()
        switch TVCertificatePolicy.decide(expected: expected, received: digest, canApprove: requestApproval != nil) {
        case .matched:
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        case .rejected:
            reject(expected == nil
                ? "This TV has no trusted certificate yet. Click Connect to confirm first-time pairing."
                : "The TV certificate has changed. Verify the device and pair it again in Settings.", completionHandler)
            return
        case .approvalRequired:
            break
        }
        guard let requestApproval else {
            reject("This TV has no trusted certificate yet. Click Connect to confirm first-time pairing.", completionHandler)
            return
        }
        Task {
            guard await requestApproval(host, digest) else {
                reject("The TV certificate was not approved.", completionHandler)
                return
            }
            approve(digest)
            completionHandler(.useCredential, URLCredential(trust: trust))
        }
    }
}
