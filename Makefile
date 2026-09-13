.PHONY: build run test xcode-test app package update sync clean
build:
	swift build -c release
run:
	swift run VolumeGuard
test:
	mkdir -p .build
	clang -fsyntax-only -Wall -Wextra -I Sources/StorageProbe/include Sources/StorageProbe/StorageProbe.c
	swiftc Sources/VolumeGuard/Metrics.swift Sources/VolumeGuard/Diagnostics.swift Checks/main.swift -o .build/VolumeGuardChecks
	.build/VolumeGuardChecks
xcode-test:
	swift test
app: build
	mkdir -p dist/VolumeGuard.app/Contents/MacOS
	cp .build/release/VolumeGuard dist/VolumeGuard.app/Contents/MacOS/VolumeGuard
	cp packaging/Info.plist dist/VolumeGuard.app/Contents/Info.plist
	codesign --force --sign - dist/VolumeGuard.app
package: app
	ditto -c -k --sequesterRsrc --keepParent dist/VolumeGuard.app dist/VolumeGuard-macOS.zip
update: build
	swift scripts/StopApp.swift
	$(MAKE) app
	mkdir -p "$(HOME)/Applications"
	ditto dist/VolumeGuard.app "$(HOME)/Applications/VolumeGuard.app"
	codesign --verify --deep --strict "$(HOME)/Applications/VolumeGuard.app"
	open "$(HOME)/Applications/VolumeGuard.app"
sync:
	git pull --ff-only
	$(MAKE) update
clean:
	swift package clean
