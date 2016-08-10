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

class App
{
    func usage() -> Void {
        print("Usage:")
        print("-f [file.json]")
        exit(0)
    }

    func writeConstants(constants: Dictionary<String, AnyObject>) -> Void {
        print(constants)
    }
    
    func consume(data: Dictionary <String, AnyObject>) -> Void {
        // process defined keys, copied, fonts, schemaVersion, images, everything else is converted to Java, Swift
        for key in data.keys {
            if (key == "copied") {
                
            }
            else if (key == "fonts") {
                
            }
            else if (key == "schemaVersion") {
                
            }
            else if (key == "images") {
                
            }
            else {
                let constants = data[key] as! Dictionary<String, AnyObject>
                writeConstants(constants)
            }
        }
    }

    func start(options: [String]) -> Void {
        if findOption(args, option: "-h") {
            usage()
        }
        let file = getOption(args, option: "-f")
        if (file.isEmpty == false) {
            let location = NSString(string: file).stringByExpandingTildeInPath
            let fileContent = NSData(contentsOfFile: location)
            if (fileContent != nil) {
                let d = fromJSON(fileContent!)
                consume(d)
            }
            else {
                print("File \(file) not found")
            }
        }
        else {
            print("Missing file \(file)")
        }
    }
}