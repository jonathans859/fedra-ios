# Fedra for iOS (working name)

A VoiceOver-first Mastodon client for iPhone and iPad. It reuses the Rust core of
[Fedra](https://github.com/trypsynth/fedra), an accessible Mastodon client for Windows by
Quin Gillespie and Aryan Choudhary, and puts a native SwiftUI interface on top.

This is an independent project. It's not affiliated with or endorsed by the Fedra authors.

## Status

Early development. Tasks and milestones live in
[GitHub Issues](https://github.com/jonathans859/fedra-ios/issues). The roadmap is in
[PLAN.md](PLAN.md).

## Layout

| Path | What it is |
|---|---|
| `upstream/` | Submodule: [jonathans859/fedra](https://github.com/jonathans859/fedra), branch `ios-core` (a fork of upstream with a UI-free `fedra-core` crate) |
| `rust/fedra-ffi/` | UniFFI bridge from the core to Swift (from M2) |
| `FedraKit/` | Swift package. `FedraModel` is platform-neutral and tested on Linux and Windows |
| `App/` | The SwiftUI app. `project.yml` generates the Xcode project with XcodeGen |

## Building

```sh
git clone --recurse-submodules https://github.com/jonathans859/fedra-ios
cd FedraKit && swift test      # works on macOS, Linux and Windows
xcodegen generate              # macOS only, then open Fedra.xcodeproj
```

## License

MIT, see [LICENSE](LICENSE). Includes code from Fedra, (c) 2026 Quin Gillespie and Aryan
Choudhary, under the MIT License.
