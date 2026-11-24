# Fedra for iOS (working name)

A VoiceOver-first Mastodon client for iPhone and iPad, written in Swift. It's inspired by
[Fedra](https://github.com/trypsynth/fedra), an accessible Mastodon client for Windows by
Quin Gillespie and Aryan Choudhary. It follows Fedra's design (post templates, sound
cues, keyboard-first use) and stays compatible with its template syntax.

This is an independent project. It's not affiliated with or endorsed by the Fedra authors.

## Status

Early development. Tasks and milestones live in
[GitHub Issues](https://github.com/jonathans859/fedra-ios/issues). The roadmap is in
[PLAN.md](PLAN.md).

## Layout

| Path | What it is |
|---|---|
| `FedraKit/` | Swift package, platform-neutral. `FedraAPI` is the Mastodon client, `FedraModel` holds text, templates and view models. Tested on Linux and Windows |
| `App/` | The SwiftUI app. `project.yml` generates the Xcode project with XcodeGen |

## Building

```sh
git clone https://github.com/jonathans859/fedra-ios
cd FedraKit && swift test      # works on macOS, Linux and Windows
xcodegen generate              # macOS only, then open Fedra.xcodeproj
```

## License

MIT, see [LICENSE](LICENSE). Default templates and text-formatting rules are adapted from
Fedra, (c) 2026 Quin Gillespie and Aryan Choudhary, under the MIT License.
