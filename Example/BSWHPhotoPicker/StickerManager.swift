//
//  StickerManager.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/10/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import PhotosUI
import ObjectiveC
import BSWHPhotoPicker


// MARK: - StickerManager
final class StickerManager: NSObject {
    weak var controller: EditImageViewController?
    private weak var currentStickerView: ZLImageStickerView?
    var modelMap: [String: ImageStickerModel] = [:]

    static let shared = StickerManager()
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(duplicateSticker(_:)),
            name: Notification.Name("duplicateSticker"),
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(addTap(_:)), name: Notification.Name(rawValue: "stickerImageAddTap"), object: nil)
    }

    /// 使用本地Json加载模版
    func initCurrentTemplate(jsonName:String,currentVC:EditImageViewController){
        let items = StickerManager.shared.loadLocalJSON(fileName: jsonName, type: [ImageStickerModel].self)
        StickerManager.shared.modelMap.removeAll()
        controller = currentVC
        for state in items! {
            let sticker = currentVC.addImageSticker01(state: state)
            sticker.stickerModel = state
            StickerManager.shared.modelMap[sticker.id] = state
            if state.isBgImage == true {
                let tap = UITapGestureRecognizer(target: self, action: #selector(stickerTapped(_:)))
                sticker.addGestureRecognizer(tap)
                sticker.isUserInteractionEnabled = true
                if let image = sticker.stickerModel?.stickerImage {
                    sticker.updateImage(image, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
                }
            }
        }
    }

    // MARK: 加载本地 JSON
    func loadLocalJSON<T: Decodable>(fileName: String, type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("❌ 未找到 \(fileName).json")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ 解析 \(fileName).json 失败：\(error)")
            return nil
        }
    }

// MARK: - 点击事件处理
    @objc func duplicateSticker(_ notification: Notification){
        let dict = notification.object as! [String:Any]
        let stickerOld:EditableStickerView = dict["sticker"] as! EditableStickerView
        let stateTmp:ImageStickerModel = StickerManager.shared.modelMap[stickerOld.id]!;
        let state = stateTmp.deepCopy()
        state.originFrameX = state.originFrameX + stickerOld.totalTranslationPoint.x + 35
        state.originFrameY = state.originFrameY + stickerOld.totalTranslationPoint.y + 35
        state.originAngle = stickerOld.originAngle
        state.originScale = stickerOld.originScale
        state.gesRotation = stickerOld.gesRotation
        let sticker = controller!.addImageSticker01(state: state)
        sticker.stickerModel = state
        StickerManager.shared.modelMap[sticker.id] = state
        if state.isBgImage == true {
            let tap = UITapGestureRecognizer(target: self, action: #selector(stickerTapped(_:)))
            sticker.addGestureRecognizer(tap)
            sticker.isUserInteractionEnabled = true
            let selectedImage: UIImage = UIImage(named: (sticker.stickerModel?.bgAddImageType)!)!
            sticker.updateImage(selectedImage, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
        }
    }

    
    @objc func addTap(_ notification: Notification) {
        let dict = notification.object as! [String:Any]
        let sticker:EditableStickerView = dict["sticker"] as! EditableStickerView
        sticker.stickerModel = StickerManager.shared.modelMap[sticker.id]
        let tap = UITapGestureRecognizer(target: self, action: #selector(stickerTapped(_:)))
        sticker.addGestureRecognizer(tap)
        sticker.isUserInteractionEnabled = true
        let selectedImage: UIImage = sticker.stickerModel?.stickerImage ?? UIImage(named: (sticker.stickerModel?.bgAddImageType)!)!
        sticker.updateImage(selectedImage, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
    }
    
    @objc func stickerTapped(_ sender: UITapGestureRecognizer) {
        guard let stickerView = sender.view as? EditableStickerView else { return }
        currentStickerView = stickerView

        let size = CGSize(width: stickerView.stickerModel!.originFrameWidth, height: stickerView.stickerModel!.originFrameHeight)
        let overlayRect = CGRect(
            x: size.width * (stickerView.stickerModel!.overlayRectX ?? 0),
            y: size.height * (stickerView.stickerModel!.overlayRectY ?? 0),
            width: size.width * (stickerView.stickerModel!.overlayRectWidth ?? 0.8),
            height: size.height * (stickerView.stickerModel!.overlayRectHeight ?? 0.8)
        )
        
        let point = sender.location(in: stickerView)
        
        if overlayRect.contains(point) {
            print("👉 点击在 overlay 区域内")
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized || status == .limited else { return }
                DispatchQueue.main.async {
                    var config = PHPickerConfiguration(photoLibrary: .shared())
                    config.filter = .images
                    config.selectionLimit = 1
                    let picker = PHPickerViewController(configuration: config)
                    picker.delegate = self
                    self.controller?.present(picker, animated: true)
                }
            }
        } else {
            print("👉 点击在 overlay 区域外")
            stickerView.setOperation(true)
            stickerView.isEditingCustom = !stickerView.isEditingCustom
            stickerView.setOperation(false)
        }
    }
}
/// 选择照片
extension StickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }
        let provider = result.itemProvider

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let self = self,
                let newImage:UIImage = image as? UIImage,
                let stickerView = self.currentStickerView else { return }
                DispatchQueue.main.async {
                    
                    if stickerView.stickerModel?.isBgImage == true {
                        if let imageData = newImage.pngData() {
                            stickerView.stickerModel?.imageData = imageData
                        }
                        stickerView.updateImage(newImage, stickerModel: stickerView.stickerModel!, withBaseImage: stickerView.image)
                    }
                }
            }
        }
    }
}


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
    
    func updateImage(_ newImage: UIImage, stickerModel: ImageStickerModel, withBaseImage baseImage: UIImage? = nil) {
        
        let imageTypeRaw = stickerModel.imageType?.rawValue
        var finalImage: UIImage?
        
        // MARK: - 不规则形状
        if imageTypeRaw == "IrregularShape" {
            if let base = UIImage(named: stickerModel.image),
               let frame = UIImage(named: stickerModel.imageMask!) {
                
                finalImage = overlayImageWithFrame(newImage, baseImage: base, frameImage: frame)
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
                        let cornerRadius = min(overlayRect.width, overlayRect.height) * 0.1
                        return UIBezierPath(roundedRect: overlayRect, cornerRadius: cornerRadius)
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
    
    // 1. 生成二值化 alpha mask（反转并翻转上下，使 mask 与 UIKit 坐标系对齐）
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
    
    // 绘制 baseCG 到灰度 context
    context.draw(baseCG, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    // 二值化 alpha 并上下翻转 alphaData
    var flippedAlpha = [UInt8](repeating: 0, count: width * height)
    for y in 0..<height {
        for x in 0..<width {
            let index = y * width + x
            let flippedIndex = (height - 1 - y) * width + x
            // alpha > 0 -> 0 可绘制，alpha = 0 -> 255 不可绘制
            flippedAlpha[flippedIndex] = alphaData[index] > 0 ? 0 : 255
        }
    }
    
    // 生成 mask
    guard let maskProvider = CGDataProvider(data: NSData(bytes: &flippedAlpha, length: flippedAlpha.count)) else { return baseImage }
    guard let mask = CGImage(maskWidth: width,
                             height: height,
                             bitsPerComponent: bitsPerComponent,
                             bitsPerPixel: bitsPerComponent,
                             bytesPerRow: bytesPerRow,
                             provider: maskProvider,
                             decode: nil,
                             shouldInterpolate: false) else { return baseImage }
    
    // 2. 使用 UIGraphicsImageRenderer 绘制
    return UIGraphicsImageRenderer(size: size).image { ctx in
        let cgContext = ctx.cgContext
        
        // 绘制底图
        baseImage.draw(in: CGRect(origin: .zero, size: size))
        
        // 使用 mask 绘制 newImage（坐标系正常，不翻转）
        cgContext.saveGState()
        cgContext.clip(to: CGRect(origin: .zero, size: size), mask: mask)
        
        // 缩放 newImage 填充整个区域
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
        
        // 叠加金框
        frameImage.draw(in: CGRect(origin: .zero, size: size))
    }
}


}

