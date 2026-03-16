# Trump Clock

A single-purpose iOS app that monitors whether Donald J. Trump is the current President of the United States. If he leaves office before the end of his term, it sends a notification. That's it.

Icon designed by Robyn Mahon (Kody's wife) -- a clock with Trump's toupee. All code written by Claude Code. Not a single line was written by hand.

## How It Works

The app queries Wikidata's public SPARQL endpoint to check who currently holds the office of head of government of the United States (Q30). It compares the result against Trump's Wikidata entity (Q22686). If he's no longer listed, the app stores the departure date locally and fires a local notification.

Checks happen three ways:
- On app launch and foregrounding
- On tap (manual check)
- Via background app refresh (hourly)

The app has two states. A dark monitoring screen with pulsing green radar lines and a serif message confirming he's still president, and a departure screen that simply states he is no longer president with the date.

## Technical Details

- **Language:** Swift / SwiftUI
- **Target:** iOS 17+, iPhone only
- **Data source:** Wikidata SPARQL API (https://query.wikidata.org/sparql)
- **Notifications:** Local (not push)
- **Background:** BGAppRefreshTaskRequest, hourly
- **Storage:** UserDefaults for departure state
- **Bundle ID:** com.app.trumpwatch
- **Product name:** Trump Clock
- **Privacy:** No tracking, no analytics, no data collection

## Project Structure

```
TrumpWatch/
  TrumpWatchApp.swift        -- App entry point, background task scheduling
  ContentView.swift          -- MonitoringView and DepartureView
  PresidencyMonitor.swift    -- Wikidata queries, state management
  NotificationManager.swift  -- Notification permissions and alert
  PrivacyInfo.xcprivacy      -- Privacy manifest (required since 2024)
  Info.plist                 -- Background fetch config
  Assets.xcassets/           -- App icon (1024x1024) and accent color
docs/
  privacy.html               -- Privacy policy (hosted via GitHub Pages)
  support.html               -- Support page (hosted via GitHub Pages)
  CNAME                      -- Custom domain: trumpclock.kodyabbott.com
```

245 lines of Swift total across 4 files.

## Building and Submitting -- The Hard Part

The code took minutes. Getting it into the App Store took hours. Here's everything that came up during submission.

### Xcode Setup

- **Xcode command line tools** needed configuring (`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`)
- **Recommended settings warning** appeared after renaming the product -- clicked Perform Changes
- **Shared scheme** wasn't committed to the repo, which blocked Xcode Cloud from finding it

### Naming

The original name "TrumpWatch" was taken on the App Store. "Trump Watch" (with a space) was also taken. Landed on **Trump Clock** which fit the icon.

Changing the name required updating the Product Name build setting from `$(TARGET_NAME)` to `Trump Clock`. The Display Name under General > Identity also needed updating separately.

### Git

- Initial commits had the wrong author (voxkura). Fixed retroactively with `git filter-branch` and force pushed.
- The Instruments trace file (trumpwatch-startup.trace) was accidentally committed -- 130MB of binary data. Added `*.trace/` to .gitignore and removed it from tracking.
- Set global git config to the correct name and email.

### GitHub

- Created as a private repo, but GitHub Pages requires a public repo (or a paid plan). Made the repo public since there are no secrets in the code.
- Custom domain `trumpclock.kodyabbott.com` set up via GitHub Pages with a CNAME record.

### Xcode Cloud

- Initial workflow created under the old product name failed with "Workflow does not exist"
- Recreated the workflow but missed adding an Archive action -- got "Workflow must have at least one Required to Pass action"
- Scheme warning persisted in the UI but the build succeeded anyway once the scheme was pushed
- Changed Distribution Preparation from None to App Store Connect so builds upload automatically

### App Store Connect

- **Privacy Policy URL and Support URL** are in different places. Privacy is under App Privacy in the sidebar. Support URL is in the version's localization section alongside the description.
- **App icon** didn't show until a build with App Store Connect distribution was attached to the version
- **Missing Compliance** flag on the build -- selected No for encryption (standard HTTPS is exempt)
- **Content Rights** -- selected Yes since the app accesses Wikidata (CC0 licensed)
- **iPad screenshots required** because the build targeted both iPhone and iPad. Changed `TARGETED_DEVICE_FAMILY` to iPhone only to avoid needing iPad screenshots.
- **Screenshot dimensions** -- iPhone 16e screenshots (1170x2532) weren't accepted. Needed iPhone 17 Pro Max for the 6.9" size (2868x1320).
- **Banking info** takes 24 hours to process.

### App Store Listing

- **Subtitle (30 char max):** Is he still President?
- **Category:** News
- **Price:** $0.99

### Potential Rejection Risks

- **Guideline 4.2 (Minimum Functionality)** -- the app does exactly one thing
- **Guideline 4.3 (Spam)** -- could be seen as a novelty app
- **Guideline 1.1 (Objectionable Content)** -- politically sensitive, reviewer-dependent
- **Right of publicity** -- uses a public figure's name and likeness (the toupee icon)

## Links

- **Repo:** https://github.com/kodyabbott/trumpwatch
- **Privacy:** https://trumpclock.kodyabbott.com/privacy.html
- **Support:** https://trumpclock.kodyabbott.com/support.html
