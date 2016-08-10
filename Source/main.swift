//
//  main.swift
//  Sango
//
//  Created by Steve Hales on 8/9/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

// https://www.raywenderlich.com/128039/command-line-programs-os-x-tutorial

import Foundation


func findOption(args:[String], option:String) -> Bool {
    var found = false
    for argument in args {
        if argument == option {
            found = true
        }
    }
    return found
}

func getOption(args:[String], option:String) -> String {
    var found:String = ""
    for argument in args {
        if argument == option {
            var indx = args.indexOf(argument)
            if (indx != nil) {
                indx = indx! + 1
                if indx < args.count {
                    found = args[indx!]
                }
            }
            break
        }
    }
    return found
}

func fromJSON(data:NSData) -> Dictionary<String, AnyObject>
{
    var dict:Dictionary<String, AnyObject>!
    do {
        dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! Dictionary<String, AnyObject>
    }
    catch {
        print(error)
    }
    return dict
}

print("Hello, World!")
var args = Process.arguments
args.removeFirst()

let app = App()
app.start(args)



