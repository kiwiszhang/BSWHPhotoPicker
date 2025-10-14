//
//  ViewController.swift
//  BSWHPhotoPicker
//
//  Created by caoguangming on 09/11/2025.
//  Copyright (c) 2025 caoguangming. All rights reserved.
//

import UIKit
import BSWHPhotoPicker

class ViewController: UIViewController {

    @IBOutlet weak var testImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        testImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func onTapImage(_ gesture: UITapGestureRecognizer) {
        if let image = testImageView.image {
            let controller = EditImageViewController(image: image, editModel: .init(stickers: [ZLImageStickerState(
                id: UUID().uuidString,
                image: .init(named: "imageSticker")!,
                originScale: 1,
                originAngle: 90,
                originFrame: CGRect(x: 100, y: 100, width: 100, height: 100),
                gesScale: 1,
                gesRotation: 0,
                totalTranslationPoint: .zero
            )]))
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
        
    }
    

}

