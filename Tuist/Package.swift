// swift-tools-version: 6.3
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: ["Alamofire": .staticFramework]
    )
#endif

let package = Package(
    name: "AltfolioDependencies",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.12.0")
    ]
)
