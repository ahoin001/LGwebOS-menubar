#!/usr/bin/env python3
"""Audit public source files without reading preferences, Keychain or the TV.

Use --deny TEXT for any additional personal names or identifiers to exclude.
Use --root DIR to audit a clean export before sharing it. This is a useful
release check, not a guarantee that arbitrary files contain no sensitive data.
"""
import argparse
import ipaddress
from pathlib import Path
import re
import subprocess
import sys

PUBLIC_ROOTS = ("Sources", "Tests", "scripts", "Apps")
PRIVATE_ROOTS = {".git", ".build", ".swiftpm", "dist", "research", "node_modules", "__pycache__"}
LEGACY_FILES = {
    "package.json", "package-lock.json", "scripts/probe.mjs",
    "scripts/inventory.mjs", "scripts/report.py", "scripts/developer-diagnostics.py",
}
PUBLIC_SCRIPTS = {"scripts/build.sh", "scripts/privacy-check.py"}
IPV4 = re.compile(rb"(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?![\d.])")
MAC = re.compile(rb"(?<![a-zA-Z0-9])(?:[0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}(?![a-zA-Z0-9])")
HOME_PATH = re.compile(rb"/(?:Users|home)/[^/\s\"']+|/var/folders/[a-zA-Z0-9_/]+")
CLIENT_KEY = re.compile(rb'''["']client-key["']\s*:\s*["'][^"']+["']''')
# Documentation-only address blocks; loopback and multicast are protocol values.
EXAMPLE_NETWORKS = tuple(ipaddress.ip_network(block) for block in (
    "192.0.2.0/24", "198.51.100.0/24", "203.0.113.0/24", "127.0.0.0/8", "224.0.0.0/4",
))
EXAMPLE_MACS = {b"00:00:00:00:00:00", b"00:11:22:33:44:55", b"ff:ff:ff:ff:ff:ff"}


def files_to_check(root):
    """Prefer Git's complete publication view, including newly added files."""
    git = subprocess.run(
        ["git", "-C", str(root), "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
    )
    if git.returncode == 0:
        return sorted({root / name.decode() for name in git.stdout.split(b"\0") if name})
    # A source export needs no repository initialization to be checked.
    candidates = []
    for file in root.rglob("*"):
        relative = file.relative_to(root)
        if any(part in PRIVATE_ROOTS for part in relative.parts):
            continue
        name = relative.as_posix()
        if name in LEGACY_FILES or (relative.parts[0] == "scripts" and name not in PUBLIC_SCRIPTS):
            continue
        if file.is_file() and (len(relative.parts) == 1 or relative.parts[0] in PUBLIC_ROOTS):
            candidates.append(file)
    return sorted(candidates)


def findings(data, denied):
    found = []
    for match in HOME_PATH.finditer(data):
        found.append((match.start(), "local user or temporary path"))
    for match in CLIENT_KEY.finditer(data):
        found.append((match.start(), "persisted pairing key"))
    for match in IPV4.finditer(data):
        try:
            address = ipaddress.ip_address(match.group().decode())
        except ValueError:
            continue
        if address in (ipaddress.ip_address("0.0.0.0"), ipaddress.ip_address("255.255.255.255")):
            continue
        if any(address in network for network in EXAMPLE_NETWORKS):
            continue
        if address.is_private or address.is_link_local:
            found.append((match.start(), "private network address"))
    for match in MAC.finditer(data):
        if match.group().lower().replace(b"-", b":") not in EXAMPLE_MACS:
            found.append((match.start(), "device MAC address"))
    lower = data.lower()
    for identifier in denied:
        encoded = identifier.encode().lower()
        if encoded and encoded in lower:
            found.append((lower.index(encoded), "explicitly denied identifier"))
    return sorted(set(found))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--deny", action="append", default=[], metavar="TEXT")
    args = parser.parse_args()
    root = args.root.resolve()
    if not root.is_dir():
        parser.error("--root must be a directory")
    checked = 0
    issues = []
    for file in files_to_check(root):
        relative = file.relative_to(root).as_posix()
        if file.is_symlink():
            issues.append(f"{relative}: symlink must be reviewed before publishing")
            continue
        if not file.is_file():
            continue
        data = file.read_bytes()
        checked += 1
        for offset, reason in findings(data, args.deny):
            line = data[:offset].count(b"\n") + 1
            # Never echo the sensitive value itself.
            issues.append(f"{relative}:{line}: {reason}")
    if issues:
        print("Privacy check found items to review:")
        print("\n".join(issues))
        return 1
    print(f"Privacy check passed: {checked} public files inspected.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
