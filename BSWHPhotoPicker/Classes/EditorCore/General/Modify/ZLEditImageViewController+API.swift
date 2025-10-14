//
//  ZLEditImageViewController+API.swift
//  BSWHPhotoPicker
//
//  Created by bswh on 2025/9/12.
//

import Foundation

// MARK: - 操作步骤API
extension ZLEditImageViewController {
    /// 当前进行的操作
    public var currentOperation: ZLImageEditorConfiguration.EditTool? {
        return selectedTool
    }
    
    /// 能否Redo
    public var canRedo: Bool {
        return editorManager.actions.count != editorManager.redoActions.count
    }
    
    /// 能否Undo
    public var canUndo: Bool {
        return !editorManager.actions.isEmpty
    }
    /// undo
    public func undoAction() {
        editorManager.undoAction()
    }
    
    /// redo
    public func redoAction() {
        editorManager.redoAction()
    }
    
    /// 切换操作
    public func switchOperation(type: ZLImageEditorConfiguration.EditTool?) {
        switch type {
        case .draw:// 绘制（包含绘制和擦除）
            selectedTool = ((selectedTool == .draw) ? nil : ZLImageEditorConfiguration.EditTool.draw)
        case .mosaic:// 马赛克
            selectedTool = ((selectedTool == .mosaic) ? nil : ZLImageEditorConfiguration.EditTool.mosaic)
            generateNewMosaicImageLayer()
        case .filter:// 滤镜
            selectedTool = ((selectedTool == .filter) ? nil : ZLImageEditorConfiguration.EditTool.filter)
        case .adjust:// 参数调整
            selectedTool = ((selectedTool == .adjust) ? nil : ZLImageEditorConfiguration.EditTool.adjust)
            generateAdjustImageRef()
        default:
            selectedTool = nil
        }
    }
    
    /// 设置擦除
    public func switchEraser() {
        isEraser = !isEraser
    }
    
    /// 完成编辑
    public func doneEdit() {
        var stickerStates: [ZLBaseStickertState] = []
        for view in stickersContainer.subviews {
            guard let view = view as? ZLBaseStickerView else { continue }
            stickerStates.append(view.state)
        }
        
        var hasEdit = true
        if drawPaths.isEmpty,
           currentClipStatus.editRect.size == imageSize,
           currentClipStatus.angle == 0,
           mosaicPaths.isEmpty,
           stickerStates.isEmpty,
           currentFilter.applier == nil,
           currentAdjustStatus.allValueIsZero {
            hasEdit = false
        }
        
        var resImage = originalImage
        var editModel: ZLEditImageModel?
        
        func callback() {
            dismiss(animated: animateDismiss) {
                self.editFinishBlock?(resImage, editModel)
            }
        }
        
        guard hasEdit else {
            callback()
            return
        }
        
        autoreleasepool {
            let hud = ZLProgressHUD(style: ZLImageEditorUIConfiguration.default().hudStyle)
            hud.show(in: view)
            
            DispatchQueue.main.async { [self] in
                resImage = buildImage()
                resImage = resImage.zl
                    .clipImage(
                        angle: currentClipStatus.angle,
                        editRect: currentClipStatus.editRect,
                        isCircle: currentClipStatus.ratio?.isCircle ?? false
                    ) ?? resImage
                if let oriDataSize = originalImage.jpegData(compressionQuality: 1)?.count {
                    resImage = resImage.zl.compress(to: oriDataSize)
                }
                
                editModel = ZLEditImageModel(
                    drawPaths: drawPaths,
                    mosaicPaths: mosaicPaths,
                    clipStatus: currentClipStatus,
                    adjustStatus: currentAdjustStatus,
                    selectFilter: currentFilter,
                    stickers: stickerStates,
                    actions: editorManager.actions
                )
                
                hud.hide()
                callback()
            }
        }
    }
}


// MARK: - 绘制
extension ZLEditImageViewController {
    /// 选择绘制颜色
    public func chooseDraw(color: UIColor) {
        currentDrawColor = color
        isEraser = false
    }
}

// MARK: - 滤镜
extension ZLEditImageViewController {
    /// 所有滤镜
    public var allFilters: [ZLFilter] {
        return ZLImageEditorConfiguration.default().filters
    }
    
    /// 设置滤镜
    public func setFilter(filter: ZLFilter) {
        editorManager.storeAction(.filter(oldFilter: currentFilter, newFilter: filter))
        changeFilter(filter)
    }
}

// MARK: - 贴纸相关（包含图片贴纸和文字贴纸）
extension ZLEditImageViewController {
    /// 添加图片贴纸(固定为ZLImageSticker类型，如果ZLImageStickerView不适用，可以自定义，使用addCustomSticker方法)
    public func addImageSticker(image: UIImage) {
        let scale = mainScrollView.zoomScale
        let size = ZLImageStickerView.calculateSize(image: image, width: view.frame.width)
        let originFrame = getStickerOriginFrame(size)
        
        let imageSticker = ZLImageStickerView(image: image, originScale: 1 / scale, originAngle: -currentClipStatus.angle, originFrame: originFrame)
        addSticker(imageSticker)
        view.layoutIfNeeded()
        
        editorManager.storeAction(.sticker(oldState: nil, newState: imageSticker.state))
    }
    
    /// 添加文字贴纸(固定为ZLTextSticker类型，如果ZLTextStickerView不适用，可以自定义，使用addCustomSticker方法)
    public func addTextSticker(font: UIFont) {
        showInputTextVC(font: font) { [weak self] text, textColor, font, image, style in
            self?.addTextStickersView(text, textColor: textColor, font: font, image: image, style: style)
        }
    }
    
    /// 添加贴纸(需要继承ZLBaseStickerView)
    public func addCustomSticker(sticker: ZLBaseStickerView) {
        addSticker(sticker)
        editorManager.storeAction(.sticker(oldState: nil, newState: sticker.state))
    }
    
    /// 删除贴纸
    public func removeSticker(sticker: ZLBaseStickerView) {
        let endState: ZLBaseStickertState? = sticker.state
        sticker.moveToAshbin()
        editorManager.storeAction(.sticker(oldState: endState, newState: nil))
        
        stickersContainer.subviews.forEach { view in
            (view as? ZLStickerViewAdditional)?.gesIsEnabled = true
        }
    }
}

// MARK: - 马赛克
extension ZLEditImageViewController {
    
}

// MARK: - 参数调整
extension ZLEditImageViewController {
    
}


extension ZLEditImageViewController {
    private func setDrawOperation() {
        
    }
}
