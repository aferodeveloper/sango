//
//  App.swift
//  Sango
//
//  Created by Steve Hales on 8/10/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

import Foundation

class App
{
    func usage() -> Void {
        print("Usage:")
        print("-f [file.json]")
        exit(0)
    }
    func start(options: [String]) -> Void {
        if findOption(args, option: "-h") {
            usage()
        }
        let file = getOption(args, option: "-f")
        if file.isEmpty == false {
            let location = NSString(string: file).stringByExpandingTildeInPath
            let fileContent = NSData(contentsOfFile: location)
            if (fileContent != nil) {
                let d = fromJSON(fileContent!)
                print(d)
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