//
//  ViewController.swift
//  BSWHPhotoPicker
//
//  Created by caoguangming on 09/11/2025.
//  Copyright (c) 2025 caoguangming. All rights reserved.
//

import Localize_Swift

func Localize_Swift_bridge(forKey:String,table:String,fallbackValue:String)->String {
    return forKey.localized(using: table);
}

import UIKit
import BSWHPhotoPicker

class ViewController: UIViewController {
    let backButton01: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("背景列表", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("模版列表", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    let lang00Button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("英文", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    let lang01Button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("中文", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(backButton01)
        view.addSubview(backButton)
        view.addSubview(lang00Button)
        view.addSubview(lang01Button)
        backButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        backButton01.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton.snp.top).offset(-80)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        lang00Button.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(40)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        lang01Button.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(40)
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton01.addTarget(self, action: #selector(onClickBack01(_:)), for: .touchUpInside)
        lang00Button.addTarget(self, action: #selector(onClickLang00(_:)), for: .touchUpInside)
        lang01Button.addTarget(self, action: #selector(onClickLang01(_:)), for: .touchUpInside)
    }
    @objc private func onClickBack01(_ sender: UIButton) {
        presentBgVC()
    }
    @objc private func onClickBack(_ sender: UIButton) {
        StickerManager.shared.selectedTemplateIndex = 5
        presentVC()
    }
    @objc private func onClickLang00(_ sender: UIButton) {
        BSWHPhotoPickerLocalization.shared.currentLanguage = "en"
        StickerManager.shared.selectedTemplateIndex = 1
        presentVC()
    }
    @objc private func onClickLang01(_ sender: UIButton) {
        BSWHPhotoPickerLocalization.shared.currentLanguage = "zh"
        StickerManager.shared.selectedTemplateIndex = 2
        presentVC()
    }
    
    func presentVC(){
        let vc = UINavigationController(rootViewController: TemplateViewController())
        StickerManager.shared.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    func presentBgVC(){
        let vc = UINavigationController(rootViewController: BackGroundViewController())
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}

extension ViewController: StickerManagerDelegate {
    
    func replaceBackgroundWith(controller: BSWHPhotoPicker.EditImageViewController, imageRect: CGRect, completion: @escaping (UIImage?) -> Void) {
        let img = UIImage(named: "Christmas02-bg")
        print("image")
        completion(img)
    }
    
    func addStickerImage(controller: BSWHPhotoPicker.EditImageViewController, completion: @escaping (UIImage?) -> Void) {
        let img = UIImage(named: "imageSticker000")
        print("image")
        completion(img)
    }
    
    func cropStickerImage(controller: BSWHPhotoPicker.EditImageViewController, completion: @escaping (UIImage?) -> Void) {
        let img = UIImage(named: "imageSticker000")
        print("image")
        completion(img)
    }
}

