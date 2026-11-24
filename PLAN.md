# Plan / Roadmap

The individual tasks are GitHub Issues, grouped into milestones M0–M10:
https://github.com/jonathans859/fedra-ios/milestones. This file holds the roadmap,
the decisions and the background. The checkboxes below are the source the issues
were created from; GitHub is authoritative.

Status: **M0 done except the name and the App Store Connect record. Next: M1.**

## Decisions made (2026-11-24)

| Topic | Decision |
|---|---|
| Core source | **Our own Swift code.** Fedra (Windows) is design inspiration only. No Rust, no fork (changed 2026-11-24) |
| Relationship | Independent app inspired by Fedra (MIT). Upstream not contacted |
| App name | Open: decide before the App Store Connect record. Working name "Fedra" until then |
| Build | Windows only + GitHub Actions macOS runners, testing on device via TestFlight |
| Platforms | iPhone + iPad, iOS 18+ |
| First version | A tiny read-only app (sign in, read the home timeline) |
| Fedra features | Keep post templates, sound cues and keyboard/quick-action keys, **and** offer iOS-native patterns (rotor, custom actions, haptics) |
| Push | Wanted. User hosts the relay container (M8) |
| Language | English only |
| Bundle ID | `com.jonathan859.fedra` |
| GitHub | `jonathans859/fedra-ios` |
| Templates | Same syntax, variables and defaults as Fedra for Windows, so templates can be copied between the two |
| Tasks | GitHub Issues + Milestones |
| Indentation | Tabs |

## Fedra (Windows) as the reference

We take the **design** from upstream, not the code (decided 2026-11-24, after mapping
the Rust code: it's one binary with the core tangled into the wx UI, and the bridge
would cost two milestones before showing a single post). Things to carry over:

| From upstream | Use |
|---|---|
| `doc/readme.md` (user manual) | feature reference, wording, default shortcuts |
| `src/template.rs` + manual "Templates" | template syntax, variable names, the four default templates |
| `src/html.rs`, `src/text.rs` | rules for turning post HTML into readable text, emoji handling in names |
| `src/mastodon/*` | which endpoints and fields a full client needs |
| `src/config.rs` | settings list (timestamp format, CW display, sort order, filters, ...) |
| `sounds/` | contains only `boop.mp3` with no licence note, so **we make our own sounds** |

Upstream reference commit: `trypsynth/fedra@172615b` (v0.9.1, 2026-11-22).

## Milestones

### M0 – Repository skeleton
- [x] README with credit + LICENSE (MIT, upstream copyright for ported logic)
- [x] `.gitignore`, `.gitattributes`, `.editorconfig`
- [x] `FedraKit` Swift package skeleton (`FedraModel`), `swift test` green on Windows
- [x] `project.yml` (XcodeGen) with a placeholder SwiftUI app, bundle ID
- [x] CI green: Linux `swift test` + macOS unsigned simulator build
- [ ] Choose the public name before the App Store Connect record (the bundle ID can't change afterwards)
- [ ] App Store Connect app record + TestFlight via apple-ci (needs you: create the app in App Store Connect)

### M1 – Swift Mastodon client (FedraAPI)
- [ ] `HTTPTransport` protocol + URLSession implementation (FoundationNetworking on Linux/Windows) + fake transport for tests
- [ ] Codable models: Status, Account, Notification, MediaAttachment, Poll, Mention, Tag, CustomEmoji, Instance
- [ ] Endpoints for M3: verify credentials, home timeline, single status, context; `max_id`/`min_id` pagination via the `Link` header
- [ ] OAuth calls: register app, build authorize URL, exchange code for token (the UI part comes in M3)
- [ ] Typed errors (offline, unauthorised, rate limit, server error) with messages written for speech
- [ ] JSON fixtures from a real instance, tests on Linux + Windows

### M2 – Text and templates (FedraModel)
- [ ] HTML to plain text for VoiceOver (paragraphs, line breaks, links, mentions, hashtags), following upstream's `html.rs` rules. Own small parser or SwiftSoup? Decide before starting
- [ ] Template engine: Fedra-compatible subset (`{{ var }}`, `{% if %}…{% endif %}`). Falls back to `author: content` on a syntax error, like upstream
- [ ] Template variables (author, username, content, relative_time, visibility, counts, media, poll, booster, quote_*, ...) built from a Status
- [ ] Port the four default templates (post, boost, quote, favourite)
- [ ] Settings enums: timestamp format, CW display, emoji in names, sort order

### M3 – Read-only MVP (first TestFlight build)
- [ ] Sign-in: instance field → OAuth via `ASWebAuthenticationSession` → token in Keychain
- [ ] Home timeline: a list where each post is one VoiceOver element, label from the default post template
- [ ] Load more at the end, pull to refresh, keep the reading position (port the idea of upstream `read_position`)
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
- [ ] Our own sound pack (upstream has no licensed sounds), each cue toggleable, mixing with VoiceOver via the audio session
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
