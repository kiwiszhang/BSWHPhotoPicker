//
//  ReplaceBgView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/11.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

@objc protocol StickerToolsViewDelegate: AnyObject {
    func stickerToolDidSelectItemAt(_ sender: StickerToolsView,indexPath:IndexPath)
}

class StickerToolsView:UIView {
    weak var delegate: StickerToolsViewDelegate?
    // 点击关闭回调
    var onClose: (() -> Void)?
    private lazy var closeBtn = UIImageView().image(BSWHBundle.image(named: "template-Tools-close")).enable(true).onTap { [self] in
        closeAction()
    }
    private lazy var toolCollectionView = StickerToolsCollectionView().backgroundColor(.white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(closeBtn)
        addSubview(toolCollectionView)
        closeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.h)
            make.right.equalToSuperview().offset(-16.w)
            make.width.equalTo(55.h)
            make.height.equalTo(36.w)
        }
        toolCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(70.h)
            make.top.equalTo(closeBtn.snp.bottom).offset(0.h)
        }
        toolCollectionView.delegate = self
    }
    
    @objc private func closeAction() {
        onClose?()  // ✅ 调用回调
    }
}

// MARK: - StickerToolsCollectionViewDelegate
extension StickerToolsView:StickerToolsCollectionViewDelegate {
    func stickerCellDidSelectItemAt(_ sender: StickerToolsCollectionView, indexPath: IndexPath) {
        self.delegate?.stickerToolDidSelectItemAt(self, indexPath: indexPath)
    }
    
    
}
