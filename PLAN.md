# Plan / Roadmap

The individual tasks are GitHub Issues, grouped into milestones M0–M10:
https://github.com/jonathans859/fedra-ios/milestones. This file holds the roadmap,
the decisions and the background. The checkboxes below are the source the issues
were created from; GitHub is authoritative.

Status: **M0 in progress.** Upstream analysed at `trypsynth/fedra@172615b` (v0.9.1, 2026-11-22).

## Decisions made (2026-11-24)

| Topic | Decision |
|---|---|
| Core source | Fork upstream, extract a UI-free `fedra-core` crate in the fork, use it as a git submodule, rebase on upstream regularly |
| Relationship | Own independent app built on MIT code. Upstream not contacted |
| App name | Decide later. Use a working name until then |
| Build | Windows only + GitHub Actions macOS runners, testing on device via TestFlight |
| Platforms | iPhone + iPad, iOS 18+ |
| First version | A tiny read-only app that proves the Rust↔Swift bridge end to end |
| Fedra features | Keep post templates, sound cues and keyboard/quick-action keys, **and** offer iOS-native patterns (rotor, custom actions, haptics) |
| Push | Wanted. User hosts the relay container (M8) |
| Language | English only |
| Bundle ID | `com.jonathan859.fedra` |
| GitHub | `jonathans859/fedra-ios`, fork `jonathans859/fedra` (branch `ios-core`) |
| Tasks | GitHub Issues + Milestones |
| Indentation | Tabs (matches upstream) |

## What upstream gives us and what has to change

Upstream is **one binary crate**. No library exists yet. UI coupling found outside `src/ui/`:

| Module | Coupling | Change in the fork |
|---|---|---|
| `mastodon/*`, `html.rs`, `template.rs`, `text.rs`, `timeline.rs`, `clock.rs`, `read_position.rs` | none / little | move as-is |
| `network.rs` | `wx_utils::tasks` background queue | expose plain blocking fns; the scheduling stays in the UI layer |
| `auth.rs` | `wxdragon` browser launch + localhost listener | keep `register_app` / `build_authorize_url` / `exchange_token`. iOS uses `ASWebAuthenticationSession` + a custom URL scheme |
| `responses/*` | `live_region.announce(...)` | return outcome values/events; the UI decides what to announce |
| `accounts.rs`, `notifications.rs`, `audio.rs`, `speech/*` | wx / rodio / OS | stay in the Windows app, not in the core |
| `config.rs` (1.6k lines) | mixes data with Windows hotkeys | split: data types → core, shortcut/UI config stays |
| `streaming.rs` | tungstenite | move to the core; check that it works on iOS (TLS roots) |

## Milestones

### M0 – Repository skeleton
- [x] Fork `trypsynth/fedra` → `jonathans859/fedra`, branch `ios-core`
- [x] Add the fork as submodule `upstream/`
- [x] README with credit + LICENSE (MIT, keep upstream copyright alongside ours)
- [x] `.gitignore`, `.gitattributes`, `.editorconfig`
- [x] `FedraKit` Swift package skeleton (`FedraModel`), `swift test` green on Windows
- [x] `project.yml` (XcodeGen) with a placeholder SwiftUI app, bundle ID
- [ ] CI green: Linux `swift test` + macOS unsigned simulator build
- [ ] App Store Connect app record + TestFlight via apple-ci (needs you: create the app in App Store Connect)

### M1 – Extract `fedra-core` (in the fork)
- [ ] Workspace member `core/` (`fedra-core`), move the UI-free modules over
- [ ] Remove `wx_utils` from `network.rs`, `wxdragon` from `auth.rs`, `live_region` from `responses/*`
- [ ] Split `config.rs` into core data and Windows shortcuts
- [ ] Windows app builds and behaves the same (`cargo clippy -D warnings`, `cargo test`)
- [ ] Write down the rebase procedure in `upstream/IOS_CORE.md`

### M2 – Bridge (FFI + XCFramework)  ⚠ original research, no skill exists yet
- [ ] `rust/fedra-ffi` with UniFFI (proc macros), async API, error enum
- [ ] TLS on iOS: `rustls-native-certs` can't read the iOS trust store. Evaluate `rustls-platform-verifier` vs `webpki-roots`
- [ ] Build targets `aarch64-apple-ios`, `aarch64-apple-ios-sim`, `x86_64-apple-ios-sim` → XCFramework
- [ ] How CI builds Rust before Xcode (apple-ci has no pre-build hook). Options: (a) an Xcode run-script build phase calls cargo, (b) a self-contained workflow that copies apple-ci's steps, (c) prebuilt XCFramework as a release asset
- [ ] Binary size check (upstream uses opt-level "z", LTO)
- [ ] Afterwards: create the skill `rust-uniffi-ios` and commit it

### M3 – Read-only MVP (first TestFlight build)
- [ ] Sign-in: instance field → OAuth via `ASWebAuthenticationSession` → token in Keychain
- [ ] Home timeline: a list where each post is one VoiceOver element, label from the default post template
- [ ] Load more at the end, pull to refresh, keep the reading position (upstream `read_position`)
- [ ] Post detail: full text, links, media descriptions, content warning
- [ ] Error and empty states that make sense when spoken
- [ ] VoiceOver walkthrough on device, Accessibility Inspector audit in CI

### M4 – Reading in full
- [ ] Multiple accounts + account switcher
- [ ] Timelines: notifications, mentions, local, federated, bookmarks, favourites, user, hashtag, list
- [ ] Threads (context), profiles, boosts/favourites lists
- [ ] Rotor: switch timelines, jump to links/mentions in a post

### M5 – Interacting
- [ ] Compose / reply / quote, visibility, CW, language
- [ ] Boost, favourite, bookmark, follow/mute/block as custom actions
- [ ] Media upload with alt text (required prompt, as an option)
- [ ] Mention/hashtag suggestions in the composer, VoiceOver-friendly

### M6 – Fedra features
- [ ] Template editor (post/boost/quote/favourite) with preview, read by VoiceOver
- [ ] Sound cues (upstream `sounds/`), each toggleable, mixing with VoiceOver via the audio session
- [ ] Hardware keyboard shortcuts + quick-action keys, customisable
- [ ] Haptics as an alternative to sounds

### M7 – Live updates
- [ ] Streaming while the app is in the foreground. New posts must not steal focus
- [ ] Background App Refresh for unread counts

### M8 – Push notifications (relay)  ⚠ original research
- [ ] Choose the relay (see the notes), deploy it, configure the APNs key
- [ ] Notification Service Extension: decrypt Web Push on the device, keys in the shared Keychain
- [ ] Actionable notifications (reply, favourite)
- [ ] Afterwards: create the skill `mastodon-push-relay`

### M9 – Feature parity extras
- [ ] Lists, filters (server + local), search, polls, scheduled posts, profile editing, follow management, message requests, user aliases

### M10 – App Store
- [ ] Final name + icon, privacy manifest, App Privacy, screenshots, review notes (test account on an instance)


## Notes: how push works
Mastodon can't talk to APNs. It only speaks **Web Push**:
1. The app asks the instance for a push subscription (`POST /api/v1/push/subscription`) and passes the relay's URL plus a public key and auth secret generated on the device.
2. On every event the instance sends an **encrypted** Web Push message to that URL.
3. The relay passes the still-encrypted message to APNs, using your APNs key (.p8) from the Apple Developer account.
4. On the iPhone a Notification Service Extension decrypts it with the private key from the Keychain and shows the notification.

So the relay is small and **stateless** (no database, no user data, and it can't read posts). In practice it's one Docker container behind HTTPS (for example Caddy/Traefik with a domain). Mastodon's own iOS app uses a relay like this; it's open source (to verify in M8: `mastodon/webpush-apn-relay`, Go). Running costs: a small VPS or an existing server, a domain, and the APNs key.
