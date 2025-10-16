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

    private var stickerManager: StickerManager!

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


        StickerManager.shared.attachTapGestures(in: view, vc: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.attachModelsToStickerViews(in: self.view, modelArr: StickerManager.shared.modelArr)
        }
    }
    
    func attachModelsToStickerViews(in rootView: UIView, modelArr: [ImageStickerModel]) {
        var index = 0
        func traverse(_ view: UIView) {
            for sub in view.subviews {
                if let stickerView = sub as? ZLImageStickerView,
                   index < modelArr.count {
                    // 绑定顺序模型（因为 ZL 不公开 id，我们退而求其次）
                    let model = modelArr[index]
                    stickerView.stickerModel = model
                    index += 1
                } else {
                    traverse(sub)
                }
            }
        }
        traverse(rootView)
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
}



