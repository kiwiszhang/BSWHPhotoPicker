//
//  CustomStickerView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/10/17.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import BSWHPhotoPicker

/// 可缩放旋转的贴纸容器视图
//class EditableStickerContainerView: UIView {
//
//    private let stickerView: ZLImageStickerView
//    private var resizeButton: UIButton!
//
//    private var currentTransform: CGAffineTransform = .identity
//    private var initialTouchPoint: CGPoint = .zero
//    private var initialScale: CGFloat = 1
//    private var initialRotation: CGFloat = 0
//
//    private var isResizing = false
//
//    var isEditing: Bool = false {
//        didSet {
//            resizeButton.isHidden = !isEditing
//            stickerView.layer.borderWidth = isEditing ? 1 : 0
//            stickerView.layer.borderColor = UIColor.systemYellow.cgColor
//        }
//    }
//
//    init(stickerView: ZLImageStickerView) {
//        self.stickerView = stickerView
//        super.init(frame: stickerView.frame)
//
//        addSubview(stickerView)
//        setupResizeButton()
//        enableTapSelection()
//        setupPanGesture()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//// MARK: - Setup
//private extension EditableStickerContainerView {
//
//    func setupResizeButton() {
//        resizeButton = UIButton(type: .custom)
//        resizeButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle.fill"), for: .normal)
//        resizeButton.tintColor = .white
//        resizeButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        resizeButton.layer.cornerRadius = 15
//        resizeButton.clipsToBounds = true
//        resizeButton.frame = CGRect(x: bounds.width - 30, y: bounds.height - 30, width: 30, height: 30)
//        resizeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
//        resizeButton.isHidden = true
//        addSubview(resizeButton)
//
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleResizePan(_:)))
//        pan.delegate = self
//        resizeButton.addGestureRecognizer(pan)
//    }
//
//    func enableTapSelection() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        addGestureRecognizer(tap)
//    }
//
//    func setupPanGesture() {
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPan(_:)))
//        pan.delegate = self
//        addGestureRecognizer(pan)
//    }
//
//    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//        isEditing.toggle()
//    }
//}
//
//// MARK: - 移动手势
//private extension EditableStickerContainerView {
//
//    @objc func handleStickerPan(_ gesture: UIPanGestureRecognizer) {
//        guard !isResizing else { return }
//
//        let translation = gesture.translation(in: superview)
//        switch gesture.state {
//        case .began, .changed:
//            // 在当前 transform 基础上平移
//            transform = currentTransform.translatedBy(x: translation.x, y: translation.y)
//        case .ended, .cancelled:
//            currentTransform = transform
//        default: break
//        }
//    }
//}
//
//// MARK: - 缩放旋转手势（右下角按钮）
//private extension EditableStickerContainerView {
//
//    @objc func handleResizePan(_ gesture: UIPanGestureRecognizer) {
//        guard let superview = superview else { return }
//        let location = gesture.location(in: superview)
//
//        switch gesture.state {
//        case .began:
//            isResizing = true
//            initialTouchPoint = location
//            initialScale = 1
//            initialRotation = 0
//
//        case .changed:
//            // 计算相对于左上角的向量
//            let origin = frame.origin
//            let dxStart = initialTouchPoint.x - origin.x
//            let dyStart = initialTouchPoint.y - origin.y
//            let dxNow = location.x - origin.x
//            let dyNow = location.y - origin.y
//
//            // 缩放比例
//            let distanceStart = hypot(dxStart, dyStart)
//            let distanceNow = hypot(dxNow, dyNow)
//            let scale = distanceStart > 0 ? distanceNow / distanceStart : 1
//
//            // 旋转角度
//            let angleDiff = atan2(dyNow, dxNow) - atan2(dyStart, dxStart)
//
//            // 应用旋转 + 缩放
//            transform = currentTransform.rotated(by: angleDiff).scaledBy(x: scale, y: scale)
//
//            // 右下角按钮跟随手指
//            resizeButton.center = CGPoint(x: dxNow, y: dyNow)
//
//        case .ended, .cancelled:
//            // 保存累积 transform
//            currentTransform = transform
//            isResizing = false
//
//            // 恢复按钮到右下角
//            resizeButton.frame.origin = CGPoint(
//                x: bounds.width - resizeButton.bounds.width,
//                y: bounds.height - resizeButton.bounds.height
//            )
//
//        default: break
//        }
//    }
//}
//
//// MARK: - UIGestureRecognizerDelegate
//extension EditableStickerContainerView: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}

