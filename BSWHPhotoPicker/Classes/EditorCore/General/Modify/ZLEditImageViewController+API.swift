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


public class EditableStickerView: ZLImageStickerView {

    // MARK: - UI
    private var resizeButton: UIButton!

    // MARK: - gesture / state
    private var initialTouchPoint: CGPoint = .zero
    private var initialTransform: CGAffineTransform = .identity

    // 起始向量/角度/距离（中心 -> 手指）
    private var initialVector: CGPoint = .zero
    private var initialDistance: CGFloat = 0
    private var initialAngle: CGFloat = 0

    // 平移用状态
    private var panStartTransform: CGAffineTransform = .identity
    private var panStartTouchPoint: CGPoint = .zero

    // 标志：按钮在 superview 层级上（overlay）
    private var overlaySuperview: UIView? { superview }

    // MARK: - 编辑状态
    public var isEditingCustom: Bool = false {
        didSet {
            resizeButton.isHidden = !isEditingCustom
            if isEditingCustom {
                overlaySuperview?.bringSubviewToFront(resizeButton)
            }
        }
    }

    // MARK: - 初始化
    init(image: UIImage, originScale: CGFloat, originAngle: CGFloat, originFrame: CGRect) {
        super.init(image: image,
                   originScale: originScale,
                   originAngle: originAngle,
                   originFrame: originFrame)
        setupResizeButtonLocal()
        enableTapSelection()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup UI
    private func setupResizeButtonLocal() {
        let size: CGFloat = 36
        resizeButton = UIButton(type: .custom)
        resizeButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        resizeButton.layer.cornerRadius = size / 2
        resizeButton.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        resizeButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle.fill"), for: .normal)
        resizeButton.tintColor = .white
        resizeButton.isHidden = true

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleResizePan(_:)))
        pan.delegate = self
        resizeButton.addGestureRecognizer(pan)
    }

    private func enableTapSelection() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        isEditingCustom.toggle()
        syncResizeButtonToOverlay()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        syncResizeButtonToOverlay()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateResizeButtonPosition()
    }

    private func syncResizeButtonToOverlay() {
        guard let overlay = overlaySuperview else { return }
        if resizeButton.superview != overlay {
            resizeButton.removeFromSuperview()
            overlay.addSubview(resizeButton)
        }
        updateResizeButtonPosition()
    }

    private func updateResizeButtonPosition() {
        guard let overlay = overlaySuperview else { return }
        let bottomRightInOverlay = self.convert(CGPoint(x: bounds.width, y: bounds.height), to: overlay)
        resizeButton.center = bottomRightInOverlay
    }

    // MARK: - Resize Pan (旋转 + 缩放)
    @objc private func handleResizePan(_ gesture: UIPanGestureRecognizer) {
        guard let overlay = overlaySuperview else { return }

        let centerInOverlay = self.convert(CGPoint(x: bounds.midX, y: bounds.midY), to: overlay)
        let touchPoint = gesture.location(in: overlay)

        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
            initialTransform = originTransform
            initialVector = CGPoint(x: touchPoint.x - centerInOverlay.x, y: touchPoint.y - centerInOverlay.y)
            initialDistance = hypot(initialVector.x, initialVector.y)
            initialAngle = atan2(initialVector.y, initialVector.x)
            setOperation(true)

        case .changed:
            let currentVector = CGPoint(x: touchPoint.x - centerInOverlay.x, y: touchPoint.y - centerInOverlay.y)
            let currentDistance = hypot(currentVector.x, currentVector.y)
            let currentAngle = atan2(currentVector.y, currentVector.x)

            let angleDiff = currentAngle - initialAngle
            let scale = initialDistance > 0 ? currentDistance / initialDistance : 1.0

            transform = initialTransform.rotated(by: angleDiff).scaledBy(x: scale, y: scale)
            updateResizeButtonPosition()

        case .ended, .cancelled:
            originTransform = transform
            initialTransform = originTransform
            gesRotation = 0
            gesScale = 1
            updateResizeButtonPosition()
            setOperation(false)
        default:
            break
        }
    }

    // MARK: - 平移 (优化后更平滑)
    @objc override func panAction(_ ges: UIPanGestureRecognizer) {
        guard gesIsEnabled else { return }

        switch ges.state {
        case .began:
            panStartTransform = originTransform
            panStartTouchPoint = ges.location(in: superview)
            setOperation(true)

        case .changed:
            guard let superview = superview else { return }
            let currentPoint = ges.location(in: superview)

            // 位移量（全局坐标）
            let dx = currentPoint.x - panStartTouchPoint.x
            let dy = currentPoint.y - panStartTouchPoint.y

            // 将位移量映射到当前旋转角度的局部坐标中
            let rotation = atan2(panStartTransform.b, panStartTransform.a)
            let cosA = cos(rotation)
            let sinA = sin(rotation)

            // 修正后位移，使旋转后方向仍然正确
            let localDx = dx * cosA + dy * sinA
            let localDy = dy * cosA - dx * sinA

            transform = panStartTransform.translatedBy(x: localDx, y: localDy)
            updateResizeButtonPosition()

        case .ended, .cancelled:
            originTransform = transform
            setOperation(false)

        default:
            break
        }
    }

    public func refreshResizeButtonPosition() {
        syncResizeButtonToOverlay()
        updateResizeButtonPosition()
    }

    public override func removeFromSuperview() {
        resizeButton.removeFromSuperview()
        super.removeFromSuperview()
    }

    deinit {
        resizeButton.removeFromSuperview()
    }

    // MARK: - UIGestureRecognizerDelegate
    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == resizeButton || otherGestureRecognizer.view == resizeButton {
            return false
        }
        return true
    }
}


