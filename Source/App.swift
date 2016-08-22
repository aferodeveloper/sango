//
//  App.swift
//  Sango
//
//  Created by Steve Hales on 8/10/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

import Foundation
import AppKit
import CoreGraphics

// See:
// https://docs.google.com/document/d/1X-pHtwzB6Qbkh0uuhmqtG98o2_Dv_okDUim6Ohxhd8U/edit
// for more details

private let SchemaVersion = 1

private let keySchemaVersion = "schemaVersion"
private let keyFonts = "fonts"
private let keyImages = "images"
private let keyImagesScaled = "imagesScaled"
private let keyImagesIos = "imagesIos"
private let keyImagesAndroid = "imagesAndroid"
private let keyImagesTinted = "imagesTinted"
private let keyGlobalTint = "globalTint"
private let keyCopied = "copied"
private let keyAppIcon = "appIcon"
private let keyIOSAppIcon = "iOSAppIcon"
private let keyAndroidAppIcon = "androidAppIcon"
private let keyJava = "java"
private let keySwift = "swift"
private let firstPassIgnoredKeys = [keyCopied, keyIOSAppIcon, keyAndroidAppIcon, keyAppIcon,
                                    keyFonts, keySchemaVersion, keyImages,
                                    keyImagesScaled, keyImagesIos, keyImagesAndroid,
                                    keyImagesTinted, keyJava, keySwift, keyGlobalTint]

private enum LangType {
    case Unset
    case Java
    case Swift
}

class App
{
    private var package:String = ""
    private var baseClass:String = ""
    private var sourceAssetFolder:String? = nil
    private var outputAssetFolder:String? = nil

    private var inputFile:String? = nil
    private var inputFiles:[String]? = nil
    private var outputClassFile:String? = nil

    private var compileType:LangType = .Unset

    private var verbose = false
    private var globalTint:NSColor? = nil

    func usage() -> Void {
        print("Usage:")
        print(" -asset_template [basename]          creates a json template, specificly for the assets")
        print(" -config_template [file.json]        creates a json template, specificly for the app")
        print(" -config [file.json]                 use config file for options, instead of command line")
        print(" -input [file.json]                  asset json file")
        print(" -inputs [file1.json file2.json ...] merges asset files and process")
        print(" -input_assets [folder]              asset source folder (read)")
        print(" -out_source [source.java|swift]     path to result of language")
        print(" -java                               write java source")
        print(" -swift                              write swift source")
        print(" -out_assets [folder]                asset root folder (write), typically iOS Resource, or Android app/src/main")
        print(" -verbose                            be verbose in details")
    }

    func debug(text: String) -> Void {
        if (verbose) {
            print(text)
        }
    }
    
    // Save image, tinted
    func saveImage(image: NSImage, file: String) -> Bool {
        if (globalTint != nil) {
            let tintedImage = image.tint(globalTint!)
            return tintedImage.saveTo(file)
        }
        else {
            return image.saveTo(file)
        }
    }
    
    private func writeImageStringArray(stringArray: Dictionary<String, AnyObject>, type: LangType) -> String {
        var outputString = "\n"
        if (type == .Swift) {
            // public static let UI_SECONDARY_COLOR_TINTED = ["account_avatar1", "account_avatar2"]
            for (key, value) in stringArray {
                outputString.appendContentsOf("\tpublic static let \(key) = [\"")
                let strValue = String(value)
                outputString.appendContentsOf(strValue + "\"]\n")
            }
        }
        else if (type == .Java) {
            // public static final String[] UI_SECONDARY_COLOR_TINTED = {"account_avatar1", "account_avatar2"};
            for (key, value) in stringArray {
                outputString.appendContentsOf("\tpublic static final String[] \(key) = {\"")
                let strValue = String(value)
                outputString.appendContentsOf(strValue + "\"};\n")
            }
        }
        else {
            print("Error: invalide output type")
            exit(-1)
        }
        return outputString
    }

    private func parseColor(color: String) -> (r:Double, g:Double, b:Double, a:Double, s:Int, rgb:UInt32)? {
        var red:Double = 0
        var green:Double = 0
        var blue:Double = 0
        var alpha:Double = 1
        var rgbValue:UInt32 = 0
        var isColor = false
        var size = 0

        let parts = color.componentsSeparatedByString(",")
        if (parts.count == 3 || parts.count == 4) {
            // color
            red = Double(parts[0])! / 255.0
            green = Double(parts[1])! / 255.0
            blue = Double(parts[2])! / 255.0
            alpha = 1
            size = 3
            if (parts.count == 4) {
                alpha = Double(parts[3])! / 255.0
                size = 4
            }
            isColor = true
            let r = UInt32(red * 255.0)
            let g = UInt32(green * 255.0)
            let b = UInt32(blue * 255.0)
            let a = UInt32(alpha * 255.0)
            rgbValue = (a << 24) | (r << 16) | (g << 8) | b
        }
        else if (color.hasPrefix("#")) {
            var hexStr = color.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
            hexStr = hexStr.substringFromIndex(hexStr.startIndex.advancedBy(1))
            
            NSScanner(string: hexStr).scanHexInt(&rgbValue)
            red = 1
            green = 1
            blue = 1
            alpha = 1
            
            if (hexStr.characters.count < 6) {
                print("Error: not enough characters for hex color definition. Needs 6.")
                exit(-1)
            }
            
            if (hexStr.characters.count >= 6) {
                red = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
                green = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
                blue = Double(rgbValue & 0x000000FF) / 255.0
                size = 3
            }
            if (hexStr.characters.count == 8) {
                alpha = Double((rgbValue & 0xFF000000) >> 24) / 255.0
                size = 4
            }
            isColor = true
        }
        if (isColor) {
            return (r: red, g: green, b: blue, a: alpha, s: size, rgb:rgbValue)
        }
        return nil
    }
    
    private func writeConstants(name: String, constants: Dictionary<String, AnyObject>, type: LangType) -> String {
        var outputString = "\n"
        if (type == .Swift) {
            outputString.appendContentsOf("public struct ")
            outputString.appendContentsOf(name + " {\n")
            for (key, value) in constants {
                let line = "\tstatic let " + key.snakeCaseToCamelCase() + " = "
                outputString.appendContentsOf(line)

                var useQuotes = false
                let strValue = String(value)
                if (value is String) {
                    useQuotes = true
                    if (strValue.isNumber() == true) {
                        useQuotes = false
                    }
                    else {
                        let color = parseColor(strValue)
                        if (color != nil) {
                            let line = "UIColor(red: \(color!.r.roundTo3f), green: \(color!.g.roundTo3f), blue: \(color!.b.roundTo3f), alpha: \(color!.a.roundTo3f))"
                            outputString.appendContentsOf(line + "\t// ")
                            useQuotes = false
                        }
                    }
                }
                if (useQuotes) {
                    let line = "\"" + String(value) + "\""
                    outputString.appendContentsOf(line);
                }
                else {
                    let line = String(value)
                    outputString.appendContentsOf(line);
                }
                outputString.appendContentsOf("\n")
            }
            outputString.appendContentsOf("}")
        }
        else if (type == .Java) {
            outputString.appendContentsOf("public final class ")
            outputString.appendContentsOf(name + " {\n")

            for (key, value) in constants {
                var type = "int"
                var endQuote = ";"
                var parmSize = ""
                var useQuotes = false
                var strValue = String(value)
                if (value is String) {
                    useQuotes = true
                    if (strValue.isNumber() == true) {
                        useQuotes = false
                    }
                    else {
                        type = "String"

                        let color = parseColor(strValue)
                        if (color != nil) {
                            type = "int"
                            if (color?.s == 4) {
                                parmSize = "L"
                                type = "long"
                            }
                            let line = String(color!.rgb)
                            strValue = String(line + parmSize + ";\t// \(value)")
                            useQuotes = false
                            endQuote = ""
                        }
                    }
                }

                let line = "\tpublic static final " + type + " " + key + " = "
                outputString.appendContentsOf(line)
                if (useQuotes) {
                    let line = "\"" + strValue + "\"" + endQuote
                    outputString.appendContentsOf(line);
                }
                else {
                    let line = strValue + endQuote
                    outputString.appendContentsOf(line);
                }
                outputString.appendContentsOf("\n")
            }
            outputString.appendContentsOf("}")
        }
        else {
            print("Error: invalide output type")
            exit(-1)
        }
        return outputString
    }

    // http://petrnohejl.github.io/Android-Cheatsheet-For-Graphic-Designers/
    
    private func scaleAndCopyImages(files: [String], type: LangType, useRoot: Bool) -> Void {
        for file in files {
            let filePath = sourceAssetFolder! + "/" + file
            var destFile:String
            if (useRoot) {
                destFile = outputAssetFolder! + "/" + (file as NSString).lastPathComponent
            }
            else {
                destFile = outputAssetFolder! + "/" + file  // can include file/does/include/path
            }
            let destPath = (destFile as NSString).stringByDeletingLastPathComponent
            createFolder(destPath)

            var fileName = (file as NSString).lastPathComponent
            fileName = (fileName as NSString).stringByDeletingPathExtension
            fileName = fileName.stringByReplacingOccurrencesOfString("@2x", withString: "")
            fileName = fileName.stringByReplacingOccurrencesOfString("@3x", withString: "")

            if (type == .Swift) {
                // Ok, we're going to create the @3, @2, and normal size from the given assumed largest image
                let image3 = NSImage.loadFrom(filePath) // @3
                if (image3 == nil) {
                    print("Error: missing file \(filePath)")
                    exit(-1)
                }
                let image2 = image3.scale(66.67)        // @2
                let image = image3.scale(33.34)         // @1
                var file = destPath + "/" + fileName + "@3x.png"
                if (saveImage(image3, file: file) == false) {
                    exit(-1)
                }
                debug("Image scale and copy \(filePath) -> \(file)")
                file = destPath + "/" + fileName + "@2x.png"
                if (saveImage(image2, file: file) == false) {
                    exit(-1)
                }
                debug("Image scale and copy \(filePath) -> \(file)")
                file = destPath + "/" + fileName + ".png"
                if (saveImage(image, file: file) == false) {
                    exit(-1)
                }
                debug("Image scale and copy \(filePath) -> \(file)")
            }
            else if (type == .Java) {
                let image4 = NSImage.loadFrom(filePath) // 3x
                if (image4 == nil) {
                    print("Error: missing file \(filePath)")
                    exit(-1)
                }
                let image3 = image4.scale(66.67)        // 2x
                let image2 = image4.scale(50)           // 1.5x
                let image = image4.scale(33.34)         // 1x
                let mdpi = destPath + "/res/drawable-mdpi/"
                let hdpi = destPath + "/res/drawable-hdpi/"
                let xhdpi = destPath + "/res/drawable-xhdpi/"
                let xxhdpi = destPath + "/res/drawable-xxhdpi/"
                createFolders([mdpi, hdpi, xhdpi, xxhdpi])
                fileName = fileName + ".png"
                var file = xxhdpi + fileName
                if (saveImage(image4, file: file) == false) {
                    exit(-1)
                }
                debug("Image scale and copy \(filePath) -> \(file)")
                file = xhdpi + fileName
                if (saveImage(image3, file: file) == false) {
                    exit(-1)
                }
                debug("Image scale and copy \(filePath) -> \(file)")
                file = hdpi + fileName
                if (saveImage(image2, file: file) == false) {
                    exit(-1)
                }
                debug("Image scale and copy \(filePath) -> \(file)")
                file = mdpi + fileName
                if (saveImage(image, file: file) == false) {
                    exit(-1)
                }
                debug("Image scale and copy \(filePath) -> \(file)")
            }
            else {
                print("Error: wrong type")
                exit(-1)
            }
        }
    }
    
    // this table to used to place images marked with either @2, @3 into their respective android equals
    private let iOStoAndroid = [
        1: "mdpi",
        2: "xhdpi",
        3: "xxhdpi"
    ]

    
    private func imageResourcePath(file: String, type: LangType, useRoot: Bool) -> (sourceFile: String,
                                                                                    destFile: String,
                                                                                    destPath: String)
    {
        let filePath = sourceAssetFolder! + "/" + file
        var destFile:String
        if (useRoot) {
            destFile = outputAssetFolder! + "/" + (file as NSString).lastPathComponent
        }
        else {
            destFile = outputAssetFolder! + "/" + file  // can include file/does/include/path
        }
        var destPath = (destFile as NSString).stringByDeletingLastPathComponent
        
        var fileName = (file as NSString).lastPathComponent
        fileName = (fileName as NSString).stringByDeletingPathExtension
        
        if (type == .Swift) {
            // do nothing
        }
        else if (type == .Java) {
            let result = NSImage.getScaleFrom(fileName)
            let drawable = iOStoAndroid[result.scale]!
            destPath = destPath + "/res/drawable-" + drawable + "/"
            destFile = destPath + result.file + ".png"
        }
        else {
            print("Error: Wrong type")
            exit(-1)
        }
        return (sourceFile: filePath, destFile: destFile, destPath: destPath)
    }
    
    private func copyImage(file: String, type: LangType, useRoot: Bool) -> Void
    {
        let roots = imageResourcePath(file, type: type, useRoot: useRoot)
        createFolder(roots.destPath)
        if (globalTint == nil) {
            copyFile(roots.sourceFile, dest: roots.destFile)
        }
        else {
            let image = NSImage.loadFrom(roots.sourceFile)
            if (image != nil) {
                saveImage(image, file: roots.destFile)
            }
            else {
                print("Error: Can't find source image \(roots.sourceFile)")
            }
        }
    }

    private func copyImages(files: [String], type: LangType, useRoot: Bool) -> Void {
        for file in files {
            copyImage(file, type: type, useRoot: useRoot)
        }
    }
    
    private let iOSAppIconSizes = [
        "Icon-Small.png": 29,
        "Icon-Small@2x.png": 58,
        "Icon-Small@3x.png": 87,
        "Icon-Small-40.png": 40,
        "Icon-Small-40@2x.png": 80,
        "Icon-Small-40@3x.png": 120,
        "Icon-Small-50.png": 50,
        "Icon-Small-50@2x.png": 100,
        "Icon.png": 57,
        "Icon@2x.png": 114,
        "Icon-40.png": 40,
        "Icon-40@3x.png": 120,
        "Icon-60.png": 60,
        "Icon-60@2x.png": 120,
        "Icon-60@3x.png": 180,
        "Icon-72.png": 72,
        "Icon-72@2x.png": 144,
        "Icon-76.png": 76,
        "Icon-76@2x.png": 152,
        "Icon-80.png": 80,
        "Icon-80@2x.png": 160,
        "Icon-120.png": 120,
        "Icon-167.png": 167,
        "Icon-83.5@2x.png": 167
    ]
    // ic_launcher.png
    private let AndroidDefaultIconName = "ic_launcher.png"
    private let AndroidIconSizes = [
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192
    ]

    // http://iconhandbook.co.uk/reference/chart/android/
    // https://developer.apple.com/library/ios/qa/qa1686/_index.html
    private func copyAppIcon(file: String, type: LangType) -> Void {
        let filePath = sourceAssetFolder! + "/" + file
        let iconImage = NSImage.loadFrom(filePath)
        if (iconImage == nil) {
            print("Error: missing file \(iconImage)")
            exit(-1)
        }
        if (type == .Swift) {
            let destPath = outputAssetFolder! + "/icons"
            createFolder(destPath)
            for (key, value) in iOSAppIconSizes {
                let width = CGFloat(value)
                let height = CGFloat(value)
                let newImage = iconImage.resize(width, height: height)
                let destFile = destPath + "/" + key
                saveImage(newImage, file: destFile)
                debug("Image scale icon and copy \(filePath) -> \(destFile)")
            }
        }
        else if (type == .Java) {
            for (key, value) in AndroidIconSizes {
                let width = CGFloat(value)
                let height = CGFloat(value)
                let newImage = iconImage.resize(width, height: height)
                let destPath = outputAssetFolder! + "/res/drawable-" + key
                createFolder(destPath)
                let destFile = destPath + "/" + AndroidDefaultIconName
                saveImage(newImage, file: destFile)
                debug("Image scale icon and copy \(filePath) -> \(destFile)")
            }
        }
        else {
            print("Error: wrong type")
            exit(-1)
        }
    }
    
    private func copyAssets(files: [String], type: LangType, useRoot: Bool) -> Void {
        for file in files {
            let filePath = sourceAssetFolder! + "/" + file
            var destFile:String
            if (useRoot) {
                destFile = outputAssetFolder! + "/" + (file as NSString).lastPathComponent
            }
            else {
                destFile = outputAssetFolder! + "/" + file  // can include file/does/include/path
            }
            let destPath = (destFile as NSString).stringByDeletingLastPathComponent
            createFolder(destPath)
            
            var fileName = (file as NSString).lastPathComponent
            
            if (type == .Swift) {
                copyFile(filePath, dest: destFile)
            }
            else if (type == .Java) {
                let defaultLoc = destPath + "/assets/"
                createFolder(defaultLoc)
                fileName = defaultLoc + fileName
                copyFile(filePath, dest: fileName)
            }
            else {
                print("Error: wrong type")
                exit(-1)
            }
        }
    }

    private func copyFonts(files: [String], type: LangType, useRoot: Bool) -> Void {
        for file in files {
            let filePath = sourceAssetFolder! + "/" + file
            var destFile:String
            if (useRoot) {
                destFile = outputAssetFolder! + "/" + (file as NSString).lastPathComponent
            }
            else {
                destFile = outputAssetFolder! + "/" + file  // can include file/does/include/path
            }
            let destPath = (destFile as NSString).stringByDeletingLastPathComponent
            createFolder(destPath)
            
            var fileName = (file as NSString).lastPathComponent
            
            if (type == .Swift) {
                copyFile(filePath, dest: destFile)
            }
            else if (type == .Java) {
                let defaultLoc = destPath + "/assets/fonts/"
                createFolder(defaultLoc)
                fileName = defaultLoc + fileName
                copyFile(filePath, dest: fileName)
            }
            else {
                print("Error: wrong type")
                exit(-1)
            }
        }
    }
    
    private func consume(data: Dictionary <String, AnyObject>, type: LangType, outputFile: String) -> Void
    {
        // process first pass keys
        for (key, value) in data {
            if (key == keySchemaVersion) {
                let version = value as! Int
                if (version != SchemaVersion) {
                    print("Error: mismatched schema. Got \(version), expected \(SchemaVersion)")
                    exit(-1)
                }
            }
            else if (key == keyJava) {
                let options = value as! Dictionary<String, AnyObject>
                baseClass = options["base"] as! String
                package = options["package"] as! String
            }
            else if (key == keySwift) {
                let options = value as! Dictionary<String, AnyObject>
                baseClass = options["base"] as! String
            }
            else if (key == keyGlobalTint) {
                let color = parseColor(value as! String)
                globalTint = NSColor(calibratedRed: CGFloat(color!.r), green: CGFloat(color!.g), blue: CGFloat(color!.b), alpha: CGFloat(color!.a))
            }
        }
        
        // everything else is converted to Java, Swift classes
        var genString = ""
        for (key, value) in data {
            if (firstPassIgnoredKeys.contains(key) == false) {
                let constants = value as! Dictionary<String, AnyObject>
                let line = writeConstants(key, constants:constants, type: type)
                genString.appendContentsOf(line)
            }
        }
        for (key, value) in data {
            if (key == keyCopied) {
                copyAssets(value as! Array, type: type, useRoot: false)
            }
            else if (key == keyAppIcon) {
                copyAppIcon(value as! String, type: type)
            }
            else if (key == keyAndroidAppIcon) {
                if (type == .Java) {
                    copyAppIcon(value as! String, type: type)
                }
            }
            else if (key == keyIOSAppIcon) {
                if (type == .Swift) {
                    copyAppIcon(value as! String, type: type)
                }
            }
            else if (key == keyFonts) {
                copyFonts(value as! Array, type: type, useRoot: true)
            }
            else if (key == keyImages) {
                copyImages(value as! Array, type: type, useRoot: true)
            }
            else if (key == keyImagesScaled) {
                scaleAndCopyImages(value as! Array, type: type, useRoot: true)
            }
            else if (key == keyImagesIos) {
                if (type == .Swift) {
                    copyImages(value as! Array, type: type, useRoot: true)
                }
            }
            else if (key == keyImagesAndroid) {
                if (type == .Java) {
                    copyImages(value as! Array, type: type, useRoot: true)
                }
            }
        }
        if (genString.isEmpty == false) {
            var outputStr = "/* Generated with Sango, by Afero.io */\n\n"
            if (type == .Swift) {
                outputStr.appendContentsOf("import UIKit\n")
            }
            else if (type == .Java) {
                if (package.isEmpty) {
                    outputStr.appendContentsOf("package java.lang;\n")
                }
                else {
                    outputStr.appendContentsOf("package \(package);\n")
                }
            }
            if (baseClass.isEmpty == false) {
                genString = genString.stringByReplacingOccurrencesOfString("\n", withString: "\n\t")
                if (type == .Swift) {
                    outputStr.appendContentsOf("public struct \(baseClass) {")
                }
                else if (type == .Java) {
                    outputStr.appendContentsOf("public final class \(baseClass) {")
                }
                genString.appendContentsOf("\n}")
            }
            outputStr.appendContentsOf(genString + "\n")
            do {
                try outputStr.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Error: writing to \(outputFile)")
            }
        }
    }

    func createFolders(folders: [String]) -> Bool {
        for file in folders {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(file, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("Error: creating folder \(file)")
            }
        }
        return true
    }

    func createFolder(src: String) -> Bool {
        var ok = true
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(src, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("Error: creating folder \(src)")
            ok = false
        }
        
        return ok
    }

//    private func copyFiles(files: [String], type: LangType, useRoot: Bool) -> Void {
//        for file in files {
//            let filePath = sourceAssetFolder! + "/" + file
//            var destFile:String
//            if (useRoot) {
//                destFile = outputAssetFolder! + "/" + (file as NSString).lastPathComponent
//            }
//            else {
//                destFile = outputAssetFolder! + "/" + file
//            }
//            let destPath = (destFile as NSString).stringByDeletingLastPathComponent
//            createFolder(destPath)
//            if (copyFile(filePath, dest: destFile) == false) {
//                exit(-1)
//            }
//        }
//    }
    
    private func copyFile(src: String, dest: String, restrict: Bool = false) -> Bool {
        var destFile = dest
//        if (restrict) {
//            let fileName = (destFile as NSString).lastPathComponent
//            if (
//        }
        deleteFile(dest)
        var ok = true
        do {
            try NSFileManager.defaultManager().copyItemAtPath(src, toPath: destFile)
            debug("Copy \(src) -> \(dest)")
        }
        catch {
            print("Error: copying file \(src) to \(dest)")
            ok = false
        }

        return ok
    }
    
    private func deleteFile(src: String) -> Bool {
        var ok = true
        do {
            try NSFileManager.defaultManager().removeItemAtPath(src)
        }
        catch {
            ok = false
        }
        
        return ok
    }

    private let baseAssetTemplate = [keySchemaVersion :SchemaVersion,
                                    keyFonts: [],
                                    keyImages: [],
                                    keyImagesScaled: [],
                                    keyImagesIos: [],
                                    keyImagesAndroid: [],
                                    keyCopied: [],
                                    keyAppIcon: "",
                                    keyIOSAppIcon: "",
                                    keyAndroidAppIcon: ""
                                ]

    private func createAssetTemplate(base: String) -> Void {
        var temp = baseAssetTemplate as! Dictionary<String,AnyObject>
        temp[keyJava] = ["package" : "one.two", "base": base]
        temp[keySwift] = ["base": base]
        temp["Example"] = ["EXAMPLE_CONSTANT": 1]
        let jsonString = toJSON(temp)
        let outputFile = base + ".json"
        if (jsonString != nil) {
            do {
                try jsonString!.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)
                debug("JSON template created at \"\(outputFile)\"")
            }
            catch {
                print("Error: writing to \(outputFile)")
            }
        }
    }
    
    private let baseConfigTemplate = ["inputs": ["example/base.json","example/brand_1.json"],
                                     "input_assets": "../path/to/depot",
                                     "out_source": "path/to/app/source",
                                     "out_assets": "path/to/app/resources",
                                     "type": "swift or java"
    ]
    private func createConfigTemplate(file: String) -> Void {
        let jsonString = toJSON(baseConfigTemplate)
        if (jsonString != nil) {
            do {
                try jsonString!.writeToFile(file, atomically: true, encoding: NSUTF8StringEncoding)
                debug("JSON template created at \"\(file)\"")
            }
            catch {
                print("Error: writing to \(file)")
            }
        }
    }
    
    func start(args: [String]) -> Void {
        if (findOption(args, option: "-h") || args.count == 0) {
            usage()
            exit(0)
        }

        verbose = findOption(args, option: "-verbose")
        debug("Sango © 2016 Afero, Inc")
        
        if gitInstalled() {
            debug("git installed")
        }
        else {
            debug("git not installed")
        }

        let baseName = getOption(args, option: "-asset_template")
        if (baseName != nil) {
            createAssetTemplate(baseName!)
            exit(0)
        }

        let configTemplateFile = getOption(args, option: "-config_template")
        if (configTemplateFile != nil) {
            createConfigTemplate(configTemplateFile!)
            exit(0)
        }

        let gitCheckout = getOptions(args, option: "-git-checkout-tag")
        if (gitCheckout != nil) {
            let pwd = NSString(string: gitCheckout![0]).stringByStandardizingPath
            let tag = NSString(string: gitCheckout![1]).stringByStandardizingPath
            gitCheckoutAtTag(pwd, tag: tag)
            print(gitCheckout)
            exit(0)
        }
        
        let configFile = getOption(args, option: "-config")
        if (configFile != nil) {
            let result = fromJSONFile(configFile!)
            if (result != nil) {
                inputFile = result!["input"] as? String
                inputFiles = result!["inputs"] as? [String]
                sourceAssetFolder = result!["input_assets"] as? String
                outputClassFile = result!["out_source"] as? String
                outputAssetFolder = result!["out_assets"] as? String
                let type = result!["type"] as? String
                if (type == "java") {
                    compileType = .Java
                }
                else if (type == "swift") {
                    compileType = .Swift
                }
            }
        }
        
        if (compileType == .Unset) {
            if (findOption(args, option: "-java")) {
                compileType = .Java
            }
            else if (findOption(args, option: "-swift")) {
                compileType = .Swift
            }
            else {
                print("Error: need either -swift or -java")
                exit(-1)
            }
        }

        if (outputClassFile == nil) {
            outputClassFile = getOption(args, option: "-out_source")
        }
        if (outputClassFile != nil) {
            outputClassFile = NSString(string: outputClassFile!).stringByExpandingTildeInPath
        }
        else {
            print("Error: missing output file")
            exit(-1)
        }

        if (sourceAssetFolder == nil) {
            sourceAssetFolder = getOption(args, option: "-input_assets")
        }
        if (sourceAssetFolder != nil) {
            sourceAssetFolder = NSString(string: sourceAssetFolder!).stringByExpandingTildeInPath
        }
        else {
            print("Error: missing source asset folder")
            exit(-1)
        }
        
        if (outputAssetFolder == nil) {
            outputAssetFolder = getOption(args, option: "-out_assets")
        }
        if (outputAssetFolder != nil) {
            outputAssetFolder = NSString(string: outputAssetFolder!).stringByExpandingTildeInPath
        }
        else {
            print("Error: missing output asset folder")
            exit(-1)
        }

        var result:[String:AnyObject]? = nil
        if (inputFiles == nil) {
            inputFiles = getOptions(args, option: "-inputs")
        }
        if (inputFiles != nil) {
            for file in inputFiles! {
                let d = fromJSONFile(file)
                if (d != nil) {
                    if (result == nil) {
                        result = d
                    }
                    else {
                        result = result! + d!
                    }
                }
            }
        }

        if (inputFile == nil) {
            inputFile = getOption(args, option: "-input")
        }
        if (inputFile != nil) {
            result = fromJSONFile(inputFile!)
        }
        
        if (result != nil) {
            consume(result!, type: compileType, outputFile: outputClassFile!)
        }
        else {
            print("Error: missing input file")
            exit(-1)
        }
    }
}

// MARK: - Extras
private func toJSON(dictionary:Dictionary<String, AnyObject>) -> String? {
    do {
        let data: NSData
        data = try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
        let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        return jsonString.stringByReplacingOccurrencesOfString("\\/", withString: "/")
    }
    catch {
        return nil
    }
}

private func fromJSONFile(file:String) -> [String:AnyObject]? {
    var result:[String: AnyObject]?

    let location = NSString(string: file).stringByExpandingTildeInPath
    let fileContent = NSData(contentsOfFile: location)
    if (fileContent != nil) {
        result = fromJSON(fileContent!)
        if (result == nil) {
            print("Error: Can't parse \(location) as JSON")
        }
    }
    else {
        print("Error: can't find file \(location)")
    }
    return result
}

private func fromJSON(data:NSData) -> [String: AnyObject]? {
    var dict:[String: AnyObject]?
    do {
        dict = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject]
    }
    catch {
        print(error)
        dict = nil
    }
    return dict
}
