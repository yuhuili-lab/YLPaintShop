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
    
    static func generateRandomPoints(row row: Int, col: Int, width: Int, height: Int, radius: Int) -> (Int, Int) {
        var newRow = row + Int(arc4random_uniform(UInt32(radius*2))) - radius
        
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
    
    func createContext(_ inImage: CGImage) -> CGContext {
        let bitmapBytes = 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerComponent = 8
        
        let width = inImage.width
        let height = inImage.height
        let bitmapBytesPerRow = width * bitmapBytes
        let bitmapByteCount = bitmapBytesPerRow * height
        
        // A pointer to the destination in memory where the drawing is to be rendered. The size of this memory block should be at least (bytesPerRow*height) bytes.
        let bitmapData = malloc(bitmapByteCount)
        
        let context = CGContext(data: bitmapData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        return context!
    }
}

extension UIImage {
    func scatter(_ radius: Int) -> UIImage? {
        
        let inImage:CGImage = self.cgImage!
        let context = self.createContext(inImage)
        
        let width = inImage.width
        let height = inImage.height
        let total = width*height
        
        let rect = CGRect(x:0, y:0, width:width, height:height)
        
        context.clear(rect)
        
        context.draw(inImage, in: rect)
        
        let data = context.data
        let dataType = UnsafeMutableRawPointer(data)!.assumingMemoryBound(to: UInt8.self)
        
        
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
        
        let finalContext = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let imageRef = finalContext?.makeImage()
        
        return UIImage(cgImage: imageRef!)
    }
    
    func paintEdge(_ threshold: Int) -> UIImage? {
        
        let inImage:CGImage = self.cgImage!
        let context = self.createContext(inImage)
        
        let width = inImage.width
        let height = inImage.height
        let total = width*height
        
        let rect = CGRect(x:0, y:0, width:width, height:height)
        
        context.clear(rect)
        
        context.draw(inImage, in: rect)
        
        let data = context.data
        let dataType = UnsafeMutableRawPointer(data)!.assumingMemoryBound(to: UInt8.self)
        
        
        for i in 0...total-1 {
            // Find out which row which column currently is
            let row:Int = i/width
            let col:Int = i%width
            let offset = 4 * i
            
            var isEdge = false;
            
            // Check all 8 pixels around it
            for j in -1...1 {
                var shouldExit = false
                
                for k in -1...1 {
                    let newRow = row+j
                    let newCol = col+k
                    
                    if newRow<0 || newRow>=height {
                        continue
                    } else if newCol<0 || newCol>=width {
                        continue
                    }
                    
                    let newOffset = 4 * ((width * newRow) + newCol)
                    
                    // Check if rgb diff is > threshold
                    
                    // First value (newOffset+0 and offset+0) is alpha, ignored
                    if (Float(dataType[newOffset+1]) - Float(dataType[offset+1])) > Float(threshold) ||
                        (Float(dataType[newOffset+2]) - Float(dataType[offset+2])) > Float(threshold) ||
                        (Float(dataType[newOffset+3]) - Float(dataType[offset+3])) > Float(threshold){
                        isEdge = true
                        shouldExit = true
                        break
                    }
                    
                }
                if shouldExit {
                    break
                }
            }
            
            if isEdge {
                // Paint black
                dataType[offset] = 255
                dataType[offset+1] = 0
                dataType[offset+2] = 0
                dataType[offset+3] = 0
            } else {
                // Paint white
                dataType[offset] = 255
                dataType[offset+1] = 255
                dataType[offset+2] = 255
                dataType[offset+3] = 255
            }
            
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapBytesPerRow = width * 4
        
        let finalContext = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let imageRef = finalContext?.makeImage()
        
        return UIImage(cgImage: imageRef!)
    }
    
}
