//
// JSONFile.swift
// Iconizer
// https://github.com/raphaelhanneken/iconizer
//

import Cocoa

/// Reads and writes the Contents.json files.
struct ContentsJSON {

    /// The image information from <IconAssetType>.json
    var images: [[String: String]]

    /// The Contents.json file as array.
    var contents: [String: Any] = [:]

    let appIconCar = Data(bytes: &AppIcon_Car_json, count: Int(AppIcon_Car_json_len))
    let appIconIOS = Data(bytes: &AppIcon_iOS_json, count: Int(AppIcon_iOS_json_len))
    let appIconIPad = Data(bytes: &AppIcon_iPad_json, count: Int(AppIcon_iPad_json_len))
    let appIconIPhone = Data(bytes: &AppIcon_iPhone_json, count: Int(AppIcon_iPhone_json_len))
    let appIconMac = Data(bytes: &AppIcon_Mac_json, count: Int(AppIcon_Mac_json_len))
    let appIconWatch = Data(bytes: &AppIcon_Watch_json, count: Int(AppIcon_Watch_json_len))
    var dataMap: [String: Data] = [:]

    // MARK: Initializers

    /// Initialize a new ContentsJSON instance.
    init() {
        // Init the images array.
        images = []

        // Init the contents array, with general information.
        contents["author"] = "Iconizer & Sango"
        contents["version"] = "1.0"
        contents["properties"] = ["pre-rendered": true]
        contents["images"] = []

        dataMap[nameForResource(forIconAssetType: .appIcon, andPlatform: iPadPlatformName)] = appIconIPad
        dataMap[nameForResource(forIconAssetType: .appIcon, andPlatform: iPhonePlatformName)] = appIconIPhone
        dataMap[nameForResource(forIconAssetType: .appIcon, andPlatform: iOSPlatformName)] = appIconIOS
        dataMap[nameForResource(forIconAssetType: .appIcon, andPlatform: macOSPlatformName)] = appIconMac
        dataMap[nameForResource(forIconAssetType: .appIcon, andPlatform: carPlayPlatformName)] = appIconCar
        dataMap[nameForResource(forIconAssetType: .appIcon, andPlatform: appleWatchPlatformName)] = appIconWatch
    }

    /// Initialize a new ContentsJSON instance with a specified Asset Type
    /// and selected platforms.
    ///
    /// - Parameters:
    ///   - type: The asset type to get the JSON data for.
    ///   - platforms: The platforms selected by the user.
    /// - Throws: See ContentsJSONError for possible values.
    init(forType type: IconAssetType, andPlatforms platforms: [String]) throws {
        self.init()
        for platform in platforms {
            images += try arrayFromJson(forType: type, andPlatform: platform)
        }
    }

    init(forType type: IconAssetType,
         andPlatforms platforms: [String],
         withOrientation orientation: ImageOrientation) throws {
        self.init()
        for var platform in platforms {
            switch orientation {
            case .landscape:
                platform += "_Landscape"
            case .portrait:
                platform += "_Portrait"
            }
            images += try arrayFromJson(forType: type, andPlatform: platform)
        }
    }

    // MARK: Methods

    /// Get the asset information for the supplied Asset Type.
    ///
    /// - Parameters:
    ///   - type: The asset type to get the information for.
    ///   - platform: The platforms selected by the user.
    /// - Returns: The Contents.json for the supplied asset type and platforms as Array.
    /// - Throws: See ContentsJSONError for possible values.
    func arrayFromJson(forType type: IconAssetType, andPlatform platform: String) throws -> [[String: String]] {
        guard let resourceData = resourceFrom(forIconAssetType: type, andPlatform: platform) else {
            throw ContentsJSONError.fileNotFound
        }
        // Create a new JSON object from the given data.
        let json = try JSONSerialization.jsonObject(with: resourceData, options: [.allowFragments])

        // Convert the JSON object into a Dictionary.
        guard let contents = json as? [String: AnyObject] else {
            throw ContentsJSONError.castingJSONToDictionaryFailed
        }
        // Get the image information from the JSON dictionary.
        guard let images = contents["images"] as? [[String: String]] else {
            throw ContentsJSONError.gettingImagesArrayFailed
        }

        // Return the image information.
        return images
    }

    private func nameForResource(forIconAssetType type: IconAssetType, andPlatform platform: String) -> String {
        let resource: String
        switch type {
        case .appIcon:
            resource = "AppIcon_" + platform
        case .imageSet:
            resource = "ImageSet"
        case .launchImage:
            resource = "LaunchImage_" + platform
        }
        return resource
    }

    private func resourceFrom(forIconAssetType type: IconAssetType, andPlatform platform: String) -> Data? {
        let key = nameForResource(forIconAssetType: type, andPlatform: platform)
        return dataMap[key]
    }

    ///  Saves the Contents.json to the appropriate folder.
    ///
    ///  - parameter url: File url to save the Contents.json to.
    ///  - throws: An exception when the JSON serialization fails.
    /// Save the Contents.json to the supplied file URL.
    ///
    /// - Parameter url: The file URL to save the Contents.json to.
    /// - Throws: See JSONSerialization for possible values.
    mutating func saveToURL(_ url: URL) throws {
        contents["images"] = images.sorted(by: { (left, right) -> Bool in
            var leftValue = 0
            var rightValue = 0
            if let l = left["expected-size"] {
                leftValue = Int(l) ?? 0
            }
            if let r = right["expected-size"] {
                rightValue = Int(r) ?? 0
            }
            let il = left["filename"] ?? "0"
            let ir = right["filename"] ?? "1"

            if leftValue == rightValue {
                return il < ir
            }
            return leftValue < rightValue
        })
        var keys = JSONSerialization.WritingOptions.prettyPrinted
        if #available(OSX 10.13, *) {
            keys = [JSONSerialization.WritingOptions.sortedKeys, JSONSerialization.WritingOptions.prettyPrinted]
        }
        let data = try JSONSerialization.data(withJSONObject: contents, options: keys)
        try data.write(to: url.appendingPathComponent("Contents.json", isDirectory: false), options: .atomic)
        images.removeAll()
    }
}
