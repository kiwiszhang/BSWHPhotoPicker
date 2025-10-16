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

    @IBOutlet weak var testImageView: UIImageView!
    private var stickerArr:[ZLImageStickerState] = []
    
//    private lazy var imageSticker:ZLImageStickerState = ZLImageStickerState(
//        id: UUID().uuidString,
//        image: .init(named: "bg-00-header")!,
//        originScale: 1,
//        originAngle: 0,
//        originFrame: CGRect(x: 0, y: 0, width: kkScreenWidth, height: 200),
//        gesScale: 1,
//        gesRotation: 0,
//        totalTranslationPoint: .zero
//    )
    private lazy var imageSticker01:ZLImageStickerState = ZLImageStickerState(
        id: UUID().uuidString,
        image: .init(named: "imageSticker-bg-white")!,
        originScale: 1,
        originAngle: 0,
        originFrame: CGRect(x: 40, y: 145, width: 162, height: 207),
        gesScale: 1,
        gesRotation: 0,
        totalTranslationPoint: .zero
    )
    
    private lazy var imageSticker02:ZLImageStickerState = ZLImageStickerState(
        id: UUID().uuidString,
        image: .init(named: "imageSticker-bg-white")!,
        originScale: 1,
        originAngle: 0,
        originFrame: CGRect(x: 182, y: 176, width: 176, height: 229),
        gesScale: 1,
        gesRotation: 0,
        totalTranslationPoint: .zero
    )

    private lazy var imageSticker03:ZLImageStickerState = ZLImageStickerState(
        id: UUID().uuidString,
        image: .init(named: "imageSticker-bg-yellow")!,
        originScale: 1,
        originAngle: 0,
        originFrame: CGRect(x: 66, y: 319, width: 165, height: 207),
        gesScale: 1,
        gesRotation: 0,
        totalTranslationPoint: .zero
    )
    
    private lazy var imageSticker04:ZLImageStickerState = ZLImageStickerState(
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        testImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        testImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func onTapImage(_ gesture: UITapGestureRecognizer) {
        if let image = testImageView.image {
            stickerArr = StickerManager.shared.makeStickerStates(from: "Christmas02")
            let controller = EditImageViewController(image: image, editModel: .init(stickers: stickerArr))
//            let controller = EditImageViewController(image: image, editModel: .init(stickers: [imageSticker,imageSticker01,imageSticker02,imageSticker03,imageSticker04]))
//            let controller = EditImageViewController(image: image, editModel: .init(stickers: [textSticker]))
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
        
    }

}

