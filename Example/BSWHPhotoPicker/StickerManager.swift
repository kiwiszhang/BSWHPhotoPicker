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
    private weak var controller: UIViewController?
    private weak var currentStickerView: ZLImageStickerView?
    private var currentStickerModel: ImageStickerModel?
    private var baseView:UIView?

    var modelMap: [String: ImageStickerModel] = [:]

    static let shared = StickerManager()
    private override init() {}

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

//    func makeStickerStates(from fileName: String) -> [ZLImageStickerState] {
//        modelMap.removeAll()
//        guard let items = loadLocalJSON(fileName: fileName, type: [ImageStickerModel].self) else { return [] }
//        var result: [ZLImageStickerState] = []
//
//        for item in items {
//            let uuid = UUID().uuidString
//            let imageSticker = ZLImageStickerState(
//                id: uuid,
//                image: UIImage(named: item.image)!,
//                originScale: item.originScale,
//                originAngle: item.originAngle,
//                originFrame: CGRect(
//                    x: item.originFrameX.w,
//                    y: item.originFrameY.h,
//                    width: item.originFrameWidth == -1 ? UIScreen.main.bounds.width : item.originFrameWidth.w,
//                    height: item.originFrameHeight.h
//                ),
//                gesScale: item.gesScale,
//                gesRotation: item.gesRotation,
//                totalTranslationPoint: .zero
//            )
//            result.append(imageSticker)
//            modelMap[uuid] = item
//        }
//        return result
//    }

    func attachTapGestures(in view: UIView,vc:UIViewController) {
        controller = vc
        attachGesturesAndModels(in: view, modelMap: StickerManager.shared.modelMap)
        setupTapGestureForStickersPeriodically()
    }
    // ✅ 递归扫描并绑定可点击贴纸
    func attachGesturesAndModels(in rootView: UIView, modelMap: [String: ImageStickerModel]) {
        baseView = rootView
        
        func traverse(_ view: UIView) {
            for sub in view.subviews {
                if let stickerView = sub as? EditableStickerView {
                    
                    // 1️⃣ 绑定模型（如果能拿到 id）
                    let uuid = stickerView.id
                    if let model = modelMap[uuid] {
                        stickerView.stickerModel = model
                    }
                    
                    if let image = stickerView.stickerModel?.stickerImage {
                        stickerView.updateImage(image, stickerModel: stickerView.stickerModel!, withBaseImage: stickerView.image)
                    }
                    
                    // 2️⃣ 如果是贴纸背景，加手势
                    if stickerView.stickerModel?.isBgImage == true {
                        let tap = UITapGestureRecognizer(target: self, action: #selector(stickerTapped(_:)))
                        stickerView.addGestureRecognizer(tap)
                        stickerView.isUserInteractionEnabled = true
                    }
                    
                } else {
                    traverse(sub)
                }
            }
        }
        
        traverse(rootView)
    }

    func setupTapGestureForStickersPeriodically() {
        // 每次视图出现后，每隔 0.5s 检查一次贴纸状态
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.attachGesturesAndModels(in: self?.baseView ?? UIView(), modelMap: StickerManager.shared.modelMap)
        }
    }
    
// MARK: - 点击事件处理
    @objc private func stickerTapped(_ sender: UITapGestureRecognizer) {
        guard let stickerView = sender.view as? ZLImageStickerView else { return }
        currentStickerView = stickerView

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
    }
}

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
    
    func updateImage(_ newImage: UIImage,stickerModel:ImageStickerModel,withBaseImage baseImage: UIImage? = nil) {
        let finalImage: UIImage
        if let base = baseImage {
            let size = base.size
            finalImage = UIGraphicsImageRenderer(size: size).image { _ in
                base.draw(in: CGRect(origin: .zero, size: size))
                let overlayRect = CGRect(
                    x: size.width * (stickerModel.overlayRectX ?? 0),
                    y: size.height * (stickerModel.overlayRectY ?? 0),
                    width: size.width * (stickerModel.overlayRectWidth ?? 0.8),
                    height: size.height * (stickerModel.overlayRectHeight ?? 0.8)
                )
                let isCircle = stickerModel.isCircle ?? false
                if isCircle {
                    // 添加圆形裁剪区域
                    let path = UIBezierPath(ovalIn: overlayRect)
                    path.addClip()
                }
                newImage.draw(in: overlayRect, blendMode: .normal, alpha: 1.0)
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

