import AppKit
import XCTest

@testable import LookAwayOverlaySupport

final class BreakWindowConfigurationTests: XCTestCase {
    func testModernMacOSOverlayJoinsAllApplications() {
        guard #available(macOS 13.0, *) else { return }

        let behavior = BreakWindowConfiguration.collectionBehavior(
            for: OperatingSystemVersion(majorVersion: 26, minorVersion: 0, patchVersion: 0)
        )

        XCTAssertTrue(behavior.contains(.canJoinAllApplications))
        XCTAssertTrue(behavior.contains(.stationary))
        XCTAssertTrue(behavior.contains(.ignoresCycle))
        XCTAssertFalse(behavior.contains(.fullScreenPrimary))
    }

    func testPreVenturaOverlayJoinsEverySpaceAndFullScreenWindow() {
        let behavior = BreakWindowConfiguration.collectionBehavior(
            for: OperatingSystemVersion(majorVersion: 11, minorVersion: 0, patchVersion: 0)
        )

        XCTAssertTrue(behavior.contains(.canJoinAllSpaces))
        XCTAssertTrue(behavior.contains(.fullScreenAuxiliary))
        XCTAssertTrue(behavior.contains(.stationary))
        XCTAssertFalse(behavior.contains(.fullScreenPrimary))
    }

    func testOverlayUsesBorderlessScreenSaverWindow() {
        XCTAssertEqual(BreakWindowConfiguration.styleMask, .borderless)
        XCTAssertEqual(BreakWindowConfiguration.level, .screenSaver)
    }

    @MainActor
    func testApplyingConfigurationCoversTheCurrentScreen() throws {
        guard #available(macOS 13.0, *) else { return }

        _ = NSApplication.shared
        let screen = try XCTUnwrap(NSScreen.main)
        let window = NSWindow(
            contentRect: .zero,
            styleMask: .titled,
            backing: .buffered,
            defer: false,
            screen: screen
        )
        defer { window.close() }

        BreakWindowConfiguration.apply(to: window, on: screen)

        XCTAssertEqual(window.frame, screen.frame)
        XCTAssertEqual(window.styleMask, .borderless)
        XCTAssertEqual(window.level, .screenSaver)
        XCTAssertFalse(window.isOpaque)
        XCTAssertFalse(window.hasShadow)
        XCTAssertFalse(window.hidesOnDeactivate)
        XCTAssertFalse(window.isReleasedWhenClosed)
        XCTAssertTrue(window.collectionBehavior.contains(.canJoinAllApplications))
    }
}
