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
import Photos
import PhotosUI

class ViewController: UIViewController, PHPickerViewControllerDelegate {
    
    let backButton02: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("自由拼贴", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
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
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(backButton02)
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
        
        backButton02.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton01.snp.top).offset(-80)
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
        backButton02.addTarget(self, action: #selector(onClickBack02(_:)), for: .touchUpInside)
        lang00Button.addTarget(self, action: #selector(onClickLang00(_:)), for: .touchUpInside)
        lang01Button.addTarget(self, action: #selector(onClickLang01(_:)), for: .touchUpInside)
    }
    @objc private func onClickBack01(_ sender: UIButton) {
        BSWHPhotoPickerLocalization.shared.currentLanguage = "es-MX"
        StickerManager.shared.selectedTemplateIndex = 3
        presentBgVC()
    }
    
    @objc private func onClickBack02(_ sender: UIButton) {
        
        checkPhotoAuthorizationAndPresentPicker()
    }
    
    @objc private func onClickBack(_ sender: UIButton) {
        BSWHPhotoPickerLocalization.shared.currentLanguage = "id"
        StickerManager.shared.selectedTemplateIndex = 2
        presentVC()
    }
    @objc private func onClickLang00(_ sender: UIButton) {
        BSWHPhotoPickerLocalization.shared.currentLanguage = "ar"
        let model:TemplateHomeModel = StickerManager.shared.templateHomeData[1]
        print(model.templateType)
        print(model.image!)
        StickerManager.shared.selectedTemplateIndex = 1
        presentVC()
    }
    @objc private func onClickLang01(_ sender: UIButton) {
        BSWHPhotoPickerLocalization.shared.currentLanguage = "he"
        let model:TemplateHomeModel = StickerManager.shared.backgroundHomeData[1]
        print(model.templateType)
        print(model.image!)
        StickerManager.shared.selectedTemplateIndex = 2
        presentBgVC()
    }
    
    func presentVC(){
        let vc = UINavigationController(rootViewController: TemplateViewController())
        StickerManager.shared.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    func presentBgVC(){
        let vc = UINavigationController(rootViewController: BackGroundViewController())
        StickerManager.shared.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    func imageFromHex(_ hex: String,
                      alpha: CGFloat = 1.0,
                      size: CGSize = CGSize(width: 400, height: 400)) -> UIImage? {

        guard let color = UIColor(hex: hex)?.withAlphaComponent(alpha) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    func checkPhotoAuthorizationAndPresentPicker(presentTypeFrom:Int = 0) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            presentPhotoPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.presentPhotoPicker()
                    } else {
                        self.showPhotoPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPhotoPermissionAlert()
        @unknown default:
            showPhotoPermissionAlert()
        }
    }
    func showPhotoPermissionAlert() {
        let alert = UIAlertController(
            title: BSWHPhotoPickerLocalization.shared.localized("NoPermission"),
            message: BSWHPhotoPickerLocalization.shared.localized("photoLibrarySettings"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title:BSWHPhotoPickerLocalization.shared.localized("Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: BSWHPhotoPickerLocalization.shared.localized("GotoSettings"), style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))

        self.present(alert, animated: true)
    }
    
    func presentPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 10  // 选择 1 张，可改为 0 表示无限制
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let image = imageFromHex("#FFFFFF")
        let item = TemplateModel(imageName: "#FFFFFF",imageBg: "#FFFFFF")
        let controller = EditImageViewController(image: image!)
        controller.item = item
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
}

extension ViewController: StickerManagerDelegate {
    
    func replaceBackgroundWith(controller: BSWHPhotoPicker.EditImageViewController, imageRect: CGRect, completion: @escaping (UIImage?) -> Void) {
//        let img = UIImage(named: "Pattern55")
        
        var img:UIImage? = nil
        if count % 3 == 0 {
            img = UIImage(named: "Pattern55")
        }else if count % 3 == 1{
            img = UIImage(named: "Texture00")
        }else{
            img = UIImage(named: "Christmas02-bg")
        }
        count += 1
        
        print("image")
        completion(img!)
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

extension UIColor {
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        guard hexString.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

//var img:UIImage? = nil
//if count % 3 == 0 {
//    img = UIImage(named: "Pattern55")
//}else if count % 3 == 1{
//    img = UIImage(named: "Texture00")
//}else{
//    img = UIImage(named: "Christmas02-bg")
//}
//count += 1
