# Disk Metrics

A native macOS menu-bar storage monitor for the TTU HackWesTex 2026 challenge.
MIT licensed. Requires macOS 13+ and Swift 5.9+ (Xcode 15+ toolchain).

New to the project? Start with [the plain-language presentation and code guide](PRESENTATION-GUIDE.md). For public downloads, follow [the release guide](RELEASE-GUIDE.md). Changes are left uncommitted so team members can review and commit their own contributions.

The **Storage help** section uses everyday language. It shows the purpose and result of each check; full command output opens in a separate **View report** window for troubleshooting.

## Build on your Mac

Copy this entire folder to your Mac, or clone your team's repository. Open Terminal in that folder.

```sh
xcode-select --install
```

Finish the installation dialog if command-line tools are missing. Then:

```sh
swift --version
make test
make app
open dist/DiskMetrics.app
```

Look for **DiskMetrics** in the menu bar. The app does not need a Dock icon.
For development, `make run` runs the executable directly. Quit the existing instance first.
`make test` runs standalone calculation/parser checks using the command-line tools, without XCTest. `make xcode-test` runs the additional XCTest suite when a full Xcode testing environment is available.
If your command-line tools provide Swift older than 5.9, update the tools or use Xcode 15+.
No third-party Swift packages, paid developer account, or cloud service are required for the basic app. Detailed SSD telemetry optionally uses a separately installed smartmontools executable.
The app target uses local ad-hoc signing; it is not notarized for public binary distribution.

## Implemented

- Native SwiftUI menu-bar panel and separate dashboard window.
- Mounted-volume discovery, filesystem type, total/free capacity (including mounted NFS where readable).
- Aggregate backing-device read/write GB/s from available IOBlockStorageDriver registry counters.
- Rolling throughput chart, update timestamp, unavailable-data messages.
- Capacity alerts with three percentage points of recovery hysteresis.
- Mount disappearance alerts after a collection completes.
- Time-to-full estimate from net capacity growth over at least 20 seconds.
- Session alert history and JSON report export.
- Explicit simulated demo mode, which performs no workload writes.
- Physical-drive S.M.A.R.T. status when diskutil exposes it, with failing-device alerts.
- On-demand filesystem verification using diskutil verifyVolume (no repairs).
- APFS container/backing-store mapping and reported volume quota/reserve values.
- Named-user native quota reports, with permission and unsupported/no-record states.
- NFS mount options, client RPC statistics, and local NFS server user-activity reports.
- Accessible local process disk I/O by PID and UID, with PID-reuse protection.
- Sustained device/account write-activity alerts (investigation signals, not malicious-user verdicts).
- Optional notification-center alerts and persistent live alert history.
- Internal macOS volumes hidden by default; available through a toggle.

## Install this update

Quit the old running app. Copy the entire updated source folder to the Mac, including Sources/StorageProbe and Sources/DiskMetrics. Open Terminal in that folder and run:

```sh
make test
make app
open dist/VolumeGuard.app
```

The command-line check suite now expects **27/27 checks passed**. The simplified-dashboard/update-workflow version still requires macOS compilation and testing.
Hardware results appear prominently above the throughput chart: basic-check passed, failure warning, or unavailable. This is the reported S.M.A.R.T. status, not a calculated remaining-life percentage.

### Detailed SSD health

On a Mac with Homebrew installed, run:

```sh
brew install smartmontools
```

Then click **Refresh details**. VolumeGuard checks the standard Homebrew smartctl locations and runs a read-only JSON health query. Supported devices can report temperature, estimated endurance consumed, available spare/threshold, media errors, critical-warning bits, power-on hours, unsafe shutdowns, and cumulative reads/writes. Missing fields stay unknown. Device permissions and USB bridges can prevent access. The app does not automatically run sudo or install privileged helpers.

The smartmontools tool is an optional separate dependency, not bundled in the MIT source archive. Installation reference: [Homebrew smartmontools](https://formulae.brew.sh/formula/smartmontools). NVMe fields follow [smartmontools health-log output](https://www.smartmontools.org/static/doxygen/nvmeprint_8cpp_source.html).

### Filesystem read/write probe

Under **Storage details**, choose **Choose folder and run 64 MiB probe**. Select a local folder or an already mounted NFS share. The app writes and synchronizes a temporary file, reads it, reports application-observed GB/s, and removes that file. Immediate reads can be cached. These are opt-in workload measurements for a specific filesystem path, not continuous per-volume counters or maximum/durable physical-media speed. A stalled network filesystem can stall the probe. Cleanup failures name the temporary file for later removal.
Click **Open dashboard** in the menu-bar panel. Health, speed, capacity, application activity, reports, checks, alerts, and preferences are visible in a single scrolling window without disclosure dropdowns. Initial diagnostics can take a minute or longer when a device is slow. Each child command has its own timeout; details refresh separately from the main collector.

For subsequent builds, use **`make update`** to replace and reopen the installed app without deleting it. See [Updating on Mac](UPDATING-ON-MAC.md) for the one-folder workflow and optional GitHub synchronization.

To produce a downloadable archive on the Mac:

```sh
make package
```

This creates `dist/VolumeGuard-macOS.zip`. The binary matches the build Mac's architecture (Apple Silicon when built on this team's Mac). It is locally ad-hoc signed, not notarized; smooth public distribution still needs Developer ID signing/notarization. Source remains buildable without a paid account.

## Three-minute demo

1. Start in live mode. Show real APFS capacity and filesystem labels.
2. If available, mount your team's NFS share using the Mac's existing mount workflow; show its capacity. NFS throughput is not measured by the device chart.
3. Quit the live app and launch the installed app with `open "$HOME/Applications/VolumeGuard.app" --args --demo`. State clearly that the next scenario is simulated. Normal launches always use real collectors.
4. Watch dataset consumption grow. At the default 85% threshold an alert appears after roughly 30 seconds. After at least 20 seconds the growth forecast becomes available.
5. Export a report and show its `simulated` flag, volume fields, and alerts.
6. Quit and reopen without `--demo` to return to real data. Live saved alerts remain separate from the simulated session.

For a real capacity-alert demonstration, temporarily lower the alert slider below an existing volume's usage. Explain that you changed the threshold; do not fill the system disk.

## Team of four

1. **Mac integration:** build and test immediately; validate APFS capacity against Disk Utility and device counters against a trusted local tool. Capture any build failures verbatim.
2. **NFS and metrics:** prepare a real NFS share, test mount discovery, document unavailable counters and shared-space behavior. Avoid changing shared infrastructure without authorization.
3. **UI and demo:** refine the visual hierarchy, add a mascot if time permits, record a short backup video with clear live/simulated labels.
4. **QA and submission:** run tests, verify exports, publish the public repository, check README instructions from a clean clone, prepare the presentation and future-work slide.

Integrate early. Freeze new features a few hours before judging.

## Validation checklist

- `make test` and `make app` succeed on the actual demo Mac.
- Open the packaged app and verify menu-bar panel and separate window.
- Check live free/total capacity and filesystem type against macOS tools.
- Observe device and process throughput during an ordinary bounded file copy; zero activity should not be confused with missing counters. Cached copies may not produce equivalent physical I/O.
- Compare physical device S.M.A.R.T. status with Disk Utility; unavailable status must never become a healthy verdict.
- Read the visible user quota and NFS report cards; check reported failures on unsupported/unconfigured systems.
- Enable notifications and trigger a demo capacity alert, then test report export and live alert persistence across restart.
- Only run filesystem verification when saved work and temporary disk disruption are acceptable; check the full output rather than interpreting every nonzero status as corruption.
- Test demo alert, forecast, report export, canceling export, and switching back to live mode.
- Connect/disconnect a disposable external volume; verify disappearance alert.
- If claiming NFS coverage, test against a real mounted share before judging.
- Check CPU and memory overhead in Activity Monitor.

The team reports the preceding expanded version works on its Mac. The latest dashboard, freshness, and updater changes were authored on Windows and have **not yet been compiled or tested on macOS**. The included GitHub Actions workflow runs build/tests when pushed, but does not substitute for hardware/UI verification.

## Scope and known limitations

- APFS volumes share container capacity. Do not sum displayed volume totals.
- The main throughput chart is aggregate available physical-device activity, not per-volume or NFS traffic. Separate process counters cover accessible processes only and are not tied to volumes. Hardware counter availability varies. Device changes can cause discontinuities; this MVP resets on counter regressions or changed device count.
- Capacity discovery uses filesystem calls on a background task. A stalled network mount can delay the collection; there is no hard timeout or isolated collector process yet. The timestamp exposes stale samples. Missing mounts can also reflect a metadata read failure; disappearance alerts ask the administrator to investigate.
- Growth estimates are simple recent-window estimates, not guarantees; deletion, snapshots, shared APFS allocations, and workload changes affect them.
- S.M.A.R.T. and detailed smartmontools telemetry depend on hardware/interface support and permissions. NVMe endurance consumed is a manufacturer estimate, can exceed 100%, and is not a failure-date prediction. Filesystem verification may fail due to permissions, unsupported volume types, or timeouts. Read the command result; no automatic repair is performed.
- User quotas are queried using the native quota command; APFS volume limits are separate. The app cannot add missing per-user quota support or query another user's limits without OS/server permission. Native reports retain their source headers/units and are not normalized into a quota chart.
- NFS client diagnostics are cumulative operation/RPC counters, not per-share GB/s. Local NFS server user records do not expose remote server users. pNFS is **not implemented or validated**; it needs a supported client/server test environment. No NFS mount is presented as proof of pNFS support.
- Activity alerts identify heavy observed writes, not malicious intent. Inaccessible, short-lived, and scan-limit-excluded processes are not fully observed. No process is killed and no user is blocked.
- Live alerts persist under `~/Library/Application Support/VolumeGuard/alerts.json` (latest 200). Demo alerts are isolated and never written to live history. Notifications require an explicit user opt-in and macOS permission.
- Internal `/System/Volumes/` service volumes are omitted from capacity alerts; the main user-facing startup volume is monitored.
- No file content is scanned. Exported reports can contain volume paths, process names, account IDs, and NFS server addresses; review before sharing.

## Future work

1. Isolated collectors with timeouts, stale-data states, and independent per-volume refresh.
2. Per-share byte throughput and pNFS validation on a suitable server/client pair.
3. Snapshot accounting and normalized per-user quota charts with controlled server fixtures.
4. Broader supported-hardware fixtures and validated ATA/SCSI wear attribute interpretation.
5. Per-volume process attribution and stronger anomaly baselines with false-positive evaluation.
6. Configurable retention, automatic recovery alerts, and a signed/notarized release.
7. Optional local AI explanations grounded in collected evidence.

## Public submission

Create a public GitHub/GitLab repository and push this source before judging. Include your team names, a demo-video link, screenshots, tested macOS version, and precise supported/unsupported features. Never submit only local files. The repository has not been published automatically.

## Collection references

- [Apple disk health information](https://support.apple.com/en-kw/guide/disk-utility/dskutl1005/mac)
- [Apple NFS command documentation](https://github.com/apple-oss-distributions/NFS/blob/main/nfsstat/nfsstat.1)
- [Apple quota command documentation](https://github.com/apple-oss-distributions/diskdev_cmds/blob/main/quota.tproj/quota.1)
- [Apple process resource counter definitions](https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/resource.h)
- On the target Mac, `man diskutil`, `man quota`, and `man nfsstat` describe the installed command versions. Read-only queries can still be unsupported or require privileges.
