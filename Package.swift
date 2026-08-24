// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LookAwayOverlaySupport",
    platforms: [.macOS(.v10_14)],
    targets: [
        .target(
            name: "LookAwayOverlaySupport",
            path: "LookAway",
            exclude: [
                "AppDelegate.swift",
                "Assets.xcassets",
                "Base.lproj",
                "DockIcon.swift",
                "Info.plist",
                "LookAway.entitlements",
                "ViewController.swift",
            ],
            sources: [
                "WindowController.swift",
            ]
        ),
        .testTarget(
            name: "LookAwayOverlaySupportTests",
            dependencies: ["LookAwayOverlaySupport"],
            path: "Tests/LookAwayOverlaySupportTests"
        ),
    ]
)
