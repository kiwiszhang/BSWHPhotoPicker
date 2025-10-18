//
//  CustomStickerView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/10/17.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import BSWHPhotoPicker

/// 可缩放旋转的贴纸视图（支持单指右下角按钮操作）
class EditableStickerContainerView: UIView {
    
    private let stickerView: ZLImageStickerView
    private var resizeButton: UIButton!
    
    private var initialTransform = CGAffineTransform.identity
    private var initialPoint = CGPoint.zero
    
    var isEditing: Bool = false {
        didSet {
            resizeButton.isHidden = !isEditing
            stickerView.layer.borderWidth = isEditing ? 1 : 0
            stickerView.layer.borderColor = UIColor.systemYellow.cgColor
        }
    }
    
    init(stickerView: ZLImageStickerView) {
        self.stickerView = stickerView
        super.init(frame: stickerView.frame)
        
        addSubview(stickerView)
        setupResizeButton()
        enableTapSelection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditableStickerContainerView {
    
    func setupResizeButton() {
        resizeButton = UIButton(type: .custom)
        resizeButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle.fill"), for: .normal)
        resizeButton.tintColor = .white
        resizeButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        resizeButton.layer.cornerRadius = 15
        resizeButton.clipsToBounds = true
        resizeButton.frame = CGRect(x: bounds.width - 30, y: bounds.height - 30, width: 30, height: 30)
        resizeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        resizeButton.isHidden = true
        addSubview(resizeButton)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleResizePan(_:)))
        resizeButton.addGestureRecognizer(pan)
    }
    
    func enableTapSelection() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        isEditing.toggle()
    }
    
    @objc func handleResizePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let location = gesture.location(in: superview)
        
        switch gesture.state {
        case .began:
            initialTransform = transform
            initialPoint = location
        case .changed:
            let deltaX = location.x - center.x
            let deltaY = location.y - center.y
            let initialDeltaX = initialPoint.x - center.x
            let initialDeltaY = initialPoint.y - center.y
            
            // 比例
            let initialDistance = hypot(initialDeltaX, initialDeltaY)
            let currentDistance = hypot(deltaX, deltaY)
            let scale = currentDistance / (initialDistance == 0 ? 1 : initialDistance)
            
            // 旋转角度
            let initialAngle = atan2(initialDeltaY, initialDeltaX)
            let currentAngle = atan2(deltaY, deltaX)
            let angleDiff = currentAngle - initialAngle
            
            transform = initialTransform.scaledBy(x: scale, y: scale).rotated(by: angleDiff)
        default:
            break
        }
    }
}


