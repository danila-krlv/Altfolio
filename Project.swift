import ProjectDescription

let targetSettings: SettingsDictionary = [
    "CODE_SIGN_STYLE": "Automatic",
    "CURRENT_PROJECT_VERSION": "1",
    "MARKETING_VERSION": "1.0",
    "SWIFT_VERSION": "5.0",
    "SUPPORTS_MACCATALYST": "NO",
    "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "NO",
]

let project = Project(
    name: "Altfolio",
    options: .options(automaticSchemesOptions: .disabled),
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Configurations/Debug.xcconfig"),
            .release(name: "Release", xcconfig: "Configurations/Release.xcconfig"),
        ],
        defaultSettings: .none
    ),
    targets: [
        .target(
            name: "Altfolio",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "-.Altfolio",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .file(path: "Altfolio/Resources/Info.plist"),
            sources: ["Altfolio/**/*.swift"],
            resources: [
                "Altfolio/Resources/Assets.xcassets",
                "Altfolio/Resources/Base.lproj/LaunchScreen.storyboard",
            ],
            dependencies: [.external(name: "Alamofire")],
            settings: .settings(base: targetSettings.merging([
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                "GENERATE_INFOPLIST_FILE": "YES",
                "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                "INFOPLIST_KEY_UILaunchStoryboardName": "LaunchScreen",
                "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                "SWIFT_EMIT_LOC_STRINGS": "YES",
            ], uniquingKeysWith: { _, new in new })),
            coreDataModels: [
                .coreDataModel(
                    "Altfolio/Main/Managers/CoreData/Altfolio.xcdatamodeld"
                )
            ]
        ),
        .target(
            name: "AltfolioTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "-.AltfolioTests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["AltfolioTests/**/*.swift"],
            dependencies: [.target(name: "Altfolio")],
            settings: .settings(base: targetSettings)
        ),
        .target(
            name: "AltfolioUITests",
            destinations: [.iPhone, .iPad],
            product: .uiTests,
            bundleId: "-.AltfolioUITests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["AltfolioUITests/**/*.swift"],
            dependencies: [.target(name: "Altfolio")],
            settings: .settings(base: targetSettings)
        ),
    ],
    schemes: [
        .scheme(
            name: "Altfolio",
            shared: true,
            buildAction: .buildAction(targets: ["Altfolio"]),
            testAction: .targets(["AltfolioTests", "AltfolioUITests"], configuration: "Debug"),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
    ],
    resourceSynthesizers: []
)
