import AppKit
import XCTest

@testable import LookAwayOverlaySupport

final class WindowControllerTests: XCTestCase {
    @MainActor
    func testBreakWindowCoversTheScreen() throws {
        _ = NSApplication.shared
        let screen = try XCTUnwrap(NSScreen.main)
        let contentViewController = NSViewController()
        contentViewController.view = NSView(frame: .zero)
        let controller = WindowController(
            screen: screen,
            contentViewController: contentViewController
        )
        defer { controller.close() }

        let window = try XCTUnwrap(controller.window)
        XCTAssertEqual(window.frame, screen.frame)
        XCTAssertEqual(contentViewController.view.frame, window.contentLayoutRect)
        XCTAssertEqual(window.styleMask, .borderless)
        XCTAssertEqual(window.level, .screenSaver)
        XCTAssertFalse(window.isOpaque)

        if #available(macOS 13.0, *) {
            XCTAssertTrue(window.collectionBehavior.contains(.canJoinAllApplications))
        } else {
            XCTAssertTrue(window.collectionBehavior.contains(.canJoinAllSpaces))
            XCTAssertTrue(window.collectionBehavior.contains(.fullScreenAuxiliary))
        }
    }
}
