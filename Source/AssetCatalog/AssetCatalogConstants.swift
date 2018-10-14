//
// Constants.swift
// Iconizer
// https://github.com/raphaelhanneken/iconizer
//

// MARK: - Platform names

/// Platform: Apple Watch
let appleWatchPlatformName = "Watch"
/// Platform: iPad
let iPadPlatformName = "iPad"
/// Platform: iPhone
let iPhonePlatformName = "iPhone"
/// Platform: OS X
let macOSPlatformName = "Mac"
/// Platform: Car Play
let carPlayPlatformName = "Car"
/// Platform: iOS – for icons that are needed on both, iPad and iPhone
let iOSPlatformName = "iOS"

// MARK: - Image Orientation names

///  Possible image orientations.
///
///  - Portrait:  Portrait image.
///  - Landscape: Landscape image.
enum ImageOrientation: String {
    case portrait
    case landscape
}

// MARK: - Directory names

/// Default url for app icons.
let appIconDir = "Iconizer Assets/App Icons"
/// Default url for launch images.
let launchImageDir = "Iconizer Assets/Launch Images"
/// Default url for image sets.
let imageSetDir = "Iconizer Assets/Image Sets"

// MARK: - Asset Types

///  Nicely wrap the different asset types into an enum.
///
///  - AppIcon:     Represents the AppIcon model
///  - ImageSet:    Represents the ImageSet model
///  - LaunchImage: Represents the LaunchImage model
enum IconAssetType: Int {
    case appIcon = 0
    case imageSet = 1
    case launchImage = 2
}
