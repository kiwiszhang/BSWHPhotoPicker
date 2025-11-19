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

public struct TemplateModel {
    var imageName:String = "1"
    var imageBg:String = "Christmas00-bg"
    var jsonName:String = "Christmas00"
}

class ConfigDataItem {
    
    static func getTemplateTabData() -> [String] {
        let items = [StickerManager.shared.config.all, StickerManager.shared.config.Christmas,"Baby"]
        return items
    }
    
    static func getTemplateListData() -> [[TemplateModel]] {
        let item00 = TemplateModel(imageName: "1",imageBg: "Christmas00-bg",jsonName: "Christmas00")
        let item01 = TemplateModel(imageName: "2",imageBg: "Christmas01-bg",jsonName: "Christmas01")
        let item02 = TemplateModel(imageName: "3",imageBg: "Christmas02-bg",jsonName: "Christmas02")
        let item03 = TemplateModel(imageName: "4",imageBg: "Christmas03-bg",jsonName: "Christmas03")
        let item04 = TemplateModel(imageName: "5",imageBg: "Christmas04-bg",jsonName: "Christmas04")
        let item05 = TemplateModel(imageName: "6",imageBg: "Christmas05-bg",jsonName: "Christmas05")
        let item06 = TemplateModel(imageName: "7",imageBg: "Christmas06-bg",jsonName: "Christmas06")
        
        let item10 = TemplateModel(imageName: "baby01",imageBg: "baby01-bg",jsonName: "baby01")
        let item11 = TemplateModel(imageName: "baby02",imageBg: "baby02-bg",jsonName: "baby02")
        let item12 = TemplateModel(imageName: "baby03",imageBg: "baby03-bg",jsonName: "baby03")
        let item13 = TemplateModel(imageName: "baby04",imageBg: "baby04-bg",jsonName: "baby04")
        let item14 = TemplateModel(imageName: "baby05",imageBg: "baby05-bg",jsonName: "baby05")
        let item15 = TemplateModel(imageName: "baby06",imageBg: "baby06-bg",jsonName: "baby06")

        let items = [[item00,item01,item02,item03,item04,item05,item06,item10,item11,item12,item13,item14,item15],[item00,item01,item02,item03,item04,item05,item06],[item10,item11,item12,item13,item14,item15]]
        
        return items
    }
    
    
    static func getTemplateToolsData() -> [ToolsModel] {
        let item00 = ToolsModel(text: StickerManager.shared.config.Text,imageName: "template-text")
        let item01 = ToolsModel(text: StickerManager.shared.config.Background,imageName: "template-Background")
        let item02 = ToolsModel(text: StickerManager.shared.config.Photos,imageName: "template-photos")
        let item03 = ToolsModel(text: StickerManager.shared.config.Stickers,imageName: "template-stickers")
        let item04 = ToolsModel(text: StickerManager.shared.config.Ratio,imageName: "template-ratio")
        let items = [item00,item01,item02,item03,item04]
        return items
    }
    
    static func getStickerToolsData() -> [ToolsModel] {
        let item00 = ToolsModel(text: StickerManager.shared.config.Replace,imageName: "template-replace")
        let item01 = ToolsModel(text: StickerManager.shared.config.Duplicate,imageName: "template-duplicate")
        let item02 = ToolsModel(text: StickerManager.shared.config.Crop,imageName: "template-crop")
        let item03 = ToolsModel(text: StickerManager.shared.config.FlipH,imageName: "template-FlipH")
        let item04 = ToolsModel(text: StickerManager.shared.config.FlipV,imageName: "template-FlipV")
        let item05 = ToolsModel(text: StickerManager.shared.config.Remove,imageName: "template-remove")
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

        let items = [[item00,item01,item02,item03,item04,item05,item06,item07,item08],[item20,item21,item22,item23,item24,item25,item26,item27,item28,item29,item30,item31,item32,item33,item34,item35,item36,item37,item38,item39,item40,item41,item42],[item10,item11,item12,item13,item14,item15,item16,item17,item18,item19]]
        return items
    }
}
