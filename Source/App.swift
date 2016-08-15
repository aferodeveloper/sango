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
private let keyCopied = "copied"
private let keyJava = "java"
private let keySwift = "swift"
private let firstPassIgnoredKeys = [keyCopied, keyFonts, keySchemaVersion, keyImages,
                                    keyImagesScaled, keyImagesIos, keyImagesAndroid,
                                    keyImagesTinted, keyJava, keySwift]

class App
{
    private var package:String = ""
    private var baseClass:String = ""
    private var sourceAssetFolder:String? = nil
    private var outputAssetFolder:String? = nil

    func usage() -> Void {
        print("Usage:")
        print("     -i      file.json")
        print("     -o      source.java|swift")
        print("     -java   write java source")
        print("     -swift  write swift source")
        print("     -a      asset source folder (read)")
        print("     -oa     asset root folder (write), typically iOS Resource, or Android app/src/main")
    }

    private enum LangType {
        case Java
        case Swift
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
                    
                    let parts = strValue.componentsSeparatedByString(",")
                    if (parts.count == 3 || parts.count == 4) {
                        // color
                        let red:Double = Double(parts[0])! / 255.0
                        let green:Double = Double(parts[1])! / 255.0
                        let blue:Double = Double(parts[2])! / 255.0
                        var alpha:Double = 1
                        if (parts.count == 4) {
                            alpha = Double(parts[3])! / 255.0
                        }
                        let line = "UIColor(red: \(red.roundTo3f), green: \(green.roundTo3f), blue: \(blue.roundTo3f), alpha: \(alpha.roundTo3f))"
                        outputString.appendContentsOf(line + "\t// ")
                        useQuotes = false
                    }
                    else if (strValue.hasPrefix("#")) {
                        var hexStr = strValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
                        hexStr = hexStr.substringFromIndex(hexStr.startIndex.advancedBy(1))
                        
                        var rgbValue:UInt32 = 0
                        NSScanner(string: hexStr).scanHexInt(&rgbValue)
                        var red:Double = 1
                        var green:Double = 1
                        var blue:Double = 1
                        var alpha:Double = 1

                        if (hexStr.characters.count < 6) {
                            print("Error: not enough characters for hex color definition. Needs 6.")
                            exit(-1)
                        }

                        if (hexStr.characters.count >= 6) {
                            red = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
                            green = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
                            blue = Double(rgbValue & 0x000000FF) / 255.0
                        }
                        if (hexStr.characters.count == 8) {
                            alpha = Double((rgbValue & 0xFF000000) >> 24) / 255.0
                        }
                        let line = "UIColor(red: \(red.roundTo3f), green: \(green.roundTo3f), blue: \(blue.roundTo3f), alpha: \(alpha.roundTo3f))"
                        outputString.appendContentsOf(line + "\t// ")
                        useQuotes = false
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
                    }
                }
                let parts = strValue.componentsSeparatedByString(",")
                if (parts.count == 3 || parts.count == 4) {
                    // color
                    let red:Int = Int(parts[0])!
                    let green:Int = Int(parts[1])!
                    let blue:Int = Int(parts[2])!
                    var alpha:Int = 1
                    type = "int"
                    if (parts.count == 4) {
                        alpha = Int(parts[3])!
                        parmSize = "L"
                        type = "long"
                    }
                    let line = String((alpha << 24) | (red << 16) | (green << 8) | blue)
                    strValue = String(line + parmSize + ";\t// \(value)")
                    useQuotes = false
                    endQuote = ""
                }
                else if (strValue.hasPrefix("#")) {
                    var hexStr = strValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
                    hexStr = hexStr.substringFromIndex(hexStr.startIndex.advancedBy(1))
                    
                    var rgbValue:UInt32 = 0
                    NSScanner(string: hexStr).scanHexInt(&rgbValue)
                    var red:Int = 1
                    var green:Int = 1
                    var blue:Int = 1
                    var alpha:Int = 1
                    
                    if (hexStr.characters.count < 6) {
                        print("Error: not enough characters for hex color definition. Needs 6.")
                        exit(-1)
                    }
                    
                    type = "int"
                    if (hexStr.characters.count >= 6) {
                        red = Int((rgbValue & 0x00FF0000) >> 16)
                        green = Int((rgbValue & 0x0000FF00) >> 8)
                        blue = Int(rgbValue & 0x000000FF)
                    }
                    if (hexStr.characters.count == 8) {
                        alpha = Int((rgbValue & 0xFF000000) >> 24)
                        type = "long"
                        parmSize = "L"
                    }
                    let line = String((alpha << 24) | (red << 16) | (green << 8) | blue)
                    strValue = String(line + parmSize + ";\t// \(value)")
                    useQuotes = false
                    endQuote = ""
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
    
    private func scaleAndCopyImages(files: Array<String>, type: LangType, useRoot: Bool) -> Void {
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
            
            if (type == .Swift) {
                // Ok, we're going to create the @3, @2, and normal size from the given assumed largest image
                let image3 = NSImage.loadFrom(filePath) // @3
                let image2 = image3.scale(66.67)        // @2
                let image = image3.scale(33.34)         // @1
                var file = destPath + "/" + fileName + "@3x.png"
                if (image3.saveTo(file) == false) {
                    exit(-1)
                }
                print("Image scale and copy \(filePath) -> \(file)")
                file = destPath + "/" + fileName + "@2x.png"
                if (image2.saveTo(file) == false) {
                    exit(-1)
                }
                print("Image scale and copy \(filePath) -> \(file)")
                file = destPath + "/" + fileName + ".png"
                if (image.saveTo(destPath + "/" + fileName + ".png") == false) {
                    exit(-1)
                }
                print("Image scale and copy \(filePath) -> \(file)")
            }
            else if (type == .Java) {
                let mdpi = destPath + "/res/drawable-mdpi/"
                let hdpi = destPath + "/res/drawable-hdpi/"
                let xhdpi = destPath + "/res/drawable-xhdpi/"
                let xxhdpi = destPath + "/res/drawable-xxhdpi/"
                createFolders([mdpi, hdpi, xhdpi, xxhdpi])
                fileName = fileName + ".png"
                let image4 = NSImage.loadFrom(filePath) // 3x
                let image3 = image4.scale(66.67)        // 2x
                let image2 = image4.scale(50)           // 1.5x
                let image = image4.scale(33.34)         // 1x
                var file = xxhdpi + fileName
                if (image4.saveTo(file) == false) {
                    exit(-1)
                }
                print("Image scale and copy \(filePath) -> \(file)")
                file = xhdpi + fileName
                if (image3.saveTo(xhdpi + fileName) == false) {
                    exit(-1)
                }
                print("Image scale and copy \(filePath) -> \(file)")
                file = hdpi + fileName
                if (image2.saveTo(hdpi + fileName) == false) {
                    exit(-1)
                }
                print("Image scale and copy \(filePath) -> \(file)")
                file = mdpi + fileName
                if (image.saveTo(mdpi + fileName) == false) {
                    exit(-1)
                }
                print("Image scale and copy \(filePath) -> \(file)")
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
    private func copyImages(files: Array<String>, type: LangType, useRoot: Bool) -> Void {
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

            if (type == .Swift) {
                copyFile(filePath, dest: destFile)
            }
            else if (type == .Java) {
                let result = NSImage.getScaleFrom(fileName)
                let drawable = iOStoAndroid[result.scale]!
                let defaultLoc = destPath + "/res/drawable-" + drawable + "/"
                createFolder(defaultLoc)
                fileName = result.file + ".png"
                copyFile(filePath, dest: defaultLoc + fileName)
            }
            else {
                print("Error: wrong type")
                exit(-1)
            }
        }
    }
    
    private func copyFonts(files: Array<String>, type: LangType, useRoot: Bool) -> Void {
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
    
    private func consume(data: Dictionary <String, AnyObject>, type: LangType, outputFile: String) -> Void {
        deleteFile(outputFile)

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
                copyFiles(value as! Array, type: type, useRoot: false)
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
            else if (key == keyImagesTinted) {
//                let constants = value as! Dictionary<String, AnyObject>
//                print("image tinted \(constants)")
            }
        }
        if (genString.isEmpty == false) {
            var outputStr = "/* machine generated */\n\n"
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

    func createFolders(folders: Array<String>) -> Bool {
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

    private func copyFiles(files: Array<String>, type: LangType, useRoot: Bool) -> Void {
        // our copy function is special
        
        for file in files {
            let filePath = sourceAssetFolder! + "/" + file
            var destFile:String
            if (useRoot) {
                destFile = outputAssetFolder! + "/" + (file as NSString).lastPathComponent
            }
            else {
                destFile = outputAssetFolder! + "/" + file
            }
            let destPath = (destFile as NSString).stringByDeletingLastPathComponent
            createFolder(destPath)
            if (copyFile(filePath, dest: destFile) == false) {
                exit(-1)
            }
        }
    }
    
    private func copyFile(src: String, dest: String) -> Bool {
        deleteFile(dest)
        var ok = true
        do {
            try NSFileManager.defaultManager().copyItemAtPath(src, toPath: dest)
            print("Copy \(src) -> \(dest)")
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
    
    func start(args: [String]) -> Void {
        if (findOption(args, option: "-h") || args.count == 0) {
            usage()
            exit(0)
        }

        var type:LangType = .Swift
        if (findOption(args, option: "-java")) {
            type = .Java
        }
        else if (findOption(args, option: "-swift") == false) {
            print("Error: need either -swift or -java")
            exit(-1)
        }

        var outputFile = getOption(args, option: "-o")
        outputFile = NSString(string: outputFile!).stringByExpandingTildeInPath

        sourceAssetFolder = getOption(args, option: "-a")
        if (sourceAssetFolder != nil) {
            sourceAssetFolder = NSString(string: sourceAssetFolder!).stringByExpandingTildeInPath
        }
        else {
            print("Error: missing source asset folder")
            exit(-1)
        }
        
        outputAssetFolder = getOption(args, option: "-ao")
        if (outputAssetFolder != nil) {
            outputAssetFolder = NSString(string: outputAssetFolder!).stringByExpandingTildeInPath
        }
        else {
            print("Error: missing output asset folder")
            exit(-1)
        }

        let inputFile = getOption(args, option: "-i")
        if (inputFile != nil) {
            let location = NSString(string: inputFile!).stringByExpandingTildeInPath
            let fileContent = NSData(contentsOfFile: location)
            if (fileContent != nil) {
                if let result = fromJSON(fileContent!) {
                    consume(result, type: type, outputFile: outputFile!)
                }
                else {
                    print("Error: Can't parse \(location) as JSON")
                    exit(-1)
                }
            }
            else {
                print("Error: file \(inputFile) not found")
                exit(-1)
            }
        }
        else {
            print("Error: missing input file")
            exit(-1)
        }
    }
}

// MARK: - Extras

private extension NSImage
{
    /**
     *  Given a file path, load and return an NSImage
     */
    static func loadFrom(file: String) -> NSImage! {
        let newImage = NSImage(contentsOfFile: file)
        return newImage
    }

    /**
     *  Given a file, image.png, image@2.png, image@3.png, return the scaling factor
     *  1, 2, 3
     */
    static func getScaleFrom(file :String) -> (scale: Int, file: String) {
        var scale = 1
        var fileName = (file as NSString).lastPathComponent
        fileName = (fileName as NSString).stringByDeletingPathExtension
        if (fileName.hasSuffix("@2x")) {
            scale = 2
            fileName = fileName.stringByReplacingOccurrencesOfString("@2x", withString: "")
        }
        else if (fileName.hasSuffix("@3x")) {
            scale = 3
            fileName = fileName.stringByReplacingOccurrencesOfString("@3x", withString: "")
        }
        return (scale: scale, file: fileName)
    }

    func saveTo(file: String) -> Bool {
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                      pixelsWide: Int(self.size.width),
                                      pixelsHigh: Int(self.size.height),
                                      bitsPerSample: 8,
                                      samplesPerPixel: 4,
                                      hasAlpha: true,
                                      isPlanar: false,
                                      colorSpaceName: NSDeviceRGBColorSpace,
                                      bytesPerRow: 0,
                                      bitsPerPixel: 0)!
        bitmap.size = self.size
        
        NSGraphicsContext.saveGraphicsState()
        
        NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: bitmap))
        self.drawAtPoint(CGPoint.zero,
                         fromRect: NSRect.zero,
                         operation: NSCompositingOperation.CompositeSourceOver,
                         fraction: 1.0)

        NSGraphicsContext.restoreGraphicsState()
        
        var ok = false
        let imageData = bitmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType,
                                                          properties: [NSImageCompressionFactor: 1.0])
        if (imageData != nil) {
            ok = imageData!.writeToFile((file as NSString).stringByStandardizingPath, atomically: true)
        }
        if (ok == false) {
            print("Error: Can't save image to \(file)")
        }
        return ok
    }
    
    func scale(percent: CGFloat) -> NSImage {
        var newR = CGRectMake(0, 0, self.size.width, self.size.height)
        let Width = CGRectGetWidth(newR)
        let Height = CGRectGetHeight(newR)
        let newWidth = (Width * percent) / 100.0
        let newHeight = (Height * percent) / 100.0
        
        let ratioOld = Width / Height
        let ratioNew = newWidth / newHeight
        
        if (ratioOld > ratioNew) {
            newR.size.width = newWidth                         // width of mapped rect
            newR.size.height = newR.size.width / ratioOld      // height of mapped rect
            newR.origin.x = 0                                  // x-coord of mapped rect
            newR.origin.y = (newHeight - newR.size.height) / 2 // y-coord of centered mapped rect
        }
        else {
            newR.size.height = newHeight
            newR.size.width = newR.size.height * ratioOld
            newR.origin.y = 0
            newR.origin.x = (newWidth - newR.size.width) / 2
        }
        return resize(newR.width, height: newR.height)
    }

    func resize(width: CGFloat, height: CGFloat) -> NSImage {
        let destSize = NSMakeSize(width, height)
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.drawInRect(NSMakeRect(0, 0, destSize.width, destSize.height),
                        fromRect: NSMakeRect(0, 0, self.size.width, self.size.height),
                        operation: NSCompositingOperation.CompositeSourceOver,
                        fraction: 1.0)
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.TIFFRepresentation!)!
    }
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

private extension Double
{
    var roundTo3f: Double {return Double(round(1000 * self) / 1000) }
    var roundTo2f: Double {return Double(round(100 * self) / 100) }
}

private extension String
{
    func snakeCaseToCamelCase() -> String {
        let items = self.componentsSeparatedByString("_")
        var camelCase = ""
        items.enumerate().forEach {
            camelCase += $1.capitalizedString
        }
        return camelCase
    }

    func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return !self.isEmpty && self.rangeOfCharacterFromSet(numberCharacters) == nil
    }
}
