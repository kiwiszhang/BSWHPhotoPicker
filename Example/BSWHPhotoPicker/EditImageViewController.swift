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
    private let jsonFiles:[String] = ["Christmas00","Christmas01","Christmas02","Christmas03","Christmas04","Christmas05","Christmas06","Wedding00"]

    var index = 0
    private var bgPanelBottomConstraint: Constraint?

    private lazy var bgPanel: ReplaceBgView = {
        let v = ReplaceBgView()
        v.backgroundColor = .systemRed
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.onClose = { [weak self] in
            self?.hideBottomPanel()
        }
        return v
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("返回", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("保存", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
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
    
    let toolCollectionView:ToolsCollectionView = {
       let view = ToolsCollectionView()
        view.backgroundColor = .systemCyan
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backButton)
        view.addSubview(saveButton)
        view.addSubview(nextButton)
        view.addSubview(lastButton)
        view.addSubview(menuButton)
        view.addSubview(toolCollectionView)
        
        view.addSubview(bgPanel)
                
        bgPanel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
            self.bgPanelBottomConstraint = make.bottom.equalToSuperview().offset(200).constraint
        }
        
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
        
        backButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.left.equalToSuperview()
            make.top.equalTo(menuButton.snp.top)
        }
        
        saveButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.right.equalToSuperview()
            make.top.equalTo(menuButton.snp.top)
        }
        
        toolCollectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(120.h)
        }
        toolCollectionView.delegate = self

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(onClickSave(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(onClickNext(_:)), for: .touchUpInside)
        lastButton.addTarget(self, action: #selector(onClickLast(_:)), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(onClickMenu(_:)), for: .touchUpInside)

        StickerManager.shared.initCurrentTemplate(jsonName: jsonFiles[index], currentVC: self)
    }
    
    @objc private func onClickSave(_ sender: UIButton) {
        guard let finalImage = renderImage(from: containerView) else { return }
        saveImageToAlbum(finalImage)
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
//            self.switchOperation(type: .draw)
            
            let vc = DrawViewController()
//            vc.bgImage = originalImage
            vc.bgImageFrame  = imageView.frame
            vc.modalPresentationStyle = .overFullScreen
            vc.onDrawingExported = { [weak self] exportedImage,rect in
                guard let self = self else { return }
                
                self.switchOperation(type: .imageSticker)
                let state: ImageStickerModel = ImageStickerModel(image: exportedImage,originFrame: CGRect(x: rect.origin.x / (kkScreenWidth / 375.0), y: rect.origin.y / (kkScreenHeight / 812.0), width: rect.size.width / (kkScreenWidth / 375.0), height: rect.size.height / (kkScreenHeight / 812.0)),gesScale: 1,gesRotation: 0,isBgImage: false)
                let sticker = self.addImageSticker01(state: state)
                sticker.stickerModel = state
                StickerManager.shared.modelMap[sticker.id] = state
                
            }
            present(vc, animated: false)

            
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
                let state: ImageStickerModel = ImageStickerModel(imageName: "imageSticker",originFrame: CGRect(x: 40, y: 100, width: 120, height: 120),gesScale: 1,gesRotation: 0,isBgImage: false)
//                self?.addImageSticker(image: image)
                let sticker = self?.addImageSticker01(state: state)
                sticker!.stickerModel = state
                StickerManager.shared.modelMap[sticker!.id] = state
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
    
    @objc private func onClickBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    /// 点击按钮调用
    @objc func showBottomPanel() {
        self.bgPanelBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    /// 隐藏
    func hideBottomPanel() {
        self.bgPanelBottomConstraint?.update(offset: 200)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
            
    func renderImage(from view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(
            bounds: view.bounds,
            format: {
                let f = UIGraphicsImageRendererFormat.default()
                f.scale = 3 /// 高清比例 1/2/3 可选
                return f
            }()
        )
        return renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }

    func saveImageToAlbum(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } else {
                DispatchQueue.main.async {
                    self.showAlbumPermissionAlert()
                }
            }
        }
    }

    func showAlbumPermissionAlert() {
        let alert = UIAlertController(
            title: "需要相册权限",
            message: "请在设置中允许保存照片",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        present(alert, animated: true)
    }

}

extension EditImageViewController:ToolsCollectionViewDelegate {
    func cellDidSelectItemAt(_ sender: ToolsCollectionView, indexPath: IndexPath) {
        if indexPath.row == 0 {
            replaceBgImage(image: UIImage(named: "Christmas01-bg")!)
            resetContainerViewFrame()
        }else if indexPath.row == 1 {
            showBottomPanel()
        }

    }
}


