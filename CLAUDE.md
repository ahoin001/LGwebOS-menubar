# LGwebOS-menubar: setup guide for Claude

This is a native macOS menu bar app that controls an LG TV running webOS. When a user asks you to set it up, follow these steps in order. Ask the user for anything you cannot find yourself. Do not guess an IP address, MAC address, or TV model.

## 1. Check the Mac

- Confirm macOS 14 or later: `sw_vers -productVersion`.
- Confirm Swift 5.9 or later: `swift --version`. If Swift is missing, tell the user to run `xcode-select --install`.

## 2. Build the app

```sh
bash scripts/build.sh
```

The output is `dist/LGwebOS-menubar.app`. Do not commit the `dist/` folder.

To run in Xcode, open `LGwebOS.xcworkspace`, select the **LGwebOS-menubar** scheme, and leave the destination on My Mac. That scheme is macOS-only. The **LGwebOS** scheme in the same workspace is the iPhone and iPad app.

## 3. Collect the TV details

Ask the user for these:

1. **Model number.** It is on the TV's info screen and on the label on the back.
2. **IPv4 address.** The app can discover the TV, or the user can read it from their router's device list. It looks like `192.168.x.x`. Hostnames and IPv6 are not supported.
3. **MAC address** (only needed for Wake-on-LAN).

## 4. Check compatibility

- The only tested model is **LG 50UN7310PSC** (see the README's "Tested models" table). Any other model is unverified.
- If the user's TV is a different model, say so before continuing. Ask whether they want to try anyway. If they do, report the result and suggest an issue with the model number and exact webOS version.

## 5. Check the TV is reachable

From the Mac:

```sh
ping -c 3 TV_IP
```

If there is no reply, check that the TV and Mac are on the same network. Some guest networks and networks with device isolation block discovery. The user can still enter the IP manually in the app.

## 6. Run the offline checks

```sh
"dist/LGwebOS-menubar.app/Contents/MacOS/LGwebOSMenubar" --self-check
python3 scripts/privacy-check.py
```

Both should pass before you go further.

## 7. Connect and pair

Open the app: `open "dist/LGwebOS-menubar.app"`. Then the user does this in the app:

1. Open Settings.
2. Choose **Find TVs on your network**, or enter the IPv4 address.
3. Optionally enter a display name and the MAC address.
4. Choose **Save and connect**, approve the certificate prompt, then accept pairing on the TV.

A request appears on the TV, and the user must accept it on the TV itself. You cannot do that step for them.

## Rules while setting up

- Never write the user's IP address, MAC address, serial number, or pairing key into a tracked file. Keep them in the app's settings or in `.local/`, which is ignored by git.
- Never commit or push without the user's explicit approval.
- Do not change the webOS compatibility notes in the README unless the user has tested a new version and asks you to.
- If something fails, report the exact error and what you ruled out. Do not retry the same pairing request repeatedly, because the TV may lock out repeated attempts.
