//
//  App.swift
//  Sango
//
//  Created by Steve Hales on 8/10/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

import Foundation

// See:
// https://docs.google.com/document/d/1X-pHtwzB6Qbkh0uuhmqtG98o2_Dv_okDUim6Ohxhd8U/edit
// for more details


private let SchemaVersion = 1

private let keySchemaVersion = "schemaVersion"
private let keyFonts = "fonts"
private let keyImages = "images"
private let keyImagesIos = "imagesIos"
private let keyImagesAndroid = "imagesAndroid"
private let keyImagesTinted = "imagesTinted"
private let keyCopied = "copied"
private let keyJava = "java"
private let keySwift = "swift"
private let firstPassIgnoredKeys = [keyCopied, keyFonts, keySchemaVersion, keyImages,
                                    keyImagesIos, keyImagesAndroid, keyImagesTinted,
                                    keyJava, keySwift]

class App
{
    private var package:String = ""
    private var baseClass:String = ""

    func usage() -> Void {
        print("Usage:")
        print("     -i [file.json]")
        print("     -o output path")
        print("     -a asset folder")
        print("     -java")
        print("     -swift")
    }

    private enum LangType {
        case Java
        case Swift
    }

    private func writeConstants(name: String, constants: Dictionary<String, AnyObject>, type: LangType, outputFile: String) -> String {
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
    
    private func consume(data: Dictionary <String, AnyObject>, type: LangType, outputFile: String) -> Void {
        deleteFile(outputFile)

        // process first pass keys
        for (key, value) in data {
            if (key == keyCopied) {
                
            }
            else if (key == keyFonts) {
                
            }
            else if (key == keySchemaVersion) {
                let version = value as! Int
                if (version != SchemaVersion) {
                    print("Error: mismatched SchemaVersion")
                    exit(-1)
                }
            }
            else if (key == keyImages) {
                
            }
            else if (key == keyImagesIos) {
                
            }
            else if (key == keyImagesAndroid) {
                
            }
            else if (key == keyImagesTinted) {
                
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
                let line = writeConstants(key, constants:constants, type: type, outputFile: outputFile)
                genString.appendContentsOf(line)
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

    private func copyFile(src: String, dest: String) -> Bool {
        var ok = true
        do {
            try NSFileManager.defaultManager().copyItemAtPath(src, toPath: dest)
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

        let inputFile = getOption(args, option: "-i")
        if (inputFile != nil) {
            let location = NSString(string: inputFile!).stringByExpandingTildeInPath
            let fileContent = NSData(contentsOfFile: location)
            if (fileContent != nil) {
                let result:Dictionary<String, AnyObject> = Dictionary.fromJSON(fileContent!)
                consume(result, type: type, outputFile: outputFile!)
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

private extension Dictionary
{
    static func fromJSON(data:NSData) -> Dictionary {
        var dict:Dictionary!
        do {
            dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Dictionary
        }
        catch {
            print(error)
        }
        return dict
    }
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
