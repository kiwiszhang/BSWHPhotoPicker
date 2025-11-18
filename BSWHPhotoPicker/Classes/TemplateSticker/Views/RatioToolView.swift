//
//  RatioToolView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/14.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

struct RatioToolsModel {
    var text:String = "Text"
    var imageName:String = "template-text"
    var width:Double = 1.0
    var height:Double = 1.0
}

protocol RatioToolViewDelegate: AnyObject {
    func RatioToolViewDidSelectItemAt(_ sender: RatioToolView,indexPath:IndexPath,ratioItem:RatioToolsModel)
}

class RatioToolView:UIView {
    weak var delegate: RatioToolViewDelegate?
    // 点击关闭回调
    var onClose: (() -> Void)?
    private lazy var closeBtn = UIImageView().image(UIImage(named: "template-Tools-close")).enable(true).onTap { [self] in
        closeAction()
    }
    private lazy var listView = RatioScrViewList()
    lazy var ratioCollectionView = RatioCollectionView().backgroundColor(.white)
    private let titles = [StickerManager.shared.config.General, StickerManager.shared.config.Social,StickerManager.shared.config.Print]
    var items:[[RatioToolsModel]] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let item00 = RatioToolsModel(text: "1:1",imageName: "ratio1-1",width: 1.0,height: 1.0)
        let item01 = RatioToolsModel(text: "16:9",imageName: "ratio16-9",width: 16.0,height: 9.0)
        let item02 = RatioToolsModel(text: "5:4",imageName: "ratio5-4",width: 5.0,height: 4.0)
        let item03 = RatioToolsModel(text: "7:5",imageName: "ratio7-5",width: 7.0,height: 5.0)
        let item04 = RatioToolsModel(text: "4:3",imageName: "ratio4-3",width: 4.0,height: 3.0)
        let item05 = RatioToolsModel(text: "9:16",imageName: "ratio9-16",width: 9.0,height: 16.0)
        let item06 = RatioToolsModel(text: "5:3",imageName: "ratio5-3",width: 5.0,height: 3.0)
        let item07 = RatioToolsModel(text: "3:2",imageName: "ratio3-2",width: 3.0,height: 2.0)
        let item08 = RatioToolsModel(text: "3:4",imageName: "ratio3-4",width: 3.0,height: 4.0)
        
        let item10 = RatioToolsModel(text: "Postcard",imageName: "print-00-postcard",width: 3.0,height: 2.0)
        let item11 = RatioToolsModel(text: "Poster",imageName: "print-01-poster",width: 4.0,height: 5.0)
        let item12 = RatioToolsModel(text: "Poster",imageName: "print-02-poster",width: 5.0,height: 4.0)
        let item13 = RatioToolsModel(text: "A4",imageName: "print-03-A4",width: 1.0,height: 1.414)
        let item14 = RatioToolsModel(text: "A4",imageName: "print-04-A4",width: 1.414,height: 1.0)
        let item15 = RatioToolsModel(text: "Letter",imageName: "print-05-Letter",width: 1.0,height: 1.294)
        let item16 = RatioToolsModel(text: "Letter",imageName: "print-06-Letter",width: 1.294,height: 1.0)
        let item17 = RatioToolsModel(text: "Half letter",imageName: "print-07-HLetter",width: 1.0,height: 1.545)
        let item18 = RatioToolsModel(text: "Half letter",imageName: "print-08-HLetter",width: 1.545,height: 1.0)
        let item19 = RatioToolsModel(text: "Postcard",imageName: "print-09-postcard",width: 2.0,height: 3.0)

        let item20 = RatioToolsModel(text: "Square",imageName: "social-00-square",width: 1.0,height: 1.0)
        let item21 = RatioToolsModel(text: "Portrait",imageName: "social-01-portrait",width: 4.0,height: 5.0)
        let item22 = RatioToolsModel(text: "Story",imageName: "social-02-Story",width: 9.0,height: 16.0)
        let item23 = RatioToolsModel(text: "Post",imageName: "social-03-post",width: 1.91,height: 1.0)
        let item24 = RatioToolsModel(text: "Cover",imageName: "social-04-cover",width: 16.0,height: 9.0)
        let item25 = RatioToolsModel(text: "Post",imageName: "social-05-post",width: 2.0,height: 3.0)
        let item26 = RatioToolsModel(text: "Post",imageName: "social-06-postX",width: 16.0,height: 9.0)
        let item27 = RatioToolsModel(text: "Header",imageName: "social-07-header",width: 3.0,height: 1.0)
        let item28 = RatioToolsModel(text: "YouTube",imageName: "social-08-YouTube",width: 16.0,height: 9.0)
        let item29 = RatioToolsModel(text: "Shopify",imageName: "social-09-Shopify",width: 1.0,height: 1.0)
        let item30 = RatioToolsModel(text: "Shopify",imageName: "social-10-Shopify",width: 1.0,height: 1.1)
        let item31 = RatioToolsModel(text: "Shopify",imageName: "social-11-Shopify",width: 4.0,height: 5.0)
        let item32 = RatioToolsModel(text: "Amazon",imageName: "social-12-Amazon",width: 1.0,height: 1.0)
        let item33 = RatioToolsModel(text: "Shopee",imageName: "social-13-Shopee",width: 1.0,height: 1.0)
        let item34 = RatioToolsModel(text: "Facebook",imageName: "social-14-Facebook",width: 1.0,height: 1.0)
        let item35 = RatioToolsModel(text: "Linkedin",imageName: "social-15-linkedin",width: 1.91,height: 1.0)
        let item36 = RatioToolsModel(text: "Linkedin",imageName: "social-16-linkedin",width: 1.0,height: 1.0)
        let item37 = RatioToolsModel(text: "Tiktok",imageName: "social-17-tiktok",width: 9.0,height: 16.0)
        let item38 = RatioToolsModel(text: "Tiktok",imageName: "social-18-tiktok",width: 1.0,height: 1.0)
        let item39 = RatioToolsModel(text: "Ebay",imageName: "social-19-ebay",width: 1.0,height: 1.0)
        let item40 = RatioToolsModel(text: "Poshmark",imageName: "social-20-Poshmark",width: 1.0,height: 1.0)
        let item41 = RatioToolsModel(text: "Etsy",imageName: "social-21-etsy",width: 5.0,height: 4.0)
        let item42 = RatioToolsModel(text: "Depop",imageName: "social-22-depop",width: 1.0,height: 1.0)

        
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
    func ratioCellDidSelectItemAt(_ sender: RatioCollectionView, indexPath: IndexPath,item:RatioToolsModel) {
        self.delegate?.RatioToolViewDidSelectItemAt(self, indexPath: indexPath,ratioItem: item)
    }
}

// MARK: - RatioScrViewListDelegate
extension RatioToolView:RatioScrViewListDelegate {
    func ratioScrViewDidSelect(index: Int) {
        ratioCollectionView.items = items[index]
        ratioCollectionView.currentIndex = index
        ratioCollectionView.reload()
    }
}
