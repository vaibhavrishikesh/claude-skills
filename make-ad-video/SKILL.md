---
name: make-ad-video
description: >-
  Make a polished promo / ad / launch video for an app or product — for FREE,
  locally, with no paid AI-video credits — using HeyGen's open-source
  HyperFrames (write HTML + GSAP, render to MP4). Use this whenever the user
  wants an ad video, promo, app-store preview, reel, launch/teaser video, or
  "banao ek ad/video" for an app like Soon or SharePoster. It encodes the
  working recipe (vertical 9:16 app-ad from screenshots/posters + animated text
  + CTA) and the hard-won gotchas (the GSAP centering bug, class=clip, timeline
  keys) so the video comes out clean in one pass. Reach for it before trying
  paid tools like Runway or Higgsfield — those need a subscription; HyperFrames
  is free and better for authored ads.
---

# Make an ad / promo video (free, with HyperFrames)

**The core lesson:** paid AI-video tools (Runway, Higgsfield) need a paid
subscription — their "free credits" are web-app credits that DON'T work via the
API, and the good web models are gated behind a plan. For an **authored app ad**
(screenshots/posters + animated text + CTA) you don't need any of that.
**HyperFrames** (open-source, Apache-2.0, HeyGen) turns HTML + GSAP into a
deterministic MP4 — 100% free and local, and it's *built for coding agents*.

## When to use
Any "make me an ad / promo / launch / teaser / reel / app-preview video" for an
app or product. Especially app ads that showcase screenshots or posters with
animated captions and a call-to-action.

## Setup (one-time)
```bash
# needs Node >= 22 and ffmpeg (brew install ffmpeg)
npx skills add heygen-com/hyperframes --full-depth --all --yes   # installs 20 hyperframes skills
```
This registers the official `/hyperframes` router + domain skills (core,
animation, creative, cli, media-use, …). **Read `/hyperframes` first** for any
real build — it routes to the right workflow (`/product-launch-video` for a
polished promo, `/general-video`, `/motion-graphics`, etc.). This skill is the
*distilled recipe + gotchas* that complement those.

## The fast recipe — a vertical app ad (what actually works)
```bash
npx hyperframes init videos/<app>-ad --non-interactive --example=blank
# put screenshots/posters in videos/<app>-ad/media/
# author index.html (see references/app-ad-composition.html)
cd videos/<app>-ad && npm run check   # lint+validate+inspect — fix errors
npm run render                        # -> renders/<name>.mp4 (~30s)
```
- **Canvas:** 1080×1920 (9:16, reels/stories/ads). Set `data-width/height`,
  `<meta viewport width=1080 height=1920>`, and body `1080×1920`.
- **Structure:** 3–4 screenshot scenes + a **CTA end-card**. Each scene is a
  `class="clip"` div with `data-start`, `data-duration`, `data-track-index`.
  Overlap adjacent scenes by ~0.5s (alternate `data-track-index` 0/1) and
  cross-fade with opacity for a smooth transition.
- **Look:** dark radial-gradient bg, rounded screenshot with a soft drop-shadow,
  a bold headline (top) per scene, a subtle brand footer, and a final CTA card
  (app name big + one-line value + "Free on the App Store / Google Play").
- A full working starter is in **`references/app-ad-composition.html`** — copy
  it, swap media + copy, render.

## Make it actually GOOD — the flow that lands (not just crossfades)
A flat cut of images + fades reads "meh." This structure reads like a real ad:
1. **Intro hook (~2.5s)** — a title card BEFORE the content: a scaling emblem
   (logo / ॐ / icon) with a soft radial **glow**, the one-line hook, and a date/CTA
   sub. Give the reel a reason to keep watching.
2. **Showcase scenes** — give each a **different ken-burns** move (one zoom-in, one
   pan-up, one pan-down) so it never feels static, plus a **cinematic vignette**
   overlay — `radial-gradient(120% 90% at 50% 45%, transparent 55%, rgba(4,2,10,.72) 100%)` — for depth.
3. **Vary the transitions** — don't fade every time. A **zoom-through** into the
   finale (outgoing scene scales up + fades while the next reveals) is a punchy
   hand-off; push-slide and blur-crossfade are others (see the animation skill's
   `transitions/catalog.md`).
4. **Dynamic CTA card** — the emblem does a slow **pulse** loop; text **staggers** in
   (small → title → sub → free → button → handle); the button pops with `back.out`.
   Center the button with a fixed `left` (not `translateX`) so GSAP scale can't shift it.
- **Poster / carousel ad** (images that already carry their own text — festival
  posters, quote cards): don't add text over them — show each on a **blurred-fill
  background of itself** (`.pbg` = same image, `filter: blur(42px) brightness(.45)`,
  `transform: scale(1.2)`) with the sharp image centered on top. Full working
  example: **`references/carousel-ad-composition.html`**.
- For richer motion, read the local **`hyperframes-animation`** skill:
  `transitions/catalog.md`, `blueprints/` (titlecard-reveal, cta-morph-press,
  kinetic-type-beats), `examples/*.html` (runnable ground truth).

## GOTCHAS — the ones that cost time (memorize)
1. **The centering bug (screenshots shift right / get cut).** GSAP animating
   `scale` OVERRIDES a CSS `transform: translate(-50%,-50%)`, so a centered image
   jumps off-center. **Fix:** never mix them — do the centering *inside GSAP* with
   `xPercent:-50, yPercent:-50` in BOTH the `from` and `to` of the scale tween;
   keep only `left:50%; top:50%` in CSS (no `transform`).
   ```js
   tl.fromTo(sel+" .shot", {scale:1, xPercent:-50, yPercent:-50},
                           {scale:1.07, xPercent:-50, yPercent:-50, duration:d, ease:"none"}, tIn);
   ```
2. **`class="clip"` is mandatory** on every timed element — without it the element
   is always visible and ignores `data-start`/`data-duration`.
3. **Timeline key must equal `data-composition-id`** — register the paused GSAP
   timeline on `window.__timelines["main"]` (key must match exactly, or nothing animates).
4. **Only animate visual props** (opacity, transform, color). Never call
   `video.play()/pause()` or set `audio.currentTime` — the framework owns media
   playback via `data-start`/`data-media-start`/`data-volume`.
5. **Composition length = the GSAP timeline length**, not the media length. If it
   cuts early, extend with `tl.set({}, {}, DURATION)`. Root `data-duration` is
   read at compile time — set it in HTML, don't change it from script.
6. **Image size:** resize sources to ~2× the canvas; a giant JPEG decodes to
   hundreds of MB and slows render.
7. **`content_overlap` warnings during the ~0.5s crossfade are expected** (two
   scenes share a zone while one fades out) — not errors; render is fine. Silence
   with `data-layout-allow-overlap` if desired.
8. **Fonts (esp. Devanagari / non-Latin):** the compiler only auto-embeds fonts in
   its resolved list; any other `font-family` (e.g. "Kohinoor Devanagari", "Noto
   Sans Devanagari", "Mukta") lints as an **error** (`font_family_without_font_face`).
   **Fix:** declare it yourself with a system-local source, then use that family:
   ```css
   @font-face { font-family:"DevaHF";
     src: local("Kohinoor Devanagari"), local("Devanagari Sangam MN"), local("Noto Sans Devanagari");
     font-weight: 100 900; }
   /* body { font-family:"DevaHF", -apple-system, Arial, sans-serif; } */
   ```
   The `local()` declaration alone satisfies the lint and renders the real system
   font (Devanagari renders perfectly this way). A bare Google-Fonts `<link>` may
   not load in the headless render.
9. **Don't overlap two GSAP tweens on the same property of the same element** — the
   linter flags `overlapping_gsap_tweens`. Sequence them: let the entrance tween
   finish, then start a separate pulse/loop a beat later.
10. **Always `npm run check` after edits** and fix errors before rendering.

## Design vocabulary (for polish)
- **Timing:** fast 0.2s = energy · medium 0.4s = professional · slow 0.6s = luxury.
- **Caption tone:** Hype (heavy weight, scale-pop, 72–96px) · Corporate (clean sans,
  fade+slide, 56–72px) · Tutorial (monospace, typewriter).
- **Transitions:** calm = blur crossfade · medium = push slide · high = zoom-through.
- Every scene needs an **entrance animation**; always add **transitions between scenes**.

## Pro workflow (when you want it really good)
Mirror the official `/product-launch-video`: 1) gather assets + `frame.md`
(palette/typography/design spec) → 2) `STORYBOARD.md` (scene beats + timing) →
3) borrow animation patterns from the launch-video examples → 4) render + review
static frames → 5) build the full multi-composition + polish. Multi-composition
(4–8 scenes wired into one root timeline) beats one monolithic file.

## Audio (optional)
- **Music:** local `MusicGen` or add trending audio when posting the reel (simplest,
  best reach). Music-engine deps are heavy (torch) — usually skip and add on IG.
- **Voiceover:** `/media-use` → free local **Kokoro** TTS (no key) or paid
  **ElevenLabs**; both give word-level timestamps for caption sync.

## Known assets on this machine
- **Soon** (iOS) App Store screenshots: `~/Desktop/soon-appstore-screens/` (1242×2688).
- **SharePoster** Sawan posters: `~/Desktop/insta-post/sawan_carousel/` (1408×1760).
- Finished ads land in `~/Desktop/insta-post/` (e.g. `soon_ad_hyperframes.mp4`).
- The scratch project lives at `~/Desktop/app-ads/`. See [[ship-ios-app]] for the apps.
