//
//  main.swift
//  Sango
//
//  Created by Steve Hales on 8/9/16.
//  Copyright © 2016 Afero, Inc. All rights reserved.
//

// https://www.raywenderlich.com/128039/command-line-programs-os-x-tutorial

import Foundation
import CoreFoundation

private var gitPath = "/usr/bin/git"

private func shell(arguments: [String]) -> (output: String, status: Int32)
{
    let task = NSTask()
    task.launchPath = "/bin/bash"
    var arg = ""
    for (index, value) in arguments.enumerate() {
        arg = arg.stringByAppendingString(value)
        if (index < (arguments.count - 1)) {
            arg = arg.stringByAppendingString(" && ")
        }
    }
    task.arguments = ["-c", arg]
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String

    return (output: output, status: task.terminationStatus)
}

func gitInstalled() -> Bool
{
    let output = shell(["which git"])
    return (output.status == 0)
}

func gitInstalledPath() -> String {
    let output = shell(["which git"])
    
    return output.output.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
}

func gitCheckoutAtTag(path: String, tag: String) -> Bool
{
    let output = shell(["cd \(path)",
        "\(gitPath) checkout tags/\(tag)"])
    print(output)
    return (output.status == 0)
}

func gitDropChanges(path: String) -> Bool
{
    let output = shell(["cd \(path)",
        "\(gitPath) stash -u", "\(gitPath) stash drop"])
    return (output.status == 0)
}

func gitCurrentBranch(path: String) -> String
{
    let output = shell(["cd \(path)",
        "\(gitPath) rev-parse --abbrev-ref HEAD"])
    return output.output.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
}

func gitSetBranch(path: String, branch: String) -> Bool
{
    gitDropChanges(path)
    let output = shell(["cd \(path)",
        "\(gitPath) checkout /\(branch)"])
    print(output)
    return (output.status == 0)
}

func findOption(args:[String], option:String) -> Bool
{
    var found = false
    for argument in args {
        if (argument == option) {
            found = true
        }
    }
    return found
}

func getOption(args:[String], option:String) -> String?
{
    var found:String? = nil
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

func getOptions(args:[String], option:String) -> [String]?
{
    var found:[String]? = nil
    for argument in args {
        if (argument == option) {
            var indx = args.indexOf(argument)
            if (indx != nil) {
                indx = indx! + 1
                found = []
                for dex in indx!...(args.count - 1) {
                    let str = args[dex]
                    if (str.hasPrefix("-") == false) {
                        found?.append(str)
                    }
                    else {
                        break
                    }
                }
            }
            break
        }
    }
    return found
}

// MARK: main

private let env = NSProcessInfo.processInfo().environment

if gitInstalled() {
    gitPath = gitInstalledPath()
}

private var args = Process.arguments
args.removeFirst()

App().start(args)
exit(0)


// eof



