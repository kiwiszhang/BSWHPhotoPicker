//
//  TemplateViewController.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

struct TemplateModel {
    var imageName:String = "1"
    var imageBg:String = "Christmas00-bg"
    var jsonName:String = "Christmas00"
}


class TemplateViewController: UIViewController, UIScrollViewDelegate {
    
    let tabView = CustomScrViewList()
    var collectionView: UICollectionView!
    private let titles = ["ALL", "Christmas"]
    var items:[[TemplateModel]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let item00 = TemplateModel(imageName: "1",imageBg: "Christmas00-bg",jsonName: "Christmas00")
        let item01 = TemplateModel(imageName: "2",imageBg: "Christmas01-bg",jsonName: "Christmas01")
        let item02 = TemplateModel(imageName: "3",imageBg: "Christmas02-bg",jsonName: "Christmas02")
        let item03 = TemplateModel(imageName: "4",imageBg: "Christmas03-bg",jsonName: "Christmas03")
        let item04 = TemplateModel(imageName: "5",imageBg: "Christmas04-bg",jsonName: "Christmas04")
        let item05 = TemplateModel(imageName: "6",imageBg: "Christmas05-bg",jsonName: "Christmas05")
        let item06 = TemplateModel(imageName: "7",imageBg: "Christmas06-bg",jsonName: "Christmas06")

        items = [[item00,item01,item02,item03,item04,item05,item06],[item00,item01,item02,item03,item04,item05,item06]]
        
        setupTabView()
        setupCollectionView()
    }
    
    private func setupTabView() {
        tabView.titles = titles
        tabView.delegate = self
        view.addSubview(tabView)
        tabView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().offset(24.w)
            make.right.equalToSuperview()
            make.height.equalTo(44.h)
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height - 44 - view.safeAreaInsets.top)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ContentCell.self, forCellWithReuseIdentifier: "ContentCell")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(tabView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - =====================actions==========================
   
    
    // MARK: - =====================delegate==========================
    
    
    // MARK: - =====================Deinit==========================

}

// MARK: - UICollectionViewDataSource & Delegate
extension TemplateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as! ContentCell
        cell.delegate = self
        cell.items = items[indexPath.row]
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        tabView.selectIndex(index: page, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        tabView.selectIndex(index: page, animated: true)
    }
}

// MARK: - CustomScrViewListDelegate
extension TemplateViewController: CustomScrViewListDelegate {
    func scrViewDidSelect(index: Int) {
        collectionView.layoutIfNeeded()
        if let attributes = collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0)) {
            collectionView.scrollRectToVisible(attributes.frame, animated: true)
        }
    }
}

extension TemplateViewController: ContentCellDelegate {
    func contentCell(_ cell: ContentCell, didSelectItem item: TemplateModel, at index: Int) {
        guard let image = UIImage(named: item.imageBg) else { return }
        let controller = EditImageViewController(image: image)
        controller.index = index
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
}



protocol ContentCellDelegate: AnyObject {
    func contentCell(_ cell: ContentCell, didSelectItem item: TemplateModel, at index: Int)
}

// MARK: - UICollectionViewCell
class ContentCell: UICollectionViewCell {
    
    private var collectionView: UICollectionView!
    private var layout: WaterfallLayout!
    weak var delegate: ContentCellDelegate?

    var items: [TemplateModel] = [] {
        didSet {
            // ✅ 每次更新都清空旧高度
            itemHeights = []
            calculateItemHeights()
            reloadCollectionView()
        }
    }
    
    private var itemHeights: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionViewIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView Setup
    
    private func setupCollectionViewIfNeeded() {
        guard collectionView == nil else { return }
        
        layout = WaterfallLayout()
        layout.columnCount = 2
        layout.columnSpacing = 18
        layout.rowSpacing = 18
        layout.sectionInset = UIEdgeInsets(top: 12, left: 8, bottom: 8, right: 8)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemCyan
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(WaterfallImageCell.self, forCellWithReuseIdentifier: "WaterfallImageCell")
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func reloadCollectionView() {
        layout.itemHeights = itemHeights
        layout.invalidateLayout()
        collectionView.reloadData()
        collectionView.layoutIfNeeded() // ✅ 保证第一次显示就正确
    }
    
    // MARK: - Calculate Item Heights
    
    private func calculateItemHeights() {
        let screenWidth = UIScreen.main.bounds.width
        let columnCount: CGFloat = CGFloat(layout.columnCount)
        let spacing: CGFloat = layout.sectionInset.left + layout.sectionInset.right + layout.columnSpacing * (columnCount - 1)
        let itemWidth = (screenWidth - spacing) / columnCount
        
        for item in items {
            if let img = UIImage(named: item.imageName) {
                let ratio = img.size.height / img.size.width
                let height = itemWidth * ratio
                itemHeights.append(height)
            } else {
                itemHeights.append(itemWidth) // fallback: 正方形
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ContentCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterfallImageCell", for: indexPath) as! WaterfallImageCell
        cell.setItem(item: items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.contentCell(self, didSelectItem: item, at: indexPath.row)
    }

}

class WaterfallImageCell: UICollectionViewCell {

    private let imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // ✅ 保持比例裁切
        img.clipsToBounds = true
        img.layer.cornerRadius = 10
        return img
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgView)
        imgView.frame = contentView.bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setItem(item: TemplateModel) {
        imgView.image = UIImage(named: item.imageName)
    }
}

class WaterfallLayout: UICollectionViewLayout {

    var columnCount = 2            // 两列
    var columnSpacing: CGFloat = 8 // 列间距
    var rowSpacing: CGFloat = 8    // 行间距
    var sectionInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

    var itemHeights: [CGFloat] = [] // 外部传入的动态高度数组
    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0

    override func prepare() {
        guard let collectionView = collectionView else { return }
        attributes.removeAll()
        contentHeight = 0

        let width = collectionView.bounds.width
        let itemWidth = (width - sectionInset.left - sectionInset.right - CGFloat(columnCount - 1) * columnSpacing) / CGFloat(columnCount)

        var columnHeights = Array(repeating: sectionInset.top, count: columnCount)

        for item in 0 ..< itemHeights.count {
            let indexPath = IndexPath(item: item, section: 0)
            let height = itemHeights[item]

            // 找最短列
            let minColumn = columnHeights.firstIndex(of: columnHeights.min()!)!
            let x = sectionInset.left + CGFloat(minColumn) * (itemWidth + columnSpacing)
            let y = columnHeights[minColumn]

            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attr.frame = CGRect(x: x, y: y, width: itemWidth, height: height)

            attributes.append(attr)

            columnHeights[minColumn] = attr.frame.maxY + rowSpacing
            contentHeight = max(contentHeight, columnHeights[minColumn])
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight + sectionInset.bottom)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
}
