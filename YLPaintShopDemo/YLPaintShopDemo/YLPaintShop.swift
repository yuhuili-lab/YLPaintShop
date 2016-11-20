//
//  YLPaintShop.swift
//  YLPaintShopDemo
//
//  Created by Alexander Li on 2016-11-19.
//  Copyright © 2016 Yuhui Li. All rights reserved.
//

import UIKit

enum GaussianDirection:Int {
    case Horizontal
    case Vertical
}

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
    
    
    /* This code is based on the C# code posted by Stack Overflow user
     * "Cecil has a name" at this link:
     * http://stackoverflow.com/questions/1696113/how-do-i-gaussian-blur-an-image-without-using-any-in-built-gaussian-functions
     */
    static func gaussianKernalForRadius(_ radius: Int) -> [Int:Double] {
        if radius < 1 {
            return [Int:Double]()
        }
        
        let kernelSize = radius * 2 + 1
        var kernel = [Int:Double]()
        
        let magic1 = 1.0 / (2.0 * Double(radius) * Double(radius))
        let magic2 = 1.0 / (sqrt(2.0 * .pi) * Double(radius))
        
        var r = -radius
        var div = 0.0
        
        for i in 0...kernelSize-1 {
            let x = Double(r * r)
            let value = magic2 * exp(-x * magic1)
            kernel[i] = value
            r += 1
            div += value
        }
        
        for i in 0...kernelSize-1 {
            kernel[i] = kernel[i]! / div
        }
        
        return kernel
    }
    
    static func gaussianKernelMultiplier(index index: Int, total: Int, kernel: [Int: Double]) -> Double {
        let radius = kernel.count / 2
        
        var uselessAmount = 0.0
        
        if (index-radius < 0) {
            for i in index-radius ... -1 {
                uselessAmount += kernel[i-(index-radius)]!
            }
        }
        
        if (total <= index+radius) {
            for i in total...index+radius {
                uselessAmount += kernel[(kernel.count-1)-((index+radius)-i)]!
            }
        }
        
        return 1.0 / (1.0 - uselessAmount)
    }
    
    static func performGaussianPass(direction dir: GaussianDirection, width: Int, height: Int, radius: Int, context: CGContext, gaussianKernel: [Int: Double]) {
        
        let data = context.data
        let dataType = UnsafeMutableRawPointer(data)!.assumingMemoryBound(to: UInt8.self)
        
        for i in 0...width*height-1 {
            // Find out which row which column currently is
            let row:Int = i/width
            let col:Int = i%width
            let offset = 4 * i
            
            var totalRed:Double = 0
            var totalGreen:Double = 0
            var totalBlue:Double = 0
            
            switch dir {
            case .Horizontal:
                let gaussianKernelMultiplier = UIImage.gaussianKernelMultiplier(index: col, total: width, kernel: gaussianKernel)
                
                for j in col-radius...col+radius where j>=0 && j<width {
                    
                    let multiplier = (gaussianKernel[j-(col-radius)]! as Double) * gaussianKernelMultiplier
                    
                    let newOffset = 4 * ((width * row) + j)
                    
                    totalRed += Double(dataType[newOffset+1]) * multiplier
                    totalGreen += Double(dataType[newOffset+2]) * multiplier
                    totalBlue += Double(dataType[newOffset+3]) * multiplier
                }
                break;
            
                
            case .Vertical:
                let gaussianKernelMultiplier = UIImage.gaussianKernelMultiplier(index: row, total: height, kernel: gaussianKernel)
                
                for j in row-radius...row+radius where j>=0 && j<height {
                    
                    let multiplier = (gaussianKernel[j-(row-radius)]! as Double) * gaussianKernelMultiplier
                    
                    let newOffset = 4 * ((width * j) + col)
                    
                    totalRed += Double(dataType[newOffset+1]) * multiplier
                    totalGreen += Double(dataType[newOffset+2]) * multiplier
                    totalBlue += Double(dataType[newOffset+3]) * multiplier
                }
                break;
                
            }
            
            
            dataType[offset+1] = UInt8(totalRed)
            dataType[offset+2] = UInt8(totalGreen)
            dataType[offset+3] = UInt8(totalBlue)
        }
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
    
    
    func gaussianBlur(_ radius: Int) -> UIImage? {
        let inImage:CGImage = self.cgImage!
        let context = self.createContext(inImage)
        
        let width = inImage.width
        let height = inImage.height
        
        let rect = CGRect(x:0, y:0, width:width, height:height)
        
        context.clear(rect)
        context.draw(inImage, in: rect)
        
        let gaussianKernel = UIImage.gaussianKernalForRadius(radius)
        
        
        UIImage.performGaussianPass(direction: .Horizontal, width: width, height: height, radius: radius, context: context, gaussianKernel: gaussianKernel)
        UIImage.performGaussianPass(direction: .Vertical, width: width, height: height, radius: radius, context: context, gaussianKernel: gaussianKernel)
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapBytesPerRow = width * 4
        
        let finalContext = CGContext(data: context.data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let imageRef = finalContext?.makeImage()
        
        return UIImage(cgImage: imageRef!)
    }
    
}
