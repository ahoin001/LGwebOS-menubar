# Third-party notices

## LG registration manifest and PyWebOSTV

`Sources/LGwebOSCore/registration.json` contains the public LG test-client registration manifest distributed by [PyWebOSTV](https://github.com/supersaiyanmode/PyWebOSTV). Its signed client metadata, serial field, and signature are protocol constants, not a user's TV serial number or pairing credentials. The signed block includes LG-provided localized names. It is kept intact because translating it would invalidate the signature. All project-authored text is English.

PyWebOSTV is distributed under the [MIT License](https://github.com/supersaiyanmode/PyWebOSTV/blob/master/LICENSE):

```text
MIT License

Copyright (c) 2017 Srivatsan Iyer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Icons and brand assets

The LG, PlayStation, and Google Cast symbol assets were rendered from [Simple Icons](https://simpleicons.org/), whose artwork is distributed under [CC0 1.0](https://github.com/simple-icons/simple-icons/blob/develop/LICENSE.md). CC0 does not grant trademark rights.

Other bundled app icons are third-party branding supplied through the LG app launcher. Their respective owners retain rights to their artwork and trademarks. The project's MIT license does not relicense those assets or imply endorsement by LG, Sony, Google, or other app vendors.

`tv-hero.png` is an AI-generated project illustration. Its embedded content provenance metadata is preserved.

## References and visual inspiration

The public [Connect SDK](https://github.com/ConnectSDK/Connect-SDK-iOS) informed webOS protocol behavior. The native Swift implementation is part of this project; the SDK is not bundled as a dependency.

The menu bar layout was inspired by [vorssaint-utils](https://github.com/vorssaint/vorssaint-utils). The interface in this project is implemented in SwiftUI and AppKit.
