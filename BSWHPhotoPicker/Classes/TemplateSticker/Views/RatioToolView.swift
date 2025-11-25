//
//  RatioToolView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/14.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

protocol RatioToolViewDelegate: AnyObject {
    func RatioToolViewDidSelectItemAt(_ sender: RatioToolView,indexPath:IndexPath,ratioItem:RatioToolsModel)
}

class RatioToolView:UIView {
    weak var delegate: RatioToolViewDelegate?
    // 点击关闭回调
    var onClose: (() -> Void)?
    private lazy var closeBtn = UIImageView().image(BSWHBundle.image(named: "template-Tools-close")).enable(true).onTap { [self] in
        closeAction()
    }
    private lazy var listView = RatioScrViewList()
    lazy var ratioCollectionView = RatioCollectionView().backgroundColor(.white)
    private let titles = [BSWHPhotoPickerLocalization.shared.localized("General"),
                          BSWHPhotoPickerLocalization.shared.localized("Social"),
                          BSWHPhotoPickerLocalization.shared.localized("Print")]
    var items:[[RatioToolsModel]] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        items = ConfigDataItem.getRatioToolsData()
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
