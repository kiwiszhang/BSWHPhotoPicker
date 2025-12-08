//
//  ConfigDataItem.swift
//  BSWHPhotoPicker
//
//  Created by 笔尚文化 on 2025/11/18.
//

import UIKit

class ImageHeightCache {
    static let shared = ImageHeightCache()
    private init() {}
    private var cache: [String: [CGFloat: CGFloat]] = [:]
    func get(imageName: String, width: CGFloat) -> CGFloat? {
        return cache[imageName]?[width]
    }
    func set(imageName: String, width: CGFloat, height: CGFloat) {
        if cache[imageName] == nil {
            cache[imageName] = [:]
        }
        cache[imageName]?[width] = height
    }
}

final class BGImageCache {

    static let shared = BGImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private let queue = DispatchQueue(label: "com.yourapp.bgImageDecode", qos: .userInitiated)

    private init() {
        // tune these according to app memory constraints
        cache.countLimit = 150 // keep up to 150 images
        cache.totalCostLimit = 180 * 1024 * 1024 // ~180MB
    }

    /// Synchronous cached fetch (fast if in memory). If not present, returns nil.
    func cachedImage(named name: String) -> UIImage? {
        return cache.object(forKey: name as NSString)
    }

    /// Asynchronous load with background decode -> returns on main thread
    func loadImage(named name: String, completion: @escaping (UIImage?) -> Void) {
        // if cached return immediately
        if let img = cachedImage(named: name) {
            DispatchQueue.main.async { completion(img) }
            return
        }

        queue.async { [weak self] in
            guard let self = self else { return }
            // load from bundle (or other source). This may be nil.
            let raw = BSWHBundle.image(named: name) ?? UIImage(named: name)
            guard let rawImage = raw else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // decode/draw into bitmap context to force decoding off main thread
            let decoded = rawImage.decodedImage()

            // compute approximate cost (byte size)
            let cost = decoded.pngData()?.count ?? 0
            self.cache.setObject(decoded, forKey: name as NSString, cost: cost)
            DispatchQueue.main.async {
                completion(decoded)
            }
        }
    }
}

struct RatioToolsModel {
    var text:String = "Text"
    var imageName:String = "template-text"
    var width:Double = 1.0
    var height:Double = 1.0
}

struct ToolsModel {
    var text:String = "Text"
    var imageName:String = "template-text"
}

public struct TemplateModel:Equatable {
    public var imageName:String?
    public var imageBg:String = "Christmas00-bg"
    public var jsonName:String?
    public var isNeedFit:Bool = false
    public var cornerRadius:Double = 0.0
    public var templateType:String = "Party"
}

public struct TemplateHomeModel {
    public var image:UIImage?
    public var templateType:String = "Party"
}
//public struct BackgroundModel {
//    var imageBg:String = "Christmas00-bg"
//}

class ConfigDataItem {
    
    static func getBackgroundTabData() -> [String] {
        let items = [BSWHPhotoPickerLocalization.shared.localized("Color"),
                     BSWHPhotoPickerLocalization.shared.localized("Texture"),
                     BSWHPhotoPickerLocalization.shared.localized("Geometric"),
                     BSWHPhotoPickerLocalization.shared.localized("Pattern"),
                     BSWHPhotoPickerLocalization.shared.localized("Grid"),
        ]
        return items
    }
    
    public static let backgroundListData: [[TemplateModel]] = {
            func make(_ s: [String]) -> [TemplateModel] { s.map { TemplateModel(imageBg: $0) } }

            let colors = ["BackgroundPicker","BackgroundNoColor","#99EDFF","#00C9FF","#D1E82D","#9200FF","#8F9562","#D9D9D9","#2F4D49","#FFED00","#495E26","#FAB226","#8ED830","#FF614F","#C970EB","#76939A","#4D316D","#3265E4"]

            let textures = [
                "Texture00","Texture01","Texture02","Texture03","Texture04","Texture05","Texture06","Texture07","Texture08","Texture09","Texture10","Texture11","Texture12","Texture13","Texture14","Texture15","Texture16","Texture17","Texture18","Texture19","Texture20","Texture21","Texture22","Texture23","Texture24","Texture25","Texture26","Texture27","Texture28","Texture29","Texture30","Texture31","Texture32","Texture33","Texture34","Texture35","Texture36","Texture37","Texture43","Texture38","Texture39","Texture40","Texture41","Texture42",
                "Pattern34","Pattern35","Pattern36","Pattern37","Pattern38","Pattern39","Pattern40","Pattern41","Pattern42","Pattern43","Pattern44","Pattern45","Pattern46","Pattern47","Pattern48","Pattern49","Pattern50","Pattern51","Pattern52","Pattern53","Pattern54","Pattern55","Pattern56","Pattern57","Pattern58","Pattern59","Pattern60"
            ]

            let geometrics = ["Geometric00","Geometric01","Geometric02","Geometric03","Geometric04","Geometric05","Geometric06","Geometric07"]

            let patterns = [
                "Pattern00","Pattern01","Pattern02","Pattern03","Pattern04","Pattern05","Pattern06","Pattern07","Pattern08","Pattern09","Pattern10","Pattern11","Pattern12","Pattern13","Pattern14","Pattern15","Pattern16","Pattern17","Pattern18","Pattern19","Pattern20","Pattern21","Pattern22","Pattern23","Pattern24","Pattern25","Pattern26","Pattern27","Pattern28",
                "Pattern29","Pattern30","Pattern31","Pattern32","Pattern33"
            ]

            return [
                make(colors),
                make(textures),
                make(geometrics),
                make(patterns),
                make(["Pattern29","Pattern30","Pattern31","Pattern32","Pattern33"])
            ]
        }()

        public static func getBackgroundListData() -> [[TemplateModel]] {
            return backgroundListData
        }

    static func getTemplateTabData() -> [String] {
        let items = [BSWHPhotoPickerLocalization.shared.localized("ALL"),
                     BSWHPhotoPickerLocalization.shared.localized("Christmas"),
                     BSWHPhotoPickerLocalization.shared.localized("Baby"),
                     BSWHPhotoPickerLocalization.shared.localized("Birthday"),
                     BSWHPhotoPickerLocalization.shared.localized("WeddingParty"),
                     BSWHPhotoPickerLocalization.shared.localized("Travel"),
                     BSWHPhotoPickerLocalization.shared.localized("Scrapbook"),
                     BSWHPhotoPickerLocalization.shared.localized("photoframe")]
        return items
    }
    
    static func getBackgroundHomeData() -> [TemplateHomeModel] {
        let item00 = TemplateHomeModel(image: BSWHBundle.image(named: "backgroundHome03"),templateType: BSWHPhotoPickerLocalization.shared.localized("Texture"))
        let item10 = TemplateHomeModel(image:BSWHBundle.image(named: "backgroundHome02"),templateType: BSWHPhotoPickerLocalization.shared.localized("Color"))
        let item23 = TemplateHomeModel(image: BSWHBundle.image(named: "backgroundHome01") ,templateType: BSWHPhotoPickerLocalization.shared.localized("Pattern"))
        let item32 = TemplateHomeModel(image: BSWHBundle.image(named: "backgroundHome04"),templateType: BSWHPhotoPickerLocalization.shared.localized("Grid"))
        return  [item00,item10,item23,item32]
    }
    
    
    static func getTemplateHomeData() -> [TemplateHomeModel] {
        let item00 = TemplateHomeModel(image: BSWHBundle.image(named: "Christmas01"),templateType: BSWHPhotoPickerLocalization.shared.localized("Christmas"))
        let item10 = TemplateHomeModel(image:BSWHBundle.image(named: "baby01"),templateType: BSWHPhotoPickerLocalization.shared.localized("Baby"))
        let item23 = TemplateHomeModel(image: BSWHBundle.image(named: "Birthday03") ,templateType: BSWHPhotoPickerLocalization.shared.localized("Birthday"))
        let item32 = TemplateHomeModel(image: BSWHBundle.image(named: "Wedding02"),templateType: BSWHPhotoPickerLocalization.shared.localized("WeddingParty"))
        return  [item00,item10,item23,item32]
    }
    
    static func getTemplateListData() -> [[TemplateModel]] {
        let item00 = TemplateModel(imageName: "Christmas01",imageBg: "Christmas00-bg",jsonName: "Christmas00")
        let item01 = TemplateModel(imageName: "Christmas02",imageBg: "Christmas01-bg",jsonName: "Christmas01",isNeedFit: true)
        let item02 = TemplateModel(imageName: "Christmas03",imageBg: "Christmas02-bg",jsonName: "Christmas02")
        let item03 = TemplateModel(imageName: "Christmas04",imageBg: "Christmas03-bg",jsonName: "Christmas03")
        let item04 = TemplateModel(imageName: "Christmas05",imageBg: "Christmas04-bg",jsonName: "Christmas04")
        let item05 = TemplateModel(imageName: "Christmas06",imageBg: "Christmas05-bg",jsonName: "Christmas05")
        let item06 = TemplateModel(imageName: "Christmas07",imageBg: "Christmas06-bg",jsonName: "Christmas06")
        
        let item10 = TemplateModel(imageName: "baby01",imageBg: "baby01-bg",jsonName: "baby01")
        let item11 = TemplateModel(imageName: "baby02",imageBg: "baby02-bg",jsonName: "baby02")
        let item12 = TemplateModel(imageName: "baby03",imageBg: "baby03-bg",jsonName: "baby03")
        let item13 = TemplateModel(imageName: "baby04",imageBg: "baby04-bg",jsonName: "baby04")
        let item14 = TemplateModel(imageName: "baby05",imageBg: "baby05-bg",jsonName: "baby05")
        let item15 = TemplateModel(imageName: "baby06",imageBg: "baby06-bg",jsonName: "baby06")
        
        let item21 = TemplateModel(imageName: "Birthday01",imageBg: "Birthday01-bg",jsonName: "Birthday01")
        let item22 = TemplateModel(imageName: "Birthday02",imageBg: "Travel07-bg",jsonName: "Birthday02")
        let item23 = TemplateModel(imageName: "Birthday03",imageBg: "Birthday03-bg",jsonName: "Birthday03")
        let item24 = TemplateModel(imageName: "Birthday04",imageBg: "Birthday04-bg",jsonName: "Birthday04")
        let item25 = TemplateModel(imageName: "Birthday05",imageBg: "Birthday05-bg",jsonName: "Birthday05")

        let item31 = TemplateModel(imageName: "Wedding01",imageBg: "wedding01-bg",jsonName: "Wedding01",isNeedFit: true)
        let item32 = TemplateModel(imageName: "Wedding02",imageBg: "wedding02-bg",jsonName: "Wedding02")
        let item33 = TemplateModel(imageName: "Wedding03",imageBg: "wedding03-bg",jsonName: "Wedding03")
        let item34 = TemplateModel(imageName: "Wedding04",imageBg: "wedding04-bg",jsonName: "Wedding04")
        let item35 = TemplateModel(imageName: "Wedding05",imageBg: "wedding05-bg",jsonName: "Wedding05")

        let item41 = TemplateModel(imageName: "Travel01",imageBg: "Travel01-bg",jsonName: "Travel01",isNeedFit: true)
        let item42 = TemplateModel(imageName: "Travel02",imageBg: "Travel02-bg",jsonName: "Travel02")
        let item43 = TemplateModel(imageName: "Travel03",imageBg: "Travel03-bg",jsonName: "Travel03")
        let item44 = TemplateModel(imageName: "Travel04",imageBg: "Travel04-bg",jsonName: "Travel04")
        let item45 = TemplateModel(imageName: "Travel05",imageBg: "Travel05-bg",jsonName: "Travel05")
        let item46 = TemplateModel(imageName: "Travel06",imageBg: "Travel06-bg",jsonName: "Travel06")
        let item47 = TemplateModel(imageName: "Travel07",imageBg: "Travel07-bg",jsonName: "Travel07")

        let item51 = TemplateModel(imageName: "Scrapbook01",imageBg: "Scrapbook01-bg",jsonName: "Scrapbook01")
        let item52 = TemplateModel(imageName: "Scrapbook02",imageBg: "Scrapbook02-bg",jsonName: "Scrapbook02",isNeedFit: true)
        let item53 = TemplateModel(imageName: "Scrapbook03",imageBg: "Scrapbook03-bg",jsonName: "Scrapbook03")
        let item54 = TemplateModel(imageName: "Scrapbook04",imageBg: "Scrapbook04-bg",jsonName: "Scrapbook04")
        let item55 = TemplateModel(imageName: "Scrapbook05",imageBg: "Scrapbook05-bg",jsonName: "Scrapbook05")

        let item61 = TemplateModel(imageName: "PhotoFrame01",imageBg: "PhotoFrame01-bg",jsonName: "PhotoFrame01")
        let item62 = TemplateModel(imageName: "PhotoFrame02",imageBg: "PhotoFrame02-bg",jsonName: "PhotoFrame02",cornerRadius: 48.h)
        let item63 = TemplateModel(imageName: "PhotoFrame03",imageBg: "PhotoFrame03-bg",jsonName: "PhotoFrame03",cornerRadius: 48.h)
        let item64 = TemplateModel(imageName: "PhotoFrame04",imageBg: "PhotoFrame04-bg",jsonName: "PhotoFrame04")
        let item65 = TemplateModel(imageName: "PhotoFrame05",imageBg: "PhotoFrame05-bg",jsonName: "PhotoFrame05")
        let item66 = TemplateModel(imageName: "PhotoFrame06",imageBg: "PhotoFrame06-bg",jsonName: "PhotoFrame06")
        let item67 = TemplateModel(imageName: "PhotoFrame07",imageBg: "PhotoFrame07-bg",jsonName: "PhotoFrame07")

        
        let items = [[item00,item01,item02,item03,item04,item05,item06,item10,item11,item12,item13,item14,item15,item21,item23,item24,item25,item31,item32,item33,item34,item35,item41,item42,item43,item44,item45,item46,item47,item51,item52,item53,item54,item55,item61,item62,item63,item64,item65,item66,item67],
            [item00,item01,item02,item03,item04,item05,item06],
            [item10,item11,item12,item13,item14,item15],
            [item21,item22,item23,item24,item25],
            [item31,item32,item33,item34,item35],
            [item41,item42,item43,item44,item45,item46,item47],
            [item51,item52,item53,item54,item55],
            [item61,item62,item63,item64,item65,item66,item67]
        ]
        
        return items
    }
    
    
    static func getBackgroundToolsData() -> [ToolsModel] {
        let item00 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Text"),imageName: "template-text")
        let item02 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Photos"),imageName: "template-photos")
        let item03 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Stickers"),imageName: "template-stickers")
        let item04 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Ratio"),imageName: "template-ratio")
        let items = [item00,item02,item03,item04]
        return items
    }
    
    static func getTemplateToolsData() -> [ToolsModel] {
        let item00 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Text"),imageName: "template-text")
        let item01 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Background"),imageName: "template-Background")
        let item02 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Photos"),imageName: "template-photos")
        let item03 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Stickers"),imageName: "template-stickers")
        let item04 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Ratio"),imageName: "template-ratio")
        let items = [item00,item01,item02,item03,item04]
        return items
    }
    
    static func getStickerToolsData() -> [ToolsModel] {
        let item00 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Replace"),imageName: "template-replace")
        let item01 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Duplicate"),imageName: "template-duplicate")
        let item02 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Crop"),imageName: "template-crop")
        let item03 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("FlipH"),imageName: "template-FlipH")
        let item04 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("FlipV"),imageName: "template-FlipV")
        let item05 = ToolsModel(text: BSWHPhotoPickerLocalization.shared.localized("Remove"),imageName: "template-remove")
        let items = [item00,item01,item02,item03,item04,item05]
        return items
    }
    
    static func getRatioToolsData() -> [[RatioToolsModel]] {
        let item00 = RatioToolsModel(text: "1:1",imageName: "ratio1-1",width: 1.0,height: 1.0)
        let item01 = RatioToolsModel(text: "16:9",imageName: "ratio16-9",width: 16.0,height: 9.0)
        let item02 = RatioToolsModel(text: "5:4",imageName: "ratio5-4",width: 5.0,height: 4.0)
        let item03 = RatioToolsModel(text: "7:5",imageName: "ratio7-5",width: 7.0,height: 5.0)
        let item04 = RatioToolsModel(text: "4:3",imageName: "ratio4-3",width: 4.0,height: 3.0)
        let item05 = RatioToolsModel(text: "9:16",imageName: "ratio9-16",width: 9.0,height: 16.0)
        let item06 = RatioToolsModel(text: "5:3",imageName: "ratio5-3",width: 5.0,height: 3.0)
        let item07 = RatioToolsModel(text: "3:2",imageName: "ratio3-2",width: 3.0,height: 2.0)
        let item08 = RatioToolsModel(text: "3:4",imageName: "ratio3-4",width: 3.0,height: 4.0)
        
        let item10 = RatioToolsModel(text: "Postcard",imageName: "print-00-postcard",width: 3.0,height: 2.0)
        let item11 = RatioToolsModel(text: "Poster",imageName: "print-01-poster",width: 4.0,height: 5.0)
        let item12 = RatioToolsModel(text: "Poster",imageName: "print-02-poster",width: 5.0,height: 4.0)
        let item13 = RatioToolsModel(text: "A4",imageName: "print-03-A4",width: 1.0,height: 1.414)
        let item14 = RatioToolsModel(text: "A4",imageName: "print-04-A4",width: 1.414,height: 1.0)
        let item15 = RatioToolsModel(text: "Letter",imageName: "print-05-Letter",width: 1.0,height: 1.294)
        let item16 = RatioToolsModel(text: "Letter",imageName: "print-06-Letter",width: 1.294,height: 1.0)
        let item17 = RatioToolsModel(text: "Half letter",imageName: "print-07-HLetter",width: 1.0,height: 1.545)
        let item18 = RatioToolsModel(text: "Half letter",imageName: "print-08-HLetter",width: 1.545,height: 1.0)
        let item19 = RatioToolsModel(text: "Postcard",imageName: "print-09-postcard",width: 2.0,height: 3.0)

        let item20 = RatioToolsModel(text: "Square",imageName: "social-00-square",width: 1.0,height: 1.0)
        let item21 = RatioToolsModel(text: "Portrait",imageName: "social-01-portrait",width: 4.0,height: 5.0)
        let item22 = RatioToolsModel(text: "Story",imageName: "social-02-Story",width: 9.0,height: 16.0)
        let item23 = RatioToolsModel(text: "Post",imageName: "social-03-post",width: 1.91,height: 1.0)
        let item24 = RatioToolsModel(text: "Cover",imageName: "social-04-cover",width: 16.0,height: 9.0)
        
        let item25 = RatioToolsModel(text: "Post",imageName: "social-05-post",width: 2.0,height: 3.0)
        let item26 = RatioToolsModel(text: "Post",imageName: "social-06-postX",width: 16.0,height: 9.0)
        let item27 = RatioToolsModel(text: "Header",imageName: "social-07-header",width: 3.0,height: 1.0)
        let item28 = RatioToolsModel(text: "YouTube",imageName: "social-08-YouTube",width: 16.0,height: 9.0)
        let item29 = RatioToolsModel(text: "Shopify",imageName: "social-09-Shopify",width: 1.0,height: 1.0)
        let item30 = RatioToolsModel(text: "Shopify",imageName: "social-10-Shopify",width: 1.0,height: 1.1)
        let item31 = RatioToolsModel(text: "Shopify",imageName: "social-11-Shopify",width: 4.0,height: 5.0)
        let item32 = RatioToolsModel(text: "Amazon",imageName: "social-12-Amazon",width: 1.0,height: 1.0)
        let item33 = RatioToolsModel(text: "Shopee",imageName: "social-13-Shopee",width: 1.0,height: 1.0)
        let item34 = RatioToolsModel(text: "Facebook",imageName: "social-14-Facebook",width: 1.0,height: 1.0)
        let item35 = RatioToolsModel(text: "Linkedin",imageName: "social-15-linkedin",width: 1.91,height: 1.0)
        let item36 = RatioToolsModel(text: "Linkedin",imageName: "social-16-linkedin",width: 1.0,height: 1.0)
        let item37 = RatioToolsModel(text: "Tiktok",imageName: "social-17-tiktok",width: 9.0,height: 16.0)
        let item38 = RatioToolsModel(text: "Tiktok",imageName: "social-18-tiktok",width: 1.0,height: 1.0)
        let item39 = RatioToolsModel(text: "Ebay",imageName: "social-19-ebay",width: 1.0,height: 1.0)
        let item40 = RatioToolsModel(text: "Poshmark",imageName: "social-20-Poshmark",width: 1.0,height: 1.0)
        let item41 = RatioToolsModel(text: "Etsy",imageName: "social-21-etsy",width: 5.0,height: 4.0)
        let item42 = RatioToolsModel(text: "Depop",imageName: "social-22-depop",width: 1.0,height: 1.0)

        let items = [[item00,item01,item02,item03,item04,item05,item06,item07,item08],[item20,item21,item22,item23,item24,item34,item37,item38,item28,item26,item27,item35,item36,item25,item29,item30,item31,item32,item33,item39,item41,item42,item40],[item10,item11,item12,item13,item14,item15,item16,item17,item18,item19]]
        return items
    }
}
