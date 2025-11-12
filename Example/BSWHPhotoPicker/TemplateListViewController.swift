////
////  TemplateListViewController.swift
////  BSWHPhotoPicker_Example
////
////  Created by 笔尚文化 on 2025/11/12.
////  Copyright © 2025 CocoaPods. All rights reserved.
////
//
//import UIKit
//import BSWHPhotoPicker
//
//
//class TemplateListViewController: UIViewController {
//
//    private var collectionView: UICollectionView!
//    private let imageNames:[String] = ["1","2","3","4","5","6","7","8"]
//    private let itemsImages:[UIImage] = [UIImage(named: "Christmas00-bg")!,UIImage(named: "Christmas01-bg")!,UIImage(named: "Christmas02-bg")!,UIImage(named: "Christmas03-bg")!,UIImage(named: "Christmas04-bg")!,UIImage(named: "Christmas05-bg")!,UIImage(named: "Christmas06-bg")!,UIImage(named: "wedding01-bg")!]
//    private let jsonFiles:[String] = ["Christmas00","Christmas01","Christmas02","Christmas03","Christmas04","Christmas05","Christmas06","Wedding00"]
//
//    var itemHeights: [CGFloat] = []  // 动态计算高度
//    private func setupCollectionView() {
//        calcImageHeights()
//        let layout = WaterfallLayout()
//        layout.columnCount = 2
//        layout.itemHeights = itemHeights
//        layout.rowSpacing = 18
//        layout.columnSpacing = 18
//        layout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
//
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
//        collectionView.backgroundColor = .white
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.register(WaterfallImageCell.self, forCellWithReuseIdentifier: "WaterfallImageCell")
//        view.addSubview(collectionView)
//        }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "模版列表"
//        view.backgroundColor = .white
//        setupCollectionView()
//    }
//    
///// ✅ 根据本地图片真实比例计算高度
//    private func calcImageHeights() {
//        let screenWidth = UIScreen.main.bounds.width
//        let columnCount: CGFloat = 2
//        let spacing: CGFloat = 8 * (columnCount + 1) // 左右 + 中间
//        let itemWidth = (screenWidth - spacing) / columnCount
//
//        for name in imageNames {
//            if let img = UIImage(named: name) {
//                let ratio = img.size.height / img.size.width
//                let height = itemWidth * ratio
//                itemHeights.append(height)
//            } else {
//                itemHeights.append(itemWidth) // fallback 正方形
//            }
//        }
//    }
//
//}
//
//extension TemplateListViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return imageNames.count
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterfallImageCell", for: indexPath) as! WaterfallImageCell
//        cell.setImage(named: imageNames[indexPath.item])
//        return cell
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension TemplateListViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = EditImageViewController(image: itemsImages[indexPath.row])
//        controller.index = indexPath.row
//        controller.modalPresentationStyle = .fullScreen
//        self.present(controller, animated: true)
//    }
//}
//
//class WaterfallImageCell: UICollectionViewCell {
//
//    private let imgView: UIImageView = {
//        let img = UIImageView()
//        img.contentMode = .scaleAspectFill // ✅ 保持比例裁切
//        img.clipsToBounds = true
//        img.layer.cornerRadius = 10
//        return img
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.addSubview(imgView)
//        imgView.frame = contentView.bounds
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setImage(named: String) {
//        imgView.image = UIImage(named: named)
//    }
//}
//
//class WaterfallLayout: UICollectionViewLayout {
//
//    var columnCount = 2            // 两列
//    var columnSpacing: CGFloat = 8 // 列间距
//    var rowSpacing: CGFloat = 8    // 行间距
//    var sectionInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
//
//    var itemHeights: [CGFloat] = [] // 外部传入的动态高度数组
//    private var attributes: [UICollectionViewLayoutAttributes] = []
//    private var contentHeight: CGFloat = 0
//
//    override func prepare() {
//        guard let collectionView = collectionView else { return }
//        attributes.removeAll()
//        contentHeight = 0
//
//        let width = collectionView.bounds.width
//        let itemWidth = (width - sectionInset.left - sectionInset.right - CGFloat(columnCount - 1) * columnSpacing) / CGFloat(columnCount)
//
//        var columnHeights = Array(repeating: sectionInset.top, count: columnCount)
//
//        for item in 0 ..< itemHeights.count {
//            let indexPath = IndexPath(item: item, section: 0)
//            let height = itemHeights[item]
//
//            // 找最短列
//            let minColumn = columnHeights.firstIndex(of: columnHeights.min()!)!
//            let x = sectionInset.left + CGFloat(minColumn) * (itemWidth + columnSpacing)
//            let y = columnHeights[minColumn]
//
//            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            attr.frame = CGRect(x: x, y: y, width: itemWidth, height: height)
//
//            attributes.append(attr)
//
//            columnHeights[minColumn] = attr.frame.maxY + rowSpacing
//            contentHeight = max(contentHeight, columnHeights[minColumn])
//        }
//    }
//
//    override var collectionViewContentSize: CGSize {
//        return CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight + sectionInset.bottom)
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        return attributes.filter { $0.frame.intersects(rect) }
//    }
//
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        return attributes[indexPath.item]
//    }
//}
