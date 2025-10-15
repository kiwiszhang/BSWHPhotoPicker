//
//  EditImageViewController.swift
//  BSWHPhotoPicker_Example
//
//  Created by bswh on 2025/9/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import BSWHPhotoPicker
import SnapKit
import PhotosUI

class EditImageViewController: ZLEditImageViewController {
    
    private weak var currentStickerView: ZLImageStickerView?   // 保存当前点击的贴纸
    
    let nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    let lastButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("上一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    let menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("菜单", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(nextButton)
        view.addSubview(lastButton)
        view.addSubview(menuButton)
        
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalTo(-40)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        lastButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalTo(-40)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        nextButton.addTarget(self, action: #selector(onClickNext(_:)), for: .touchUpInside)
        lastButton.addTarget(self, action: #selector(onClickLast(_:)), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(onClickMenu(_:)), for: .touchUpInside)
        
        setupTapGestureForStickers()
        setupTapGestureForStickersPeriodically()

    }
    
    @objc private func onClickNext(_ sender: UIButton) {
        if canRedo {
            redoAction()
        }
    }
    
    @objc private func onClickLast(_ sender: UIButton) {
        if canUndo {
            undoAction()
        }
    }
    
    @objc private func onClickMenu(_ sender: UIButton) {
        let alert = UIAlertController(title: "菜单", message: nil, preferredStyle: .actionSheet)
        /// 绘制
        let drawAction = UIAlertAction(title: "Draw", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.switchOperation(type: .draw)
        }
        /// 马赛克
        let mosaicAction = UIAlertAction(title: "mosaic", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.switchOperation(type: .mosaic)
        }
        
        /// 文字贴纸
        let textStickerAction = UIAlertAction(title: "文字贴纸", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.switchOperation(type: .textSticker)
            self.addTextSticker(font: UIFont.systemFont(ofSize: 20))
        }
        
        let imageStickerAction = UIAlertAction(title: "添加图片贴纸", style: .default) { [weak self] _ in
            if let image = UIImage(named: "imageSticker") {
                self?.switchOperation(type: .imageSticker)
                self?.addImageSticker(image: image)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(drawAction)
        alert.addAction(mosaicAction)
        alert.addAction(textStickerAction)
        alert.addAction(imageStickerAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func setupTapGestureForStickersPeriodically() {
        // 每次视图出现后，每隔 0.5s 检查一次贴纸状态
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.setupTapGestureForStickers()
        }
    }

    private func setupTapGestureForStickers() {
        // 获取所有贴纸视图
        func findStickerViews(in view: UIView) {
            for subview in view.subviews {
                if let stickerView = subview as? ZLImageStickerView {
                    if stickerView.image.isStickerBackground() {
                        let tap = UITapGestureRecognizer(target: self, action: #selector(stickerTapped(_:)))
                        stickerView.addGestureRecognizer(tap)
                        stickerView.isUserInteractionEnabled = true
                    }
                } else {
                    findStickerViews(in: subview)
                }
            }
        }
        findStickerViews(in: view)
    }

    @objc private func stickerTapped(_ sender: UITapGestureRecognizer) {
        guard let stickerView = sender.view as? ZLImageStickerView else { return }
        currentStickerView = stickerView
        // 打开相册选择器
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            DispatchQueue.main.async {
                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.filter = .images
                config.selectionLimit = 1
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                self.present(picker, animated: true)
            }
        }
    }
}

extension EditImageViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }
        let provider = result.itemProvider

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let self = self,
                let newImage = image as? UIImage,
                let stickerView = self.currentStickerView else { return }
                DispatchQueue.main.async {
                    if stickerView.image == UIImage(named: "imageSticker-bg-white"){
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "imageSticker-bg-white"))
                    }else if stickerView.image == UIImage(named: "imageSticker-bg-yellow") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "imageSticker-bg-yellow"))
                    }else if stickerView.image == UIImage(named: "Christmas01-sticker-bg00") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas01-sticker-bg00"))
                    }else if stickerView.image == UIImage(named: "Christmas01-sticker-bg01") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas01-sticker-bg01"))
                    }else if stickerView.image == UIImage(named: "Christmas01-sticker-bg02") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas01-sticker-bg02"))
                    }else if stickerView.image == UIImage(named: "Christmas02-sticker-bg00") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas02-sticker-bg00"))
                    }else if stickerView.image == UIImage(named: "Christmas02-sticker-bg01") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas02-sticker-bg01"))
                    }
                    else if stickerView.image == UIImage(named: "Christmas03-sticker-bg00") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas03-sticker-bg00"))
                    }else if stickerView.image == UIImage(named: "Christmas03-sticker-bg01") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas03-sticker-bg01"))
                    }else if stickerView.image == UIImage(named: "Christmas04-sticker-bg00") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas04-sticker-bg00"))
                    }else if stickerView.image == UIImage(named: "Christmas04-sticker-bg01") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas04-sticker-bg01"))
                    }else if stickerView.image == UIImage(named: "Christmas05-sticker-bg00") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas05-sticker-bg00"))
                    }else if stickerView.image == UIImage(named: "Christmas05-sticker-bg01") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas05-sticker-bg01"))
                    }else if stickerView.image == UIImage(named: "Christmas06-sticker-bg00") {
                        stickerView.updateImage(newImage,withBaseImage: UIImage(named: "Christmas06-sticker-bg00"))
                    }
                }
            }
        }
    }
}

extension ZLImageStickerView {
    func updateImage(_ newImage: UIImage, withBaseImage baseImage: UIImage? = nil) {
        let finalImage: UIImage
        if let base = baseImage {
            let size = base.size
            finalImage = UIGraphicsImageRenderer(size: size).image { _ in
                base.draw(in: CGRect(origin: .zero, size: size))
                let overlayRect = CGRect(
                    x: size.width * 0.05,
                    y: size.height * 0.16,
                    width: size.width * 0.9,
                    height: size.height * 0.8
                )
                newImage.draw(in: overlayRect, blendMode: .normal, alpha: 1.0)
            }
        } else {
            finalImage = newImage
        }
        
        if let imageView = self.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.image = finalImage
            imageView.setNeedsDisplay()
        } else {
            self.image = finalImage
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

extension UIImage {
    func isStickerBackground(in names: [String] = ["imageSticker-bg-white", "imageSticker-bg-yellow","Christmas01-sticker-bg00","Christmas01-sticker-bg01","Christmas01-sticker-bg02","Christmas02-sticker-bg00","Christmas02-sticker-bg01","Christmas03-sticker-bg00","Christmas03-sticker-bg01","Christmas04-sticker-bg00","Christmas04-sticker-bg01","Christmas05-sticker-bg00","Christmas05-sticker-bg01","Christmas06-sticker-bg00"]) -> Bool {
        names.contains { UIImage(named: $0)?.isEqual(self) == true }
    }
}

