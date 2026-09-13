# Publish VolumeGuard so people can download it

## Current state

The code exists locally. No GitHub remote is configured here. No public release has been uploaded. The assistant has not committed or pushed any changes. You and your teammate own the commits and publication steps.

## 1. Create the public repository

Sign in to GitHub. Use the + menu to create a new repository named `VolumeGuard`. Choose **Public**. For importing this existing project, leave automatic README/license/gitignore initialization off. Create the repository and copy its URL.

Use GitHub Desktop to avoid complicated Git commands. Choose **File → Clone repository → URL**, paste the URL of the empty repository you just created, and clone it into a new folder. Copy the contents of the extracted final TCL folder into that clone (do not copy or replace a `.git` folder). In GitHub Desktop, review the changed files, enter a meaningful commit message, choose **Commit to main**, then **Push origin**. These are actions for YOU to perform; the assistant has not done them. Do not upload `.build`, installed apps, temporary probe files or personal diagnostic exports as source. `.gitignore` excludes build outputs and delivery archives.

## 2. Make real contributions under both accounts

Each person should configure their own Git name and an email associated with their GitHub account (a GitHub-provided no-reply email works). GitHub Desktop exposes this in its Git settings. Do not share account passwords or use someone else's identity.

One person can commit the implementation they reviewed and tested. The other can make a genuine change—such as correcting the setup instructions after testing from a clean clone, adding a useful test, or improving the interface—and commit it using their own identity. Invite the teammate as a collaborator, or use a fork and pull request. Merge real contributions into the default branch. Contributor displays may take time to update; they are not created just by adding a name to the README. Preserve separate real commits if you want each authorship to be visible; do not fabricate contribution history.

## 3. Build the downloadable app on the Mac

In the source folder, run:

```sh
make test
make package
```

Find `dist/VolumeGuard-macOS.zip` in Finder. This is the **app download**. It contains the compiled VolumeGuard.app. The `final TCL.zip` supplied during development contains source code instead; it is not the end-user app download.

If building while running a copy from `dist`, quit that copy first. The normal `make update` workflow installs a separate copy under your personal Applications folder.

## 4. Create a GitHub Release

On the repository page, open **Releases**, choose **Draft a new release**, create a version tag such as `v0.1.0`, and give it a clear title such as `VolumeGuard 0.1 — HackWesTex preview`. Copy the release description from RELEASE-NOTES.md and adjust tested details. Attach `dist/VolumeGuard-macOS.zip` in the release's asset area. Publish the release only after verifying the asset.

GitHub documents attaching compiled programs to releases here: https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository

Now share your repository's Releases page. A separate website or App Store listing is not required for a public download.

## 5. What users do

Users download **VolumeGuard-macOS.zip** from the release, extract it, move **VolumeGuard.app** into Applications, and open it. They click its menu-bar icon and **Open dashboard**. They do not run `make` or install Swift to use the binary.

The current release is an Apple Silicon build when built on your Apple Silicon Mac. It targets macOS 13+; verify on the macOS versions you intend to claim. Do not claim Intel support for an arm64-only archive.

Detailed drive-health metrics optionally require smartmontools. Basic monitoring works without that separate executable, with unavailable detail fields honestly labeled.

## 6. Apple signing limitation

Our packaging currently uses **ad-hoc signing**, which is useful for local builds but is not Developer ID signing/notarization. On another Mac, Gatekeeper may block normal opening. Do not advertise a warning-free installation yet.

For people who trust the release, Apple documents the explicit Privacy & Security approval path: https://support.apple.com/en-gb/102445 . Do not tell users to disable Gatekeeper or remove security controls globally.

For a polished public distribution, use an Apple Developer ID Application certificate, hardened runtime and notarization, then staple the ticket and repackage the final app. This needs your team's developer identity and credentials on the Mac; they must not be sent in chat or stored in the repository. Apple's process is here: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution . The current Makefile does not perform this process.

Test the downloaded asset on another Mac, including opening it, menu-bar access, report export and notifications. A successful build alone does not prove successful distribution.

## 7. Future updates

For your team: keep one cloned source folder. After teammates push changes, `make sync` pulls and installs the new build. It stops instead of discarding conflicting local edits. `make update` rebuilds from local changes without pulling.

For ordinary downloaders: publish a new release and have them replace the app with that version. There is no automatic internet updater in this project yet. Saved alerts are kept separately from the app bundle.
