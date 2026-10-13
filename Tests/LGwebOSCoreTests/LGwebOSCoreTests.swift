import XCTest
import LGwebOSCore

final class LGwebOSCoreTests: XCTestCase {
    func testOfflineSuite() async throws {
        try await FeatureChecks.run()
    }

    func testVolumePayloadReadsNestedAndFlatMute() {
        let nested = SSAPPayload.volume(["volumeStatus": ["volume": 12, "muteStatus": true]])
        XCTAssertEqual(nested.volume, 12)
        XCTAssertEqual(nested.muted, true)
        let flat = SSAPPayload.volume(["volume": 4, "muted": false])
        XCTAssertEqual(flat.volume, 4)
        XCTAssertEqual(flat.muted, false)
    }

    func testLaunchPointsAndInputsKeepHDMIDeviceNames() {
        let points = SSAPPayload.launchPoints(["launchPoints": [["id": "netflix", "title": "Netflix"], ["title": "Missing"]]])
        XCTAssertEqual(points, [SSAPPayload.LaunchPoint(id: "netflix", title: "Netflix")])
        let inputs = SSAPPayload.externalInputs(["devices": [[
            "id": "HDMI_2",
            "label": "HDMI 2",
            "connected": true,
            "appId": "com.webos.app.hdmi2",
            "subList": [["osdName": "PlayStation 5"]],
        ]]])
        XCTAssertEqual(inputs.first?.label, "PlayStation 5")
        XCTAssertEqual(inputs.first?.appID, "com.webos.app.hdmi2")
    }

    func testPictureAndPowerPayloads() {
        XCTAssertEqual(SSAPPayload.picture(["settings": ["backlight": 40, "brightness": "15", "ignored": "no"]]), ["backlight": 40, "brightness": 15])
        XCTAssertTrue(SSAPPayload.powerIsActive(["state": "Active"]))
        XCTAssertFalse(SSAPPayload.powerIsActive(["state": "Suspended"]))
        let software = SSAPPayload.software(["major_ver": "5", "minor_ver": "0", "micro_ver": "1", "product_name": "webOS"])
        XCTAssertEqual(software.firmware, "5.0.1")
        XCTAssertEqual(software.product, "webOS")
    }

    func testKnownBrandsKeepStableColors() {
        let netflix = BrandIdentity.forApp("netflix", title: "Netflix")
        XCTAssertTrue(netflix.usesKnownColor)
        XCTAssertEqual(netflix.label, "Netflix")
        let other = BrandIdentity.forApp("com.example.player", title: "Player")
        XCTAssertFalse(other.usesKnownColor)
        XCTAssertEqual(other.tagline, "Your LG. Your room. Your remote.")
    }
}
