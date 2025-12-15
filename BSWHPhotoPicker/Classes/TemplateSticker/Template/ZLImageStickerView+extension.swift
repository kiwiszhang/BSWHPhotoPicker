//
//  ZLImageStickerView.swift
//  BSWHPhotoPicker
//
//  Created by 笔尚文化 on 2025/12/15.
//

import UIKit

// MARK: - 关联属性扩展
private var stickerIDKey: UInt8 = 0
private var stickerModelKey: UInt8 = 0
private var stickerImageKey: UInt8 = 0
extension ZLImageStickerView {
    var stickerID: String? {
        get { objc_getAssociatedObject(self, &stickerIDKey) as? String }
        set { objc_setAssociatedObject(self, &stickerIDKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var stickerModel: ImageStickerModel? {
        get { objc_getAssociatedObject(self, &stickerModelKey) as? ImageStickerModel }
        set { objc_setAssociatedObject(self, &stickerModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func updateImage(_ newImage: UIImage, stickerModel: ImageStickerModel, withBaseImage baseImage: UIImage? = nil,vc:EditImageViewController) {
        
        let imageTypeRaw = stickerModel.imageType?.rawValue
        var finalImage: UIImage?
        
        // MARK: - 不规则形状
        if imageTypeRaw == "IrregularShape" {
            if !stickerModel.imageName.isEmpty,
               !stickerModel.imageMask!.isEmpty,
               let base = BSWHBundle.image(named: stickerModel.imageName),
               let frame = BSWHBundle.image(named: stickerModel.imageMask!) {
                
                if stickerModel.imageMask == "addEmptyImage" {
                    vc.imageView.contentMode(.scaleAspectFill)

                    if stickerModel.imageName == "Travel-sticker-bg06" {
                        if stickerModel.imageData == nil {
                            vc.imageView.image = BSWHBundle.image(named: "Travel07-bg")
                        }else{
                            vc.imageView.image = newImage
                         }
                    }else if stickerModel.imageName == "Birthday02-sticker-bg00" {
                        if stickerModel.imageData == nil {
                            vc.imageView.image = BSWHBundle.image(named: "Travel07-bg")
                        }else{
                            vc.imageView.image = newImage
                         }
                    }
                    finalImage = overlayImageWithFrame(BSWHBundle.image(named: "Birthday02-sticker-bg00")!, baseImage: base, frameImage: frame)
                }else{
                    finalImage = overlayImageWithFrame(newImage, baseImage: base, frameImage: frame)
                }
            }
        }else if imageTypeRaw == "IrregularMask" {
            if !stickerModel.imageName.isEmpty,
               !stickerModel.imageMask!.isEmpty,
               let base = BSWHBundle.image(named: stickerModel.imageName),
               let frame = BSWHBundle.image(named: stickerModel.imageMask!) {
                var inset = 20.0
                var xset = 0.0
                var yset = 0.0
                if stickerModel.imageMask == "baby04-sticker-bg00" {
                    inset = 25
                    xset = 0.0
                    yset = -5.0
                }
                finalImage = IrregularMaskOverlayImageWithFrame(newImage, baseImage: base, frameImage: frame,inset: inset,xSet: xset,ySet: yset)
            }
        } else {
            // MARK: - 常规形状
            guard let base = baseImage else {
                finalImage = newImage
                return
            }
            
            let size = base.size
            finalImage = UIGraphicsImageRenderer(size: size).image { _ in
                // 绘制底图
                base.draw(in: CGRect(origin: .zero, size: size))
                
                // overlayRect
                let overlayRect = CGRect(
                    x: size.width * (stickerModel.overlayRectX ?? 0),
                    y: size.height * (stickerModel.overlayRectY ?? 0),
                    width: size.width * (stickerModel.overlayRectWidth ?? 0.8),
                    height: size.height * (stickerModel.overlayRectHeight ?? 0.8)
                )
                
                // 裁剪路径
                let path: UIBezierPath = {
                    switch imageTypeRaw {
                    case "circle", "ellipse":
                        return UIBezierPath(ovalIn: overlayRect)
                    case "square":
                        return UIBezierPath(rect: overlayRect)
                    case "rectangle":
                        return UIBezierPath(roundedRect: overlayRect, cornerRadius: stickerModel.cornerRadiusScale ?? 0.0)
                    default:
                        return UIBezierPath(rect: overlayRect)
                    }
                }()
                path.addClip()
                
                // 计算绘制区域，保持比例填充 overlayRect
                let imageSize = newImage.size
                let rectAspect = overlayRect.width / overlayRect.height
                let imageAspect = imageSize.width / imageSize.height
                
                let drawRect: CGRect
                if imageAspect > rectAspect {
                    let scale = overlayRect.height / imageSize.height
                    let drawWidth = imageSize.width * scale
                    let x = overlayRect.origin.x - (drawWidth - overlayRect.width) / 2
                    drawRect = CGRect(x: x, y: overlayRect.origin.y, width: drawWidth, height: overlayRect.height)
                } else {
                    let scale = overlayRect.width / imageSize.width
                    let drawHeight = imageSize.height * scale
                    let y = overlayRect.origin.y - (drawHeight - overlayRect.height) / 2
                    drawRect = CGRect(x: overlayRect.origin.x, y: y, width: overlayRect.width, height: drawHeight)
                }
                
                // 绘制 newImage
                newImage.draw(in: drawRect, blendMode: .normal, alpha: 1.0)
            }
        }
        
        // MARK: - 更新 UIImageView 或 self.image
        if let imageView = self.subviews.compactMap({ $0 as? UIImageView }).first {
            imageView.image = finalImage
            imageView.setNeedsDisplay()
        } else if let finalImage = finalImage {
            self.image = finalImage
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    
    func overlayImageWithFrame(_ newImage: UIImage, baseImage: UIImage, frameImage: UIImage) -> UIImage {
        let size = baseImage.size
        
        guard let baseCG = baseImage.cgImage else { return baseImage }
        
        let width = baseCG.width
        let height = baseCG.height
        let bitsPerComponent = 8
        let bytesPerRow = width
        var alphaData = [UInt8](repeating: 0, count: width * height)
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: &alphaData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: 0) else { return baseImage }
        context.draw(baseCG, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var flippedAlpha = [UInt8](repeating: 0, count: width * height)
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let flippedIndex = (height - 1 - y) * width + x
                flippedAlpha[flippedIndex] = alphaData[index] > 0 ? 0 : 255
            }
        }
        
        guard let maskProvider = CGDataProvider(data: NSData(bytes: &flippedAlpha, length: flippedAlpha.count)) else { return baseImage }
        guard let mask = CGImage(maskWidth: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bitsPerPixel: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 provider: maskProvider,
                                 decode: nil,
                                 shouldInterpolate: false) else { return baseImage }
        
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let cgContext = ctx.cgContext
            
            baseImage.draw(in: CGRect(origin: .zero, size: size))
            
            cgContext.saveGState()
            cgContext.clip(to: CGRect(origin: .zero, size: size), mask: mask)
            
            let scaleW = size.width / newImage.size.width
            let scaleH = size.height / newImage.size.height
            let scale = max(scaleW, scaleH)
            let newWidth = newImage.size.width * scale
            let newHeight = newImage.size.height * scale
            let originX = (size.width - newWidth) / 2
            let originY = (size.height - newHeight) / 2
            let imageRect = CGRect(x: originX, y: originY, width: newWidth, height: newHeight)
            
            newImage.draw(in: imageRect)
            cgContext.restoreGState()
            
            frameImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func IrregularMaskOverlayImageWithFrame(_ newImage: UIImage,
                                   baseImage: UIImage,
                                            frameImage: UIImage,inset:CGFloat = 20,xSet:CGFloat = 0,ySet:CGFloat = 0) -> UIImage {

            let size = frameImage.size
            return UIGraphicsImageRenderer(size: size).image { ctx in
                // 计算 baseImage 的绘制区域（Fit 模式）
                let drawRect = CGRect(
                    x: inset + xSet,
                    y: inset + ySet,
                    width: size.width - inset * 2,
                    height: size.height - inset * 2
                )

                let bw = baseImage.size.width
                let bh = baseImage.size.height
                let scaleFit = min(drawRect.width / bw, drawRect.height / bh)
                let baseW = bw * scaleFit
                let baseH = bh * scaleFit
                let baseRect = CGRect(
                    x: drawRect.midX - baseW / 2,
                    y: drawRect.midY - baseH / 2,
                    width: baseW,
                    height: baseH
                )

                // 1️⃣ 先绘制 baseImage
                baseImage.draw(in: baseRect)

                // 2️⃣ 使用 baseImage 的 alpha 作为裁剪区域
                if let cgBase = baseImage.cgImage {
                    ctx.cgContext.saveGState()

                    // 将 context 移动到 baseRect 的位置
                    ctx.cgContext.translateBy(x: baseRect.origin.x, y: baseRect.origin.y)
                    ctx.cgContext.scaleBy(x: baseRect.width / CGFloat(cgBase.width),
                                          y: baseRect.height / CGFloat(cgBase.height))

                    // 使用 alpha 通道裁剪：非透明部分可绘制，透明部分不可绘制
                    ctx.cgContext.clip(to: CGRect(x: 0, y: 0,
                                                  width: cgBase.width,
                                                  height: cgBase.height),
                                       mask: cgBase)

                    // 3️⃣ 绘制 newImage（Fill 模式，铺满整个 baseImage 区域）
                    let nw = newImage.size.width
                    let nh = newImage.size.height
                    let scaleFill = max(CGFloat(cgBase.width) / nw, CGFloat(cgBase.height) / nh)
                    let newW = nw * scaleFill
                    let newH = nh * scaleFill
                    let newRect = CGRect(
                        x: 0 + (CGFloat(cgBase.width) - newW) / 2,
                        y: 0 + (CGFloat(cgBase.height) - newH) / 2,
                        width: newW,
                        height: newH
                    )
                    newImage.draw(in: newRect)

                    ctx.cgContext.restoreGState()
                }

                // 4️⃣ 最后绘制 frameImage
                frameImage.draw(in: CGRect(origin: .zero, size: size))
            }
        }
}
