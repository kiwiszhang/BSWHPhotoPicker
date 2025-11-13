//
//  UIImage+Extension.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/13.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

extension UIImage {

    /// 水平翻转
    func flippedHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // 水平翻转
        context.translateBy(x: size.width, y: 0)
        context.scaleBy(x: -1.0, y: 1.0)
        
        draw(in: CGRect(origin: .zero, size: size))
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage
    }
    
    /// 垂直翻转
    func flippedVertically() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // 垂直翻转
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        draw(in: CGRect(origin: .zero, size: size))
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage
    }
    
    // MARK: - 裁剪为 1:1 正方形
    func croppedToCenteredSquare() -> UIImage? {
        return croppedToAspectRatio(widthRatio: 1, heightRatio: 1)
    }

    // MARK: - 裁剪为 4:5 比例
    func croppedToAspect4x5() -> UIImage? {
        return croppedToAspectRatio(widthRatio: 4, heightRatio: 5)
    }

    // MARK: - 裁剪为 9:16 比例
    func croppedToAspect9x16() -> UIImage? {
        return croppedToAspectRatio(widthRatio: 9, heightRatio: 16)
    }

    // MARK: - 通用方法：根据比例自动居中裁剪
    private func croppedToAspectRatio(widthRatio: CGFloat, heightRatio: CGFloat) -> UIImage? {
        guard let normalized = normalizedImage() else { return nil }

        let imageWidth = normalized.size.width
        let imageHeight = normalized.size.height
        let targetRatio = widthRatio / heightRatio
        let currentRatio = imageWidth / imageHeight

        var cropRect: CGRect

        // 宽比高窄：以宽为基准，裁高
        if currentRatio < targetRatio {
            let newHeight = imageWidth / targetRatio
            let originY = (imageHeight - newHeight) / 2.0
            cropRect = CGRect(x: 0, y: originY, width: imageWidth, height: newHeight)
        }
        // 宽比高宽：以高为基准，裁宽
        else if currentRatio > targetRatio {
            let newWidth = imageHeight * targetRatio
            let originX = (imageWidth - newWidth) / 2.0
            cropRect = CGRect(x: originX, y: 0, width: newWidth, height: imageHeight)
        }
        // 宽高比刚好相等
        else {
            cropRect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        }

        // 绘制裁剪后的图像
        let format = UIGraphicsImageRendererFormat()
        format.scale = normalized.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: cropRect.size, format: format)
        let result = renderer.image { _ in
            normalized.draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
        }

        return result
    }

    /// 归一化方向（解决旋转问题）
    private func normalizedImage() -> UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg
    }
}

