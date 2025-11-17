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
//            replaceBgImage(image: UIImage(named: "Christmas00-bg")!)
//            resetContainerViewFrame()
        }else if indexPath.row == 1 {
//            showBottomPanel()
        }else if indexPath.row == 2 {
            StickerManager.shared.checkPhotoAuthorizationAndPresentPicker(presentTypeFrom: 1)
        }else if indexPath.row == 3 {

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
            StickerManager.shared.initCurrentTemplate(jsonName:item!.jsonName, currentVC: self,cropped: 0.5)
            replaceBgImage(image: squareImage)
            resetContainerViewFrame()
        }
    }
}
