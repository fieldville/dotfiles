Apple platform development (macOS / iOS / iPadOS)
=================================================

```
$ ~/.dotfiles/.apple/setup.bash
```

Installs what a fresh Mac lacks, skipping what is already there, then builds the sample:

| step                         | how                                                    |
|------------------------------|--------------------------------------------------------|
| `mas`, `xcodegen`            | Homebrew                                               |
| Xcode                        | `sudo mas get 497799835`; falls back to App Store.app  |
| active developer directory   | `sudo xcode-select -s /Applications/Xcode.app/...`     |
| licence, first-launch pkgs   | `sudo xcodebuild -license accept` / `-runFirstLaunch`  |
| iOS SDK + simulator runtime  | `xcodebuild -downloadPlatform iOS` (iPad uses it too)  |

`HelloApple/` is a minimal multiplatform SwiftUI app (one target for all three OSes). The
`.xcodeproj` is generated from `project.yml` by XcodeGen and is not committed.

```
$ cd ~/.dotfiles/.apple/HelloApple
$ ./build.bash              # build for macOS, an iPhone simulator and an iPad simulator
$ ./build.bash ipados       # one of: macos | ios | ipados
$ ./build.bash open         # generate the project and open it in Xcode
```

Running on a real iPhone / iPad needs a development team: set it in Xcode under
Signing & Capabilities (a free Apple Account works), or add `DEVELOPMENT_TEAM` to
`project.yml`.
