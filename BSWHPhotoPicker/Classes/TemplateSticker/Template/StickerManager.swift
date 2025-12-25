//
//  StickerManager.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/10/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import ObjectiveC
 
public protocol StickerManagerDelegate: AnyObject {
    /// 替换背景，传入本控制器和返回图片的大小，返回处理好的图片
    func replaceBackgroundWith(
            controller: EditImageViewController,
            imageRect:CGRect,
            completion: @escaping (UIImage?) -> Void
        )
    /// 添加贴纸，传入本控制器，返回选择的贴纸图片
    func addStickerImage(
            controller: EditImageViewController,
            completion: @escaping (UIImage?) -> Void
        )
    /// 裁剪贴纸，传入本控制器，返回裁剪编辑后的图片
    func cropStickerImage(
            controller: EditImageViewController,
            completion: @escaping (UIImage?) -> Void
        )
}

struct stickerData {
    var uuid:String = ""
    var originScale:Double = 1.0
    var originAngle:Double = 1.0
    var gesScale:Double = 1.0
    var gesRotation:Double = 0.0
    var originTransform: CGAffineTransform = .identity
    var totalTranslationPoint: CGPoint = .zero
    var gesTranslationPoint: CGPoint = .zero
    var originFrame: CGRect = CGRectZero
    var center:CGPoint = .zero
}

// MARK: - StickerManager
public final class StickerManager: NSObject {
    weak var controller: EditImageViewController?
    private weak var currentStickerView: EditableStickerView?
    var modelMap: [String: ImageStickerModel] = [:]
    var stickerArr: [EditableStickerView] = []
    var stickerData:[String: stickerData] = [:]
    public weak var delegate: StickerManagerDelegate?
    var persentType:Int = 0
    var templateOrBackground:Int = 0
    var replaceBgImage:UIImage? = nil
    public lazy var templateHomeData:[TemplateHomeModel] = ConfigDataItem.getTemplateHomeData()
    public lazy var backgroundHomeData:[TemplateHomeModel] = ConfigDataItem.getBackgroundHomeData()
    public var selectedTemplateIndex = 0
    public static let shared = StickerManager()
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(duplicateSticker(_:)),
            name: Notification.Name("duplicateSticker"),
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(addTap(_:)), name: Notification.Name(rawValue: "stickerImageAddTap"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(duplicateTextSticker(_:)), name: Notification.Name(rawValue: "duplicateTextSticker"), object: nil)
    }

    /// 使用本地Json加载模版
    func initCurrentTemplate(jsonName:String,currentVC:EditImageViewController){
        let items = StickerManager.shared.loadLocalJSON(fileName: jsonName, type: [ImageStickerModel].self)
        StickerManager.shared.replaceBgImage = nil
        StickerManager.shared.modelMap.removeAll()
        StickerManager.shared.stickerArr.removeAll()
        StickerManager.shared.stickerData.removeAll()
        controller = currentVC
        for (_,state) in items!.enumerated() {
//            state.zIndex = index
            self.controller!.switchOperation(type: .imageSticker)
            StickerManager.shared.addStickerImageHandle(state: state,isStoreAction: false)
        }
    }
    
    func getCurrentVC(currentVC:EditImageViewController) {
        controller = currentVC
    }
    // MARK: 加载本地 JSON
    func loadLocalJSON<T: Decodable>(fileName: String, type: T.Type) -> T? {
        let bundle = BSWHBundle.bundle() 
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            print("❌ 未找到 \(fileName).json")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ 解析 \(fileName).json 失败：\(error)")
            return nil
        }
    }

// MARK: - 点击事件处理
    @objc func duplicateSticker(_ notification: Notification){
        let dict = notification.object as! [String:Any]
        let stickerOld:EditableStickerView = dict["sticker"] as! EditableStickerView
        let stateTmp:ImageStickerModel = StickerManager.shared.modelMap[stickerOld.id]!;
        let state = stateTmp.deepCopy()
        state.originFrameX = state.originFrameX + stickerOld.totalTranslationPoint.x + 35
        state.originFrameY = state.originFrameY + stickerOld.totalTranslationPoint.y + 35
        state.originAngle = stickerOld.originAngle
        state.originScale = stickerOld.originScale
        state.gesRotation = stickerOld.gesRotation
        state.imageMask = stickerOld.imageMask
        if state.imageName == "empty" {
            state.bgAddImageType = stateTmp.bgAddImageType
        }
        if state.imageName == "empty"  && stateTmp.imageData != nil{
            state.imageData = stateTmp.imageData
        }
        state.image = stickerOld.image
        self.controller!.switchOperation(type: .imageSticker)
        StickerManager.shared.addStickerImageHandle(state: state)
    }

    @objc func duplicateTextSticker(_ notification: Notification) {
        let dict = notification.object as! [String:Any]
        let stickerOld:EditableTextStickerView = dict["sticker"] as! EditableTextStickerView
        let newPoint = CGPoint(x: stickerOld.state.totalTranslationPoint.x + 35, y: stickerOld.state.totalTranslationPoint.y + 35)
        let _ = controller!.addTextStickersView01(stickerOld.text,
                                                  textColor: stickerOld.textColor,
                                                  font: stickerOld.font ?? UIFont.systemFont(ofSize: 32),
                                                  image: stickerOld.image,
                                                  style: stickerOld.style,
                                                  originFrame: stickerOld.state.originFrame,
                                                  originScale: stickerOld.state.originScale,
                                                  originAngle: stickerOld.state.originAngle,
                                                  gesScale: stickerOld.state.gesScale,
                                                  gesRotation: stickerOld.state.gesRotation,
                                                  totalTranslationPoint: newPoint)
    }
    
    @objc func addTap(_ notification: Notification) {
        let dict = notification.object as! [String:Any]
        let sticker:EditableStickerView = dict["sticker"] as! EditableStickerView
        sticker.stickerModel = StickerManager.shared.modelMap[sticker.id]
        let state = StickerManager.shared.stickerData[sticker.id]!
        let stickerData = BSWHPhotoPicker.stickerData(uuid: state.uuid,
                                                      originScale:state.originScale,
                                                      originAngle:state.originAngle,
                                                      gesScale:state.gesScale,
                                                      gesRotation:state.gesRotation,
                                                      originTransform:state.originTransform,
                                                      totalTranslationPoint:state.totalTranslationPoint,
                                                      gesTranslationPoint:state.gesTranslationPoint,
                                                      originFrame:sticker.originFrame,
                                                      center: state.center
        )
        StickerManager.shared.stickerData[sticker.id] = stickerData
        var selectedImage: UIImage = UIImage(data: sticker.state.imageData)!
        if sticker.state.imageData == BSWHBundle.image(named: "addEmptyImage")?.pngData() {
            selectedImage = BSWHBundle.image(named: "Travel07-bg")!
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(stickerTapped(_:)))
        sticker.addGestureRecognizer(tap)
//        sticker.isUserInteractionEnabled = true
        if let model = sticker.stickerModel {
            sticker.updateImage(selectedImage, stickerModel: model, withBaseImage: sticker.image,vc: controller!)
        }
        
    }
    
    @objc func stickerTapped(_ sender: UITapGestureRecognizer) {
        guard let stickerView = sender.view as? EditableStickerView else { return }
        currentStickerView = stickerView

        let size = CGSize(width: stickerView.stickerModel!.originFrameWidth, height: stickerView.stickerModel!.originFrameHeight)
        let overlayRect = CGRect(
            x: size.width * (stickerView.stickerModel!.overlayRectX ?? 0),
            y: size.height * (stickerView.stickerModel!.overlayRectY ?? 0),
            width: size.width * (stickerView.stickerModel!.overlayRectWidth ?? 0.8),
            height: size.height * (stickerView.stickerModel!.overlayRectHeight ?? 0.8)
        )
        
        let point = sender.location(in: stickerView)
        if stickerView.stickerModel?.imageName == "empty" {
            stickerView.isEditingCustom = !stickerView.isEditingCustom
            NotificationCenter.default.post(name: Notification.Name(rawValue: "tapStickerOutOverlay"), object: ["sticker":stickerView])
            return
        }
        
        if overlayRect.contains(point) {
            print("👉 点击在 overlay 区域内")
            
            if stickerView.state.imageData != BSWHBundle.image(named: stickerView.stickerModel!.bgAddImageType!)?.pngData(){
                stickerView.isEditingCustom = !stickerView.isEditingCustom
                NotificationCenter.default.post(name: Notification.Name(rawValue: "tapStickerOutOverlay"), object: ["sticker":stickerView])
            }else{
                checkPhotoAuthorizationAndPresentPicker()
            }
        } else {
            print("👉 点击在 overlay 区域外")
            stickerView.isEditingCustom = !stickerView.isEditingCustom
            NotificationCenter.default.post(name: Notification.Name(rawValue: "tapStickerOutOverlay"), object: ["sticker":stickerView])
        }
    }
    
    func addStickerImageHandle(state: ImageStickerModel,isFreeStyle:Bool = false, isStoreAction:Bool = true){
        state.zIndex = StickerManager.shared.stickerArr.count
        let sticker = self.controller!.addImageSticker01(state: state,isFreeStyle: isFreeStyle,isStoreAction: isStoreAction)
        let stickerData = BSWHPhotoPicker.stickerData(uuid: sticker.id,
                                                      originScale:state.originScale,
                                                      originAngle:state.originAngle,
                                                      gesScale:state.gesScale,
                                                      gesRotation:state.gesRotation,
                                                      originTransform:sticker.originTransform,
                                                      totalTranslationPoint:sticker.totalTranslationPoint,
                                                      gesTranslationPoint:sticker.gesTranslationPoint,
                                                      originFrame:sticker.originFrame,
                                                      center: sticker.center
        )
        StickerManager.shared.stickerData[sticker.id] = stickerData
        sticker.stickerModel = state
        StickerManager.shared.modelMap[sticker.id] = state
        StickerManager.shared.stickerArr.append(sticker)
        let tap = UITapGestureRecognizer(target: StickerManager.shared, action: #selector(StickerManager.shared.stickerTapped(_:)))
        sticker.addGestureRecognizer(tap)
        if let image = sticker.stickerModel?.stickerImage {
            sticker.updateImage(image, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image,vc: self.controller!)
        }
        self.controller!.backAndreBackStatus()
    }
    
    func replaceImage(img:UIImage){
        controller!.replaceBgImage(image: img)
        controller!.resetContainerViewFrame()
        for (_ ,sticker) in StickerManager.shared.stickerArr.enumerated() {
            if let data = StickerManager.shared.stickerData[sticker.id] {
//                sticker.originAngle = data.originAngle
                sticker.gesRotation = data.gesRotation
                sticker.originScale = data.originScale
                sticker.gesScale = data.gesScale
                sticker.originTransform = data.originTransform
                sticker.totalTranslationPoint = data.totalTranslationPoint
                sticker.gesTranslationPoint = data.gesTranslationPoint
                sticker.originFrame = data.originFrame
                sticker.center = data.center
                sticker.updateTransform()
            }
        }
        let newFrame = controller!.containerView.frame
        convertStickerFrames(
            stickers: StickerManager.shared.stickerArr,
            oldSize: controller!.containerViewOriginFrame.size,
            newSize: newFrame.size,
            mode: .fit
        )
    }

}

extension StickerManager: PHPickerViewControllerDelegate {

    public func checkPhotoAuthorizationAndPresentPicker(presentTypeFrom:Int = 0) {
        persentType = presentTypeFrom
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

    public func presentPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1  // 选择 1 张，可改为 0 表示无限制
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.controller!.present(picker, animated: true)
    }

    // 相册选择回调
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }
        let provider = result.itemProvider

        if persentType == 0 {
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    guard let self = self,
                    let newImage:UIImage = image as? UIImage,
                    let stickerView = self.currentStickerView else { return }
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData = newImage.pngData() {
                            DispatchQueue.main.async { [self] in
                                stickerView.setOperation(true)
                                let oldState = stickerView.state
                                if stickerView.stickerModel?.isBgImage == true {
                                    stickerView.stickerModel?.imageData = imageData
                                    
                                    stickerView.updateImage(newImage, stickerModel: stickerView.stickerModel!, withBaseImage: stickerView.image,vc: self.controller!)
                    
                                    stickerView.imageData = imageData
                                    stickerView.state.imageData = imageData
                                    let newState = stickerView.state
                                    stickerView.setOperation02(false,oldState:oldState,newState:newState)
                                }
                                self.controller?.currentSticker = self.currentStickerView
                                self.controller?.backAndreBackStatus()
                            }
                        }
                    }
                }
            }
        }else{
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    guard let self = self,
                    let newImage:UIImage = image as? UIImage else { return }
                    DispatchQueue.main.async { [self] in
                        self.controller!.switchOperation(type: .imageSticker)
                        let state: ImageStickerModel = ImageStickerModel(imageName: "empty",imageData:newImage.pngData(), originFrame: CGRect(x: 50, y: 50, width: 120.w, height: 120.w),gesScale: 1,gesRotation: 0,overlayRect: CGRect(x:0,y: 0,width: 1,height: 1) ,isBgImage: true)
                        StickerManager.shared.addStickerImageHandle(state: state)
                    }
                }
            }
        }
    }    
}

/// 选择照片
extension StickerManager {
    public func pickerImage(_ image: UIImage) {
        let newImage:UIImage = image
        guard let stickerView = self.currentStickerView else { return }
        DispatchQueue.main.async { [self] in
            if stickerView.stickerModel?.isBgImage == true {
                if let imageData = newImage.pngData() {
                    stickerView.stickerModel?.imageData = imageData
                }
                stickerView.updateImage(newImage, stickerModel: stickerView.stickerModel!, withBaseImage: stickerView.image,vc: self.controller!)
            }
        }
    }
}

extension StickerManager {
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

        self.controller!.present(alert, animated: true)
    }
}

