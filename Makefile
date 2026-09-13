.PHONY: build run test xcode-test app package update sync clean
build:
	swift build -c release
run:
	swift run DiskMetrics
test:
	mkdir -p .build
	clang -fsyntax-only -Wall -Wextra -I Sources/StorageProbe/include Sources/StorageProbe/StorageProbe.c
	swiftc Sources/DiskMetrics/Metrics.swift Sources/DiskMetrics/Diagnostics.swift Checks/main.swift -o .build/DiskMetricsChecks
	.build/DiskMetricsChecks
xcode-test:
	swift test
app: build
	mkdir -p ".build/bundle/Disk Metrics.app/Contents/MacOS"
	cp .build/release/DiskMetrics ".build/bundle/Disk Metrics.app/Contents/MacOS/DiskMetrics"
	cp packaging/Info.plist ".build/bundle/Disk Metrics.app/Contents/Info.plist"
	codesign --force --sign - ".build/bundle/Disk Metrics.app"
	swift scripts/ReplaceApp.swift ".build/bundle/Disk Metrics.app" "dist/Disk Metrics.app"
package: app
	ditto -c -k --sequesterRsrc --keepParent "dist/Disk Metrics.app" dist/Disk-Metrics-macOS.zip
update: build
	swift scripts/StopApp.swift
	$(MAKE) app
	mkdir -p "$(HOME)/Applications"
	swift scripts/ReplaceApp.swift "dist/Disk Metrics.app" "$(HOME)/Applications/Disk Metrics.app"
	codesign --verify --deep --strict "$(HOME)/Applications/Disk Metrics.app"
	open "$(HOME)/Applications/Disk Metrics.app"
sync:
	git pull --ff-only
	$(MAKE) update
clean:
	swift package clean
