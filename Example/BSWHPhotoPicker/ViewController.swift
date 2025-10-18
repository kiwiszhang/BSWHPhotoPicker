//
//  ViewController.swift
//  BSWHPhotoPicker
//
//  Created by caoguangming on 09/11/2025.
//  Copyright (c) 2025 caoguangming. All rights reserved.
//

public let kkScreenWidth = UIScreen.main.bounds.size.width
public let kkScreenHeight = UIScreen.main.bounds.size.height


import UIKit
import BSWHPhotoPicker

class ViewController: UIViewController {

    private var collectionView: UICollectionView!
    private let items:[UIImage] = [UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!,UIImage(named: "4")!,UIImage(named: "5")!,UIImage(named: "6")!,UIImage(named: "7")!]
    private let itemsImages:[UIImage] = [UIImage(named: "Christmas00-bg")!,UIImage(named: "Christmas01-bg")!,UIImage(named: "Christmas02-bg")!,UIImage(named: "Christmas03-bg")!,UIImage(named: "Christmas04-bg")!,UIImage(named: "Christmas05-bg")!,UIImage(named: "Christmas06-bg")!]
    private let jsonFiles:[String] = ["Christmas00","Christmas01","Christmas02","Christmas03","Christmas04","Christmas05","Christmas06"]

    
    private lazy var imageSticker:ZLImageStickerState = ZLImageStickerState(
        id: UUID().uuidString,
        image: .init(named: "Christmas-Tree")!,
        originScale: 1,
        originAngle: 0,
        originFrame: CGRect(x: 194, y: 370, width: 157, height: 240),
        gesScale: 1,
        gesRotation: 0,
        totalTranslationPoint: .zero
    )
    
    private lazy var textSticker: ZLTextStickerState = {
        let textColor = UIColor.systemTeal
        let text = "KIWI"
        let font = UIFont.systemFont(ofSize: 23, weight: .bold)
        let attributes = [NSAttributedString.Key.font: font]
        let textSize = (text as NSString).size(withAttributes: attributes)
        let size = CGSize(width: textSize.width + 20, height: textSize.height + 10)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraph
            ]
            let textRect = CGRect(origin: .zero, size: size)
            text.draw(in: textRect, withAttributes: attrs)
        }
        return ZLTextStickerState(
            id: UUID().uuidString,
            text: text,
            textColor: textColor,
            font: font,
            style: .normal,
            image: image,
            originScale: 1,
            originAngle: 0,
            originFrame: CGRect(x: 0, y: 0, width: 200, height: 50),
            gesScale: 1,
            gesRotation: 0,
            totalTranslationPoint: .zero
        )
    }()

    private func setupCollectionView() {
            let layout = UICollectionViewFlowLayout()
            let spacing: CGFloat = 20
            let width = (view.bounds.width - spacing * 3) / 2
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumLineSpacing = spacing
            layout.minimumInteritemSpacing = spacing
            layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
            collectionView.backgroundColor = .white
            collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "MyCollectionViewCell")
            collectionView.dataSource = self
            collectionView.delegate = self
            view.addSubview(collectionView)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stickerArr = StickerManager.shared.makeStickerStates(from: jsonFiles[indexPath.row])
//        let controller = EditImageViewController(image: itemsImages[indexPath.row], editModel: .init(stickers: stickerArr))
        let controller = EditImageViewController(image: itemsImages[indexPath.row])
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
}

class MyCollectionViewCell: UICollectionViewCell {
    static let reuseId = "MyCollectionViewCell"
    
    private let imageV = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(imageV)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageV.frame = contentView.bounds
        imageV.contentMode = .scaleAspectFit
    }
    
    func configure(with image: UIImage) {
        imageV.image = image
    }
}
