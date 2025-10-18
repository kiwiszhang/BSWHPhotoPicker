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

    public func addImageSticker01(state: ImageStickerModel) {
        let imageSticker = EditableStickerView(image: UIImage(named: state.image)!, originScale: state.originScale, originAngle: state.originAngle, originFrame: CGRect(x: state.originFrameX, y: state.originFrameY, width: state.originFrameWidth, height: state.originFrameHeight))
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

// MARK: - 模型定义
public struct ImageStickerModel: Codable {
    let image:String
    let originScale:Double
    let originAngle:Double
    let originFrameX:Double
    let originFrameY:Double
    let originFrameWidth:Double
    let originFrameHeight:Double
    let gesScale:Double
    let gesRotation:Double
    let overlayRectX:Double?
    let overlayRectY:Double?
    let overlayRectWidth:Double?
    let overlayRectHeight:Double?
    let isCircle:Bool?
}

class EditableStickerView: ZLImageStickerView {

    private var resizeButton: UIButton!
    private var initialTouchPoint = CGPoint.zero
    private var initialGesRotation: CGFloat = 0
    private var initialGesScale: CGFloat = 1.0

    var isEditing: Bool = false {
        didSet { resizeButton.isHidden = !isEditing }
    }

    init(image: UIImage, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect) {
        super.init(image: image, originScale: originScale, originAngle: originAngle, originFrame: originFrame)
        setupResizeButton()
        enableTapSelection()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupResizeButton() {
        let size: CGFloat = 32
        resizeButton = UIButton(type: .custom)
        resizeButton.frame = CGRect(x: bounds.width - size, y: bounds.height - size, width: size, height: size)
        resizeButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle.fill"), for: .normal)
        resizeButton.tintColor = .systemRed
        resizeButton.backgroundColor = .systemTeal.withAlphaComponent(0.3)
        resizeButton.layer.cornerRadius = size / 2
        resizeButton.isHidden = true
        resizeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        addSubview(resizeButton)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleResizePan(_:)))
        resizeButton.addGestureRecognizer(pan)
    }

    private func enableTapSelection() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        isEditing.toggle()
    }

    @objc private func handleResizePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let location = gesture.location(in: superview)

        switch gesture.state {
        case .began:
            initialTouchPoint = location
            initialGesRotation = gesRotation
            initialGesScale = gesScale
            setOperation(true)

        case .changed:
            let center = self.center
            let dx = location.x - center.x
            let dy = location.y - center.y
            let originDx = initialTouchPoint.x - center.x
            let originDy = initialTouchPoint.y - center.y

            // 🔹 以贴纸中心点为基准计算旋转角度差
            let angleDiff = atan2(dy, dx) - atan2(originDy, originDx)
            gesRotation = initialGesRotation + angleDiff

            // 🔹 以贴纸中心点为基准计算缩放比例
            let currentDistance = sqrt(dx * dx + dy * dy)
            let originDistance = sqrt(originDx * originDx + originDy * originDy)
            let scaleChange = currentDistance / max(originDistance, 1)
            gesScale = max(0.2, min(initialGesScale * scaleChange, maxGesScale))

            // 🔹 应用变化
            updateTransform()

        case .ended, .cancelled:
            setOperation(false)

        default:
            break
        }
    }
}



