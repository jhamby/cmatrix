//
//  main.swift
//  MakeVT320Font
//
//  Created by Jake Hamby on 1/26/21.
//

import Foundation
import Cocoa

// let matrixFont = NSFont(name: "Matrix Code NFI", size: 24.0)!
let matrixFont = NSFont(name: "Courier", size: 24.0)!

let fontAttributes: [NSAttributedString.Key : Any] = [
    NSAttributedString.Key.font: matrixFont,
    NSAttributedString.Key.foregroundColor: NSColor.black
]

// redefine character set 'B'
var headerFile = "\"\\x1bP1;1;1;0;0;2{B"

// 94 characters that will look like the original effect
var matrixChars = "#$%&()*+/0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ{}~ｦｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ"

// counter for inserting newlines
var counter = 0

for ch in matrixChars {
    let glyph = String.init(ch)

    let size = glyph.size(withAttributes: fontAttributes)
    print("\(glyph) size is \(size)")

    let b = BitmapCanvas(15, 24, NSColor.white)

    // There may be a smarter way to center the glyphs vertically
    var yOffset = 2.0

    // These punctuation marks aren't centered unless we move them up
    if ch == "{" || ch == "}" || ch == "(" || ch == ")" {
        yOffset = -1.0
    }

    // Use the glyph size to center horizontally
    b.text(glyph, NSPoint(x: 7.5 - (size.width / 2), y: yOffset), font: matrixFont)

    // Print to stdout for inspection
    for row in 0 ..< Int(b.height) / 2 {
        for col in 0 ..< Int(b.width) {
            if (b[col, row * 2].color.brightnessComponent + b[col, row * 2 + 1].color.brightnessComponent) < 2.0 {
                print("*", terminator: "")
            } else {
                print(" ", terminator: "")
            }
        }
        print("")
    }

    // Remember the last sixel to escape potential trigraphs ("??*")
    var lastSixelChar = ""

    // add top six rows as sixels
    for col in 0 ..< 15 {
        var sixel = 0
        for row in 0 ..< 6 {
            if (b[col, row * 2].color.brightnessComponent + b[col, row * 2 + 1].color.brightnessComponent) < 2.0 {
                sixel |= (1 << row)
            }
        }
        let sixelChar = String.init(Unicode.Scalar(63 + sixel)!)

        if (lastSixelChar == "?" && sixelChar == "?") {
            headerFile.append("\\")     // this is not a trigraph!
        }

        headerFile.append(sixelChar)

        // backslash needs to be escaped
        if sixelChar == "\\" {
            headerFile.append(sixelChar)
        }
        lastSixelChar = sixelChar
    }

    headerFile.append("/")
    lastSixelChar = ""

    // add bottom six rows as sixels
    for col in 0 ..< 15 {
        var sixel = 0
        for row in 6 ..< 12 {
            if (b[col, row * 2].color.brightnessComponent + b[col, row * 2 + 1].color.brightnessComponent) < 2.0 {
                sixel |= (1 << (row - 6))
            }
        }
        let sixelChar = String.init(Unicode.Scalar(63 + sixel)!)

        if (lastSixelChar == "?" && sixelChar == "?") {
            headerFile.append("\\")     // this is not a trigraph!
        }

        headerFile.append(sixelChar)

        // backslash needs to be escaped
        if sixelChar == "\\" {
            headerFile.append(sixelChar)
        }
        lastSixelChar = sixelChar
    }

    headerFile.append(";")

    // add newlines every 2 chars
    if (counter % 2 == 1) {
        headerFile.append("\"\n\"")
    }
    counter += 1
}

print("\(counter) glyphs defined:")

headerFile.append("\\x1b\\\\\"")
print(headerFile)
