//
//  YLPaintShop.swift
//  YLPaintShopDemo
//
//  Created by Alexander Li on 2016-11-19.
//  Copyright © 2016 Yuhui Li. All rights reserved.
//

import UIKit

class YLPaintShop: NSObject {
    
}

private extension UIImage {
    
    static func generateRandomPoints(row rowInternal: Int, col: Int, width: Int, height: Int, radius: Int) -> (Int, Int) {
        var newRow = rowInternal + Int(arc4random_uniform(UInt32(radius*2))) - radius
        
        if newRow >= height {
            newRow = height-1
        } else if newRow < 0 {
            newRow = 0
        }
        
        var newCol = col + Int(arc4random_uniform(UInt32(radius*2))) - radius
        
        if newCol >= width {
            newCol = width-1
        } else if newCol < 0 {
            newCol = 0
        }
        
        return (newRow, newCol)
    }
    
    private func createContext(inImage: CGImageRef) -> CGContext {
        let bitmapBytes = 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        
        let width = CGImageGetWidth(inImage)
        let height = CGImageGetHeight(inImage)
        let bitmapBytesPerRow = width * bitmapBytes
        let bitmapByteCount = bitmapBytesPerRow * height
        
        // A pointer to the destination in memory where the drawing is to be rendered. The size of this memory block should be at least (bytesPerRow*height) bytes.
        let bitmapData = malloc(bitmapByteCount)
        
        let context = CGBitmapContextCreate(bitmapData, width, height, bitsPerComponent, bitmapBytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        return context!
    }
}

extension UIImage {
    func scatter(radius: Int) -> UIImage? {
        
        let inImage:CGImageRef = self.CGImage!
        let context = self.createContext(inImage)
        
        let width = CGImageGetWidth(inImage)
        let height = CGImageGetHeight(inImage)
        let total = width*height
        
        let rect = CGRect(x:0, y:0, width:width, height:height)
        
        CGContextClearRect(context, rect)
        
        CGContextDrawImage(context, rect, inImage)
        
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        
        for i in 0...total-1 {
            
            // Find out which row which column currently is
            let row:Int = i/width
            let col:Int = i%width
            let offset = 4 * i
            
            // Randomly select a point to get color from
            let (srcRow, srcCol) = UIImage.generateRandomPoints(row: row, col: col, width: width, height: height, radius: radius)
            let srcOffset = 4 * ((width * srcRow) + srcCol)
            
            dataType[offset] = dataType[srcOffset]
            dataType[offset+1] = dataType[srcOffset+1]
            dataType[offset+2] = dataType[srcOffset+2]
            dataType[offset+3] = dataType[srcOffset+3]
            
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapBytesPerRow = width * 4
        
        let finalContext = CGBitmapContextCreate(data, width, height, 8, bitmapBytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let imageRef = CGBitmapContextCreateImage(finalContext)
        
        return UIImage(CGImage: imageRef!)
    }
}