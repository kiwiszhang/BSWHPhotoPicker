//
//  ZLBaseStickertState.swift
//  ZLImageEditor
//
//  Created by long on 2023/10/12.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public class ZLBaseStickertState: NSObject {
    let id: String
    let image: UIImage
    public var originScale: CGFloat
    public var originAngle: CGFloat
    public var originFrame: CGRect
    public var gesScale: CGFloat
    public var gesRotation: CGFloat
    public var totalTranslationPoint: CGPoint
    var isBgImage:Bool
    var bgAddImageType:String
    public var imageMask:String
    public var imageData: Data
    public var cornerRadiusScale:Double
    public init(
        id: String,
        image: UIImage,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat,
        gesRotation: CGFloat,
        totalTranslationPoint: CGPoint,
        isBgImage:Bool,
        bgAddImageType:String,
        imageMask:String,
        cornerRadiusScale:Double,
        imageData:Data
    ) {
        self.id = id
        self.image = image
        self.originScale = originScale
        self.originAngle = originAngle
        self.originFrame = originFrame
        self.gesScale = gesScale
        self.gesRotation = gesRotation
        self.totalTranslationPoint = totalTranslationPoint
        self.isBgImage = isBgImage
        self.bgAddImageType = bgAddImageType
        self.imageMask = imageMask
        self.cornerRadiusScale = cornerRadiusScale
        self.imageData = imageData
        super.init()
    }
}

public class ZLImageStickerState: ZLBaseStickertState { }

public class ZLTextStickerState: ZLBaseStickertState {
    let text: String
    let textColor: UIColor
    let font: UIFont?
    let style: ZLInputTextStyle
    
    public init(
        id: String,
        text: String,
        textColor: UIColor,
        font: UIFont?,
        style: ZLInputTextStyle,
        image: UIImage,
        originScale: CGFloat,
        originAngle: CGFloat,
        originFrame: CGRect,
        gesScale: CGFloat,
        gesRotation: CGFloat,
        totalTranslationPoint: CGPoint,
        isBgImage:Bool,
        bgAddImageType:String,
        imageMask:String,
        cornerRadiusScale:Double,
        imageData:Data
    ) {
        self.text = text
        self.textColor = textColor
        self.font = font
        self.style = style
        super.init(
            id: id,
            image: image,
            originScale: originScale,
            originAngle: originAngle,
            originFrame: originFrame,
            gesScale: gesScale,
            gesRotation: gesRotation,
            totalTranslationPoint: totalTranslationPoint,
            isBgImage: isBgImage,
            bgAddImageType: bgAddImageType,
            imageMask: imageMask,
            cornerRadiusScale:cornerRadiusScale,
            imageData: imageData
        )
    }
}

