//
//  MVColor.swift
//  MVColor
//
//  Created by Michael on 14/6/14.
//  Copyright (c) 2014 Michael Vu. All rights reserved.
//

import Foundation
import UIKit

extension String{
    func sub(start: Int, length: Int) -> String {
        assert(start >= 0)
        assert(length >= 0)
        assert(start <= countElements(self) - 1)
        assert(start + length <= countElements(self))
        var a = self.substringFromIndex(start)
        var b = a.substringToIndex(length)
        return b
    }
}

extension UIColor {
    class func colorWithHex(hex:UInt32, alpha:Float = 1.0) -> UIColor {
        var red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, nAlpha:Float = alpha
        var hexString:String = String(format: "%03X", arguments: [UInt32(hex)])
        var length:Int = hexString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        switch length {
        case 3:
            red = Float(Float((hex >> 8) & 0xF)/15.0)
            green = Float(Float((hex >> 4) & 0xF)/15.0)
            blue = Float(Float(hex & 0xF)/15.0)
        case 4:
            nAlpha = Float(Float((hex >> 12) & 0xF)/15.0)
            red = Float(Float((hex >> 8) & 0xF)/15.0)
            green = Float(Float((hex >> 4) & 0xF)/15.0)
            blue = Float(Float(hex & 0xF)/15.0)
        case 6:
            red = Float(Float((hex >> 16) & 0xFF)/255.0)
            green = Float(Float((hex >> 8) & 0xFF)/255.0)
            blue = Float(Float(hex & 0xFF)/255.0)
        case 8:
            nAlpha = Float(Float((hex >> 24) & 0xFF)/255.0)
            red = Float(Float((hex >> 16) & 0xFF)/255.0)
            green = Float(Float((hex >> 8) & 0xFF)/255.0)
            blue = Float(Float(hex & 0xFF)/255.0)
        default:
            break
        }
        return UIColor(red: red, green: green, blue: blue, alpha: nAlpha)
    }
    
    class func colorWithHexString(string:String, alpha:Float = 1.0) -> UIColor {
        let colorString = string.stringByReplacingOccurrencesOfString("#", withString: "", options: nil, range: nil).uppercaseString
        var red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, nAlpha:Float = alpha
        var length:Int = colorString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        switch length {
        case 3:
            red   = self.colorHexComponent(colorString, start: 0, length: 1)
            green = self.colorHexComponent(colorString, start: 1, length: 1)
            blue  = self.colorHexComponent(colorString, start: 2, length: 1)
        case 4:
            nAlpha = self.colorHexComponent(colorString, start: 0, length: 1)
            red   = self.colorHexComponent(colorString, start: 1, length: 1)
            green = self.colorHexComponent(colorString, start: 2, length: 1)
            blue  = self.colorHexComponent(colorString, start: 3, length: 1)
        case 6:
            red   = self.colorHexComponent(colorString, start: 0, length: 2)
            green = self.colorHexComponent(colorString, start: 2, length: 2)
            blue  = self.colorHexComponent(colorString, start: 4, length: 2)
        case 8:
            nAlpha = self.colorHexComponent(colorString, start: 0, length: 2)
            red   = self.colorHexComponent(colorString, start: 2, length: 2)
            green = self.colorHexComponent(colorString, start: 4, length: 2)
            blue  = self.colorHexComponent(colorString, start: 6, length: 2)
        default:
            break
        }
        return UIColor(red: red, green: green, blue: blue, alpha: nAlpha)
    }
    
    class func colorHexComponent(string:String, start:Int, length:Int) -> Float {
        let subString = string.sub(start, length: length)
        let fullHex = length == 2 ? subString : String(format: "%@%@", arguments: [subString, subString])
        var hexComponent = CUnsignedInt()
        NSScanner.scannerWithString(fullHex).scanHexInt(&hexComponent)
        return Float(hexComponent)/255.0
    }
    
    class func randomColor(alpha:Float = 1.0) -> UIColor {
        var red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0
        var generated = false
        if generated == false {
            generated = true
            srandom(CUnsignedInt(time(nil)))
        }
        red = Float(random())/Float(RAND_MAX)
        green = Float(random())/Float(RAND_MAX)
        blue = Float(random())/Float(RAND_MAX)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func hex() -> UInt {
        var red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 0.0
        if (self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) == false) {
            self.getWhite(&red, alpha: &alpha)
            green = red
            blue = red
        }
        red = roundf(red * 255.0)
        green = roundf(green * 255.0)
        blue = roundf(blue * 255.0)
        alpha = roundf(alpha * 255.0);
        return UInt(UInt(alpha) << 24) | UInt(UInt(red) << 16) | UInt(UInt(green) << 8) | UInt(blue);
    }
    
    func hexString() -> String {
        return String(format: "0x%08x", arguments: [self.hex()])
    }
    
    func hexString(red:Float, green:Float, blue:Float, alpha:Float = 1.0) -> String {
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color.hexString()
    }
    
    func colorString() -> String {
        var hex = self.hex()
        if (hex & 0xFF000000) == 0xFF000000 {
            return String(format: "#%06x", arguments: [(hex & 0xFFFFFF)])
        }
        return String(format: "#%08x", arguments: [(hex & 0xFFFFFF)])
    }
}
