//
//  ViewController.swift
//  PaintWithFriends
//
//  Created by Garrigus, Justin on 4/23/19.
//  Copyright © 2019 Garrigus, Justin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var context: CGContext?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.bounds = self.view.bounds
        
        imageView.image = createNewImage(width: Int(imageView.bounds.width), height: Int(imageView.bounds.height))
   
        if let context = setContext(image: imageView.image!)
        {
            self.context = context
        }
        else
        {
            self.context = nil
        }
    }
    
    func setContext(image: UIImage) -> CGContext?
    {
        guard let inputCGImage = image.cgImage else
        {
            print("unable to get cgImage")
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            else
        {
            print("unable to create context")
            return nil
        }
        
        return context
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touchLoc in touches
        {
            touch(touchLoc.location(in: imageView))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touchLoc in touches
        {
            touch(touchLoc.location(in: imageView))
        }
    }
    
    func touch(_ location: CGPoint)
    {
        guard let image = imageView.image else
        {
            print("Image is nil")
            return
        }
        
        imageView.image = setImagePixels(image: image, x: Int(location.x), y: Int(location.y), totalWidth: Int(imageView.bounds.width), totalHeight: Int(imageView.bounds.height))
    }
    
    func createNewImage(width: Int, height: Int) -> UIImage?
    {
        return UIImage(color: .red, size: CGSize(width: width, height: height))
    }
    
    func setImagePixels(image: UIImage, x: Int, y: Int, totalWidth: Int, totalHeight: Int) -> UIImage?
    {
        guard let inputCGImage = image.cgImage else
        {
            print("inputCGImage is nil")
            return nil
        }
        
        let width = inputCGImage.width
        let height = inputCGImage.height
        
        guard let context = context else
        {
            print("Context is nil")
            return nil
        }
        
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else
        {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: Int(imageView.bounds.width * imageView.bounds.height))
        
        for drawX in x-5...x+5
        {
            for drawY in y-5...y+5
            {
                if drawX >= 0 && drawX < width && drawY >= 0 && drawY < height
                {
                    let offset = drawY * width + drawX
                    pixelBuffer[offset] = .black
                }
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return outputImage
    }
}

struct RGBA32: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }
    
    static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
