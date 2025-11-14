//
//  RatioToolView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/14.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

@objc protocol RatioToolViewDelegate: AnyObject {
    func RatioToolViewDidSelectItemAt(_ sender: RatioToolView,indexPath:IndexPath)
}

class RatioToolView:UIView {
    weak var delegate: RatioToolViewDelegate?
    // 点击关闭回调
    var onClose: (() -> Void)?
    private lazy var closeBtn = UIImageView().image(UIImage(named: "template-Tools-close")).enable(true).onTap { [self] in
        closeAction()
    }
    private lazy var listView = RatioScrViewList()
    private lazy var ratioCollectionView = RatioCollectionView().backgroundColor(.white)
    private let titles = [StickerManager.shared.config.General, StickerManager.shared.config.Social,StickerManager.shared.config.Print]
    var items:[[ToolsModel]] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let item00 = ToolsModel(text: "1:1",imageName: "ratio1-1")
        let item01 = ToolsModel(text: "16:9",imageName: "ratio16-9")
        let item02 = ToolsModel(text: "5:4",imageName: "ratio5-4")
        let item03 = ToolsModel(text: "7:5",imageName: "ratio7-5")
        let item04 = ToolsModel(text: "4:3",imageName: "ratio4-3")
        let item05 = ToolsModel(text: "9:16",imageName: "ratio9-16")
        let item06 = ToolsModel(text: "5:3",imageName: "ratio5-3")
        let item07 = ToolsModel(text: "3:2",imageName: "ratio3-2")
        let item08 = ToolsModel(text: "3:4",imageName: "ratio3-4")
        
        let item10 = ToolsModel(text: "Postcard",imageName: "print-00-postcard")
        let item11 = ToolsModel(text: "Poster",imageName: "print-01-poster")
        let item12 = ToolsModel(text: "Poster",imageName: "print-02-poster")
        let item13 = ToolsModel(text: "A4",imageName: "print-03-A4")
        let item14 = ToolsModel(text: "A4",imageName: "print-04-A4")
        let item15 = ToolsModel(text: "Letter",imageName: "print-05-Letter")
        let item16 = ToolsModel(text: "Letter",imageName: "print-06-Letter")
        let item17 = ToolsModel(text: "Half letter",imageName: "print-07-HLetter")
        let item18 = ToolsModel(text: "Half letter",imageName: "print-08-HLetter")
        let item19 = ToolsModel(text: "Postcard",imageName: "print-09-postcard")

        let item20 = ToolsModel(text: "Square",imageName: "social-00-square")
        let item21 = ToolsModel(text: "Portrait",imageName: "social-01-portrait")
        let item22 = ToolsModel(text: "Story",imageName: "social-02-Story")
        let item23 = ToolsModel(text: "Post",imageName: "social-03-post")
        let item24 = ToolsModel(text: "Cover",imageName: "social-04-cover")
        let item25 = ToolsModel(text: "Post",imageName: "social-05-post")
        let item26 = ToolsModel(text: "Post",imageName: "social-06-postX")
        let item27 = ToolsModel(text: "Header",imageName: "social-07-header")
        let item28 = ToolsModel(text: "YouTube",imageName: "social-08-YouTube")
        let item29 = ToolsModel(text: "Shopify",imageName: "social-09-Shopify")
        let item30 = ToolsModel(text: "Shopify",imageName: "social-10-Shopify")
        let item31 = ToolsModel(text: "Shopify",imageName: "social-11-Shopify")
        let item32 = ToolsModel(text: "Amazon",imageName: "social-12-Amazon")
        let item33 = ToolsModel(text: "Shopee",imageName: "social-13-Shopee")
        let item34 = ToolsModel(text: "Facebook",imageName: "social-14-Facebook")
        let item35 = ToolsModel(text: "Linkedin",imageName: "social-15-linkedin")
        let item36 = ToolsModel(text: "Linkedin",imageName: "social-16-linkedin")
        let item37 = ToolsModel(text: "Tiktok",imageName: "social-17-tiktok")
        let item38 = ToolsModel(text: "Tiktok",imageName: "social-18-tiktok")
        let item39 = ToolsModel(text: "Ebay",imageName: "social-19-ebay")
        let item40 = ToolsModel(text: "Poshmark",imageName: "social-20-Poshmark")
        let item41 = ToolsModel(text: "Etsy",imageName: "social-21-etsy")
        let item42 = ToolsModel(text: "Depop",imageName: "social-22-depop")

        
        items = [[item00,item01,item02,item03,item04,item05,item06,item07,item08],[item20,item21,item22,item23,item24,item25,item26,item27,item28,item29,item30,item31,item32,item33,item34,item35,item36,item37,item38,item39,item40,item41,item42],[item10,item11,item12,item13,item14,item15,item16,item17,item18,item19]]
        
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(closeBtn)
        addSubView(listView)
        addSubview(ratioCollectionView)
        closeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10.h)
            make.right.equalToSuperview().offset(-16.w)
            make.width.equalTo(55.h)
            make.height.equalTo(36.w)
        }
        listView.titles = titles
        listView.delegate = self
        listView.backgroundColor = .white
        listView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0.w)
            make.height.equalTo(closeBtn.snp.height)
            make.right.equalTo(closeBtn.snp.left)
            make.centerY.equalTo(closeBtn.snp.centerY)
        }
        
        ratioCollectionView.items = items[0]
        ratioCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(70.h)
            make.top.equalTo(closeBtn.snp.bottom).offset(20.h)
        }
        ratioCollectionView.delegate = self
    }
    
    @objc private func closeAction() {
        onClose?()  // ✅ 调用回调
    }
}

// MARK: - RatioCollectionViewDelegate
extension RatioToolView:RatioCollectionViewDelegate {
    func ratioCellDidSelectItemAt(_ sender: RatioCollectionView, indexPath: IndexPath) {
        self.delegate?.RatioToolViewDidSelectItemAt(self, indexPath: indexPath)
    }
}

// MARK: - RatioScrViewListDelegate
extension RatioToolView:RatioScrViewListDelegate {
    func ratioScrViewDidSelect(index: Int) {
        ratioCollectionView.items = items[index]
        ratioCollectionView.reload()
    }
}
