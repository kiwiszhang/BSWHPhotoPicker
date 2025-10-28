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
    private let jsonFiles:[String] = ["Christmas00","Christmas01","Christmas02","Christmas03","Christmas04","Christmas05","Christmas06"]

    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("返回", for: .normal)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(addTap(_:)), name: Notification.Name(rawValue: "stickerImageAddTap"), object: nil)
        view.addSubview(backButton)
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
        
        backButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.left.equalToSuperview()
            make.top.equalTo(menuButton.snp.top)
        }
        
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(onClickNext(_:)), for: .touchUpInside)
        lastButton.addTarget(self, action: #selector(onClickLast(_:)), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(onClickMenu(_:)), for: .touchUpInside)


        
        let items = StickerManager.shared.loadLocalJSON(fileName: jsonFiles[0], type: [ImageStickerModel].self)
//        let items = StickerManager.shared.loadLocalJSON(fileName: jsonFiles[1], type: [ImageStickerModel].self)
        StickerManager.shared.modelMap.removeAll()
        for state in items! {
            let sticker = addImageSticker01(state: state)
            StickerManager.shared.modelMap[sticker.id] = state

            if state.isBgImage == true {
                let tap = UITapGestureRecognizer(target: StickerManager.shared, action: #selector(StickerManager.shared.stickerTapped(_:)))
                sticker.addGestureRecognizer(tap)
                sticker.isUserInteractionEnabled = true
            }
        }
        StickerManager.shared.attachTapGestures(in: view, vc: self)
    }

    @objc func addTap(_ notification: Notification) {
        let dict = notification.object as! [String:Any]
        let sticker:EditableStickerView = dict["sticker"] as! EditableStickerView
        sticker.stickerModel = StickerManager.shared.modelMap[sticker.id]
        let tap = UITapGestureRecognizer(target: StickerManager.shared, action: #selector(StickerManager.shared.stickerTapped(_:)))
        sticker.addGestureRecognizer(tap)
        sticker.isUserInteractionEnabled = true
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
    
    @objc private func onClickBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
}




