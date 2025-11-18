//
//  EditImageViewController+Exstention.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/14.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import BSWHPhotoPicker

// MARK: - 顶部工具栏 TemplateTopView-TemplateTopViewDelegate
extension EditImageViewController:TemplateTopViewDelegate {
    func closeTemplate(_ sender: TemplateTopView) {
        dismiss(animated: true)
    }
    func backTemplate(_ sender: TemplateTopView){
        currentSticker = nil
        hideBottomPanel()
        if canRedo {
            redoAction()
        }
        backAndreBackStatus()
    }
    func reBackTemplate(_ sender: TemplateTopView) {
        currentSticker = nil
        hideBottomPanel()
        if canUndo {
            undoAction()
        }
        backAndreBackStatus()
    }
    func saveTemplate(_ sender: TemplateTopView) {
        guard let finalImage = renderImage(from: containerView) else { return }
        saveImageToAlbum(finalImage)
    }
}

// MARK: - 整体工具栏 ToolsCollectionView-ToolsCollectionViewDelegate
extension EditImageViewController:ToolsCollectionViewDelegate {
    func cellDidSelectItemAt(_ sender: ToolsCollectionView, indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.switchOperation(type: .textSticker)
            self.addTextSticker01(font: UIFont.systemFont(ofSize: 20)) { result in
                if let result = result {
                    let sticker = result.sticker
                    sticker.frame = result.frame
                    let image = sticker.toImage(targetSize: result.frame.size)
                    let frame = result.frame
                    DispatchQueue.main.async {
                        self.switchOperation(type: .imageSticker)
                        let state: ImageStickerModel = ImageStickerModel(imageName: "empty",imageData:image.pngData(), originFrame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height),gesScale: 1,gesRotation: 0,overlayRect: CGRect(x:0,y: 0,width: 1,height: 1) ,isBgImage: true)
                        state.imageData = image.pngData()
                        let sticker = self.addImageSticker01(state: state)
                        sticker.stickerModel = state
                        StickerManager.shared.modelMap[sticker.id] = state
                        StickerManager.shared.stickerArr.append(sticker)
                        if let image = sticker.stickerModel?.stickerImage {
                            sticker.updateImage(image, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
                        }
                    }
                }
            }
        }else if indexPath.row == 1 {
//            showBottomPanel()
            StickerManager.shared.delegate?.replaceBackgroundWith(controller: self,imageRect: imageView.frame) { [weak self] image in
                guard let self = self else { return }
                if let img = image {
                    print("🎉 收到代理返回的图片：\(img)")
                    replaceBgImage(image: img)
                    resetContainerViewFrame()
                } else {
                    print("⚠️ 没有返回图片")
                }
            }
        }else if indexPath.row == 2 {
            StickerManager.shared.checkPhotoAuthorizationAndPresentPicker(presentTypeFrom: 1)
        }else if indexPath.row == 3 {
            StickerManager.shared.delegate?.addStickerImage(controller: self) { [weak self] image in
                print("添加贴纸")
                if let img = image {
                    DispatchQueue.main.async {
                        self!.switchOperation(type: .imageSticker)
                        let state: ImageStickerModel = ImageStickerModel(imageName: "empty",imageData:img.pngData(), originFrame: CGRect(x: 240, y: 100, width: 120, height: 120),gesScale: 1,gesRotation: 0,overlayRect: CGRect(x:0,y: 0,width: 1,height: 1) ,isBgImage: true)
                        let sticker = self!.addImageSticker01(state: state)
                        sticker.stickerModel = state
                        StickerManager.shared.modelMap[sticker.id] = state
                        StickerManager.shared.stickerArr.append(sticker)
                        if let image = sticker.stickerModel?.stickerImage {
                            sticker.updateImage(image, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
                        }
                    }
                } else {
                    
                }
            }
        }else if indexPath.row == 4 {
            showRatioBottomPanel()
        }
    }
}


// MARK: - 贴纸工具栏 StickerToolsView-StickerToolsViewDelegate
extension EditImageViewController:StickerToolsViewDelegate {
    func stickerToolDidSelectItemAt(_ sender: StickerToolsView, indexPath: IndexPath) {
        if indexPath.row == 0 {
            StickerManager.shared.checkPhotoAuthorizationAndPresentPicker()
        }else if indexPath.row == 1 {
            NotificationCenter.default.post(name: Notification.Name("duplicateSticker"), object: ["sticker": currentSticker])
        }else if indexPath.row == 2 {
            if let sticker = currentSticker {
                print("裁剪后的照片")
                StickerManager.shared.delegate?.cropStickerImage(controller: self) { image in
                    if let img = image {
                        sticker.updateImage(img, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
                    } else {
                    }
                }
            }
            
        }else if indexPath.row == 3 {
            if let sticker = currentSticker {
                if let image = sticker.stickerModel?.stickerImage,let newImage = image.flippedHorizontally() {
                    if let imageData = newImage.pngData() {
                        sticker.stickerModel?.imageData = imageData
                    }
                    sticker.updateImage(newImage, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
                }
            }
        }else if indexPath.row == 4 {
            if let sticker = currentSticker {
                if let image = sticker.stickerModel?.stickerImage,let newImage = image.flippedVertically() {
                    if let imageData = newImage.pngData() {
                        sticker.stickerModel?.imageData = imageData
                    }
                    sticker.updateImage(newImage, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image)
                }
            }
        }else if indexPath.row == 5 {
            if let sticker = currentSticker {
                UIView.animate(withDuration: 0.2) {
                    sticker.alpha = 0
                    sticker.leftTopButton.alpha = 0
                    sticker.resizeButton.alpha = 0
                    sticker.rightTopButton.alpha = 0
                } completion: { _ in
                    sticker.removeFromSuperview()
                }
                hideBottomPanel()
            }
        }
    }
}

// MARK: - 比例工具栏 RatioToolView-RatioToolViewDelegate
extension EditImageViewController:RatioToolViewDelegate {
    func RatioToolViewDidSelectItemAt(_ sender: RatioToolView, indexPath: IndexPath,ratioItem:RatioToolsModel) {
        let image = UIImage(named: item!.imageBg)
            if let squareImage = image!.cropped(toAspectRatioWidth: ratioItem.width, height: ratioItem.height) {
                
                for sticker in StickerManager.shared.stickerArr {
                    sticker.removeFromSuperview()
                }
                
                StickerManager.shared.initCurrentTemplate(jsonName:item!.jsonName, currentVC: self)
                
                convertStickerFrames(
                    stickers: StickerManager.shared.stickerArr,
                    oldSize: image!.size,
                    newSize: squareImage.size
                )
                replaceBgImage(image: squareImage)
                resetContainerViewFrame()
        }
    }
    
    func convertStickerFrames(
        stickers: [EditableStickerView],
        oldSize: CGSize,
        newSize: CGSize
    ) {
        let scale = min(newSize.width / oldSize.width,
                        newSize.height / oldSize.height)

        let scaledWidth = oldSize.width * scale
        let scaledHeight = oldSize.height * scale

        let offsetX = (newSize.width - scaledWidth) / 2
        let offsetY = (newSize.height - scaledHeight) / 2

        for sticker in stickers {
            // 1) 先把 sticker 在旧画布中心位置映射到新画布
            let oldCenter = sticker.center // 在 overlay / 父视图坐标系里的中心
            let newCenter = CGPoint(x: oldCenter.x * scale + offsetX,
                                    y: oldCenter.y * scale + offsetY)

            // 2) 更新模型参数（而不是直接叠加 transform）
            // 注意：totalTranslationPoint 通常以贴纸的原始坐标体系为准，
            // 这里我们也按比例缩放 translation（如果你的实现 translation 是相对于父坐标系）
            sticker.totalTranslationPoint.x *= scale
            sticker.totalTranslationPoint.y *= scale

            // 原有的 originScale 是贴纸相对于原图的基础缩放，等比放大
            sticker.originScale *= scale

            // 手动把临时手势状态复位（避免遗留 gesScale/gesRotation）
            sticker.gesScale = 1
            // sticker.gesRotation = 0 // 视你的实现而定

            // 3) 通过内部接口更新 transform（由内部负责生成 transform 并定位内容）
            sticker.updateTransform()    // 或者 sticker.updateTransform01()，看你具体想要的行为

            // 4) 把 center 设回新位置（updateTransform 可能会用 totalTranslationPoint，确保先设置）
            sticker.center = newCenter

            // 5) 强制布局并刷新 overlay 按钮 / border
            sticker.setNeedsLayout()
            sticker.layoutIfNeeded()
            sticker.refreshResizeButtonPosition() // 你已有方法，把按钮位置同步到 overlay

            // 6) 更新持久化状态
            sticker.originFrame = sticker.frame
            sticker.originTransform = sticker.transform
        }
    }


}

