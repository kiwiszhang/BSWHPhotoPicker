//
//  TemplateTopView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/13.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

@objc protocol TemplateTopViewDelegate: AnyObject {
    func closeTemplate(_ sender: TemplateTopView)
    func backTemplate(_ sender: TemplateTopView)
    func reBackTemplate(_ sender: TemplateTopView)
    func saveTemplate(_ sender: TemplateTopView)
}

class TemplateTopView: SuperView {

    weak var delegate: TemplateTopViewDelegate?
    private lazy var closeImg = UIImageView().image(BSWHBundle.image(named: "template-close")).enable(true).onTap { [self] in
        delegate?.closeTemplate(self)
    }
    lazy var backImg = UIImageView().image(BSWHBundle.image(named: "template-back")).enable(true).onTap { [self] in
        delegate?.backTemplate(self)
    }
    lazy var rebackImg = UIImageView().image(BSWHBundle.image(named: "template-reBack")).enable(true).onTap { [self] in
        delegate?.reBackTemplate(self)
    }
    private lazy var saveBtn = UILabel().text(StickerManager.shared.config.save).backgroundColor(kkColorFromHex("A216FF")).color(.white).centerAligned().hnFont(size: 14.h, weight: .boldBase).cornerRadius(8.h).onTap { [self] in
        delegate?.saveTemplate(self)
    }
    override func setUpUI() {
        addChildView([closeImg,backImg,rebackImg,saveBtn])
        closeImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8.w)
            make.bottom.equalToSuperview().offset(-10.h)
            make.height.width.equalTo(24.h)
        }
        backImg.snp.makeConstraints { make in
            make.top.equalTo(closeImg.snp.top)
            make.centerX.equalToSuperview().offset(-30.w)
            make.height.width.equalTo(24.h)
        }
        rebackImg.snp.makeConstraints { make in
            make.top.equalTo(closeImg.snp.top)
            make.centerX.equalToSuperview().offset(30.w)
            make.height.width.equalTo(24.h)
        }
        saveBtn.snp.makeConstraints { make in
            make.width.equalTo(55.w)
            make.height.equalTo(30.h)
            make.centerY.equalTo(closeImg.snp.centerY)
            make.right.equalToSuperview().offset(-20.w)
        }
    }
 

}
