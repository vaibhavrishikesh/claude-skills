# claude-skills

A personal collection of [Claude Code](https://claude.com/claude-code) **skills** —
reusable playbooks that teach Claude how to do a whole workflow end-to-end, so the
hard-won lessons don't have to be re-learned every time.

Each skill is a folder with a `SKILL.md` (what it does + when to trigger) and
optional `references/` files that Claude loads on demand.

## Skills

| Skill | What it does |
|-------|--------------|
| [`ship-ios-app`](ship-ios-app/) | Build and ship a brand-new iOS app entirely from the CLI (XcodeGen + xcodebuild, no Xcode GUI for coding) — brand/identity → project setup → device builds → AdMob → App Store Connect → submission → surviving App Review rejections (Guideline 2.1, the App Tracking Transparency prompt-timing bug, and every other trap that cost hours the first time). |
| [`make-ad-video`](make-ad-video/) | Make a polished app promo / ad / launch video for **free**, locally, with HeyGen's open-source **HyperFrames** (HTML + GSAP → MP4) — no paid AI-video credits. Encodes the vertical-9:16 app-ad recipe (screenshots/posters + animated captions + CTA), a ready composition template, the design vocabulary, and the hard-won gotchas (the GSAP centering bug, `class="clip"`, timeline keys). |

## Install

Skills live in `~/.claude/skills/`. To install a skill from this repo, symlink its
folder there (a symlink means editing the repo updates the live skill):

```bash
./install.sh          # symlinks every skill folder in this repo into ~/.claude/skills
```

Or do one by hand:

```bash
ln -s "$PWD/ship-ios-app" ~/.claude/skills/ship-ios-app
```

Then start (or restart) Claude Code — the skill shows up in the available-skills
list and triggers automatically when a request matches its description.

## How a skill triggers

Claude reads each skill's `description` and pulls the skill in when a request
matches — you don't call it by name. For example, saying *"let's build a new
iPhone app"* or *"my app got rejected on the App Store"* pulls in `ship-ios-app`.

## Adding or editing a skill

- Edit the files in this repo directly — the symlink means the live skill updates
  too. Keep `SKILL.md` under ~500 lines; push detail into `references/`.
- When you learn a new gotcha, add it to the relevant reference file so the next
  run benefits. That's the whole point: the repo gets smarter over time.

## Notes

- No secrets live here. Apple Team IDs, device UDIDs, and AdMob App/ad-unit IDs
  are not credentials — real API keys and passwords never go in a skill.
