//
//  App.swift
//  Sango
//
//  Created by Steve Hales on 8/10/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

import Foundation

private let SchemaVersion = 1

// See:
// https://docs.google.com/document/d/1X-pHtwzB6Qbkh0uuhmqtG98o2_Dv_okDUim6Ohxhd8U/edit
// for more details

class App
{
    func usage() -> Void {
        print("Usage:")
        print("-f [file.json]")
        print("-o outputFile")
        print("-java")
        print("-swift")
        exit(0)
    }

    private enum LangType {
        case Java
        case Swift
    }

    private func writeConstants(name: String, constants: Dictionary<String, AnyObject>, type: LangType, outputFile: String) -> Void {
        var outputString = ""
        if (type == .Swift) {
            outputString.appendContentsOf("/* machine generated */\n\n")
            outputString.appendContentsOf("struct ")
            outputString.appendContentsOf(name + " {\n")
            for (key, value) in constants {
                let line = "\tstatic let " + key + " = "
                outputString.appendContentsOf(line)

                var useQuotes = false
                if (value is String) {
                    useQuotes = true
                    let strValue:String = value as!String
                    if (strValue.isNumber() == true) {
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
            outputString.appendContentsOf("}\n")
        }
        else if (type == .Java) {
            outputString.appendContentsOf("/* machine generated */\n\n")
            outputString.appendContentsOf("public final class ")
            outputString.appendContentsOf(name + " {\n")
            outputString.appendContentsOf("\tprivate \(name)() {\n\t\t// restrict\n\t}\n")

            for (key, value) in constants {
                var type = "int"
                var useQuotes = false
                if (value is String) {
                    useQuotes = true
                    let strValue:String = value as!String
                    if (strValue.isNumber() == true) {
                        useQuotes = false
                    }
                    else {
                        type = "String"
                    }
                }
                let line = "\tpublic static final " + type + " " + key + " = "
                outputString.appendContentsOf(line)
                if (useQuotes) {
                    let line = "\"" + String(value) + "\";"
                    outputString.appendContentsOf(line);
                }
                else {
                    let line = String(value) + ";"
                    outputString.appendContentsOf(line);
                }
                outputString.appendContentsOf("\n")
            }
            outputString.appendContentsOf("}\n")
        }
        else {
            print("Error: invalide output type")
            exit(-1)
        }
        if (outputString.isEmpty == false) {
            do {
                try outputString.writeToFile(outputFile, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Error: writing to \(outputFile)")
            }
        }
    }
    
    private func consume(data: Dictionary <String, AnyObject>, type: LangType, outputFile: String) -> Void {
        // process defined keys, copied, fonts, schemaVersion, images, everything else is converted to Java, Swift
        for (key, value) in data {
            if (key == "copied") {
                
            }
            else if (key == "fonts") {
                
            }
            else if (key == "schemaVersion") {
                let version = value as! Int
                if (version != SchemaVersion) {
                    print("Error: mismatched SchemaVersion")
                    exit(-1)
                }
            }
            else if (key == "images") {
                
            }
            else {
                let constants = value as! Dictionary<String, AnyObject>
                writeConstants(key, constants:constants, type: type, outputFile: outputFile)
            }
        }
    }

    func start(options: [String]) -> Void {
        if findOption(args, option: "-h") {
            usage()
        }

        var type:LangType = .Swift
        if (findOption(args, option: "-java")) {
            type = .Java
        }

        let inputFile = getOption(args, option: "-f")
        var outputFile = getOption(args, option: "-o")
        if (outputFile == nil) {
            print("Error: missing output file")
            exit(-1)
        }
        outputFile = NSString(string: outputFile!).stringByExpandingTildeInPath
        if (inputFile != nil) {
            let location = NSString(string: inputFile!).stringByExpandingTildeInPath
            let fileContent = NSData(contentsOfFile: location)
            if (fileContent != nil) {
                let d = fromJSON(fileContent!)
                consume(d, type: type, outputFile: outputFile!)
            }
            else {
                print("Error: file \(inputFile) not found")
            }
        }
        else {
            print("Error: missing input file")
        }
    }
}

public extension String
{
    func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        return !self.isEmpty && self.rangeOfCharacterFromSet(numberCharacters) == nil
    }
}
