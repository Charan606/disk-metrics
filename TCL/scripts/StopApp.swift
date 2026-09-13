import AppKit
import Foundation

let applications = NSRunningApplication.runningApplications(withBundleIdentifier: "org.hackwestex.volumeguard")
for application in applications { _ = application.terminate() }
let deadline = Date().addingTimeInterval(10)
while applications.contains(where: { !$0.isTerminated }) && Date() < deadline {
    RunLoop.current.run(until: Date().addingTimeInterval(0.1))
}
if applications.contains(where: { !$0.isTerminated }) {
    print("VolumeGuard did not quit. Quit it from its menu, then run make update again. No app was replaced.")
    exit(1)
}
