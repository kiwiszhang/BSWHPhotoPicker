//
//  ReplaceBgView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/11.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class ReplaceBgView:UIView {
    // 点击关闭回调
    var onClose: (() -> Void)?

    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("✕", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var bgView:UIView = {
        let v = UIView()
        v.backgroundColor = .systemTeal
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0.w)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(70.h)
        }
        // ✅ 添加关闭按钮
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
    }
    
    @objc private func closeAction() {
        onClose?()  // ✅ 调用回调
    }
}
