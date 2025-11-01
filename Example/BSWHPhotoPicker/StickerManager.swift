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
            let selectedImage: UIImage = UIImage(named: "addImage")!
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
        let selectedImage: UIImage = sticker.stickerModel?.stickerImage ?? UIImage(named: "addImage")!
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
        let finalImage: UIImage
        
        if let base = baseImage {
            let size = base.size
            finalImage = UIGraphicsImageRenderer(size: size).image { _ in
                // 绘制底图
                base.draw(in: CGRect(origin: .zero, size: size))
                
                let overlayRect = CGRect(
                    x: size.width * (stickerModel.overlayRectX ?? 0),
                    y: size.height * (stickerModel.overlayRectY ?? 0),
                    width: size.width * (stickerModel.overlayRectWidth ?? 0.8),
                    height: size.height * (stickerModel.overlayRectHeight ?? 0.8)
                )
                
                let isCircle = stickerModel.isCircle ?? false
                if isCircle {
                    let path = UIBezierPath(ovalIn: overlayRect)
                    path.addClip()
                } else {
                    let path = UIBezierPath(rect: overlayRect)
                    path.addClip()
                }
                
                let imageSize = newImage.size
                let rectAspect = overlayRect.width / overlayRect.height
                let imageAspect = imageSize.width / imageSize.height
                
                var drawRect = CGRect.zero
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
                
                // 绘制 newImage（超出 overlayRect 会被裁剪）
                newImage.draw(in: drawRect, blendMode: .normal, alpha: 1.0)
            }
        } else {
            finalImage = newImage
        }
        
        if let imageView = self.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.image = finalImage
            imageView.setNeedsDisplay()
        } else {
            self.image = finalImage
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }


}

