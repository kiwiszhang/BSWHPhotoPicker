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
        view.addSubview(backButton)
        view.addSubview(lang00Button)
        view.addSubview(lang01Button)
        backButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
        lang00Button.addTarget(self, action: #selector(onClickLang00(_:)), for: .touchUpInside)
        lang01Button.addTarget(self, action: #selector(onClickLang01(_:)), for: .touchUpInside)
    }
    @objc private func onClickBack(_ sender: UIButton) {
        let config = genarateConfig()
        StickerManager.shared.config = config
        let vc = UINavigationController(rootViewController: TemplateViewController())
        StickerManager.shared.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    @objc private func onClickLang00(_ sender: UIButton) {
        Localize.setCurrentLanguage("en")
    }
    @objc private func onClickLang01(_ sender: UIButton) {
        Localize.setCurrentLanguage("zh")
    }
    
    func genarateConfig() -> TemplateConfig {
        var config = TemplateConfig()
        config.save = L10n.save
        config.all = L10n.all
        config.Christmas = L10n.christmas
        config.ChooseATemplate = L10n.chooseATemplate
        config.Text = L10n.text
        config.Background = L10n.background
        config.Photos = L10n.photos
        config.Stickers = L10n.stickers
        config.Ratio = L10n.ratio
        config.Replace = L10n.replace
        config.Duplicate = L10n.duplicate
        config.Crop = L10n.crop
        config.FlipH = L10n.flipH
        config.FlipV = L10n.flipV
        config.Remove = L10n.remove
        config.NoPermission = L10n.noPermission
        config.photoLibrarySettings = L10n.photoLibrarySettings
        config.Cancel = L10n.cancel
        config.GotoSettings = L10n.gotoSettings
        config.Done = L10n.done
        config.General = L10n.general
        config.Social = L10n.social
        config.Print = L10n.print
        return config
    }
    
}

extension ViewController: StickerManagerDelegate {
    
    func replaceBackgroundWith(controller: BSWHPhotoPicker.EditImageViewController, imageRect: CGRect, completion: @escaping (UIImage?) -> Void) {
        
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

