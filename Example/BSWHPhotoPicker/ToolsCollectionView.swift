//
//  ToolsCollectionView.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/10.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit


@objc protocol ToolsCollectionViewDelegate: AnyObject {
    func cellDidSelectItemAt(_ sender: ToolsCollectionView,indexPath:IndexPath)
}

class ToolsCollectionView: UIView {
    weak var delegate: ToolsCollectionViewDelegate?
    var scannedImages: [String] = ["替换背景","弹框测试","修改比例1:1","修改比例4:5","修改比例9:16"]
    var currentIndex: Int = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.showsHorizontalScrollIndicator = false
        cv.register(ToolCollectionViewCell.self, forCellWithReuseIdentifier: "ToolCollectionViewCell")
        return cv
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
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0.w)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(120.h)
        }
        reload()
    }

    func reload() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension ToolsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scannedImages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ToolCollectionViewCell",
            for: indexPath
        ) as! ToolCollectionViewCell
        cell.configure(with: scannedImages[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ToolsCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120.w, height: 120.h)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.cellDidSelectItemAt(self, indexPath: indexPath)
    }
}


class ToolCollectionViewCell: UICollectionViewCell {
        
    private lazy var containerView = UIView()
    lazy var imgView = UIImageView()
    lazy var titleLab = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in make.edges.equalToSuperview() }

        titleLab.text = "CCCC"
        titleLab.textColor = .systemRed
       
        containerView.addSubview(imgView)
        containerView.addSubview(titleLab)

        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 46.h, height: 46.h))
        }

        titleLab.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(20.h)
        }
    }


    func configure(with item: String) {
        titleLab.text = item
    }
}
