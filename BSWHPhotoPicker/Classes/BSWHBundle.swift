//
//  TLBundle.swift
//  Pods
//
//  Created by wade.hawk on 2017. 5. 9..
//
//

import UIKit

open class BSWHBundle {

    /// 获取 bundle
    public class func bundle() -> Bundle {
        let podBundle = Bundle(for: BSWHBundle.self)
        if let url = podBundle.url(forResource: "BSWHPhotoPicker", withExtension: "bundle") {
            return Bundle(url: url) ?? podBundle
        }
        return podBundle
    }

    // MARK: - 图片资源
//    public class func image(named name: String) -> UIImage? {
//        let bundle = self.bundle()
//        return UIImage(named: name, in: bundle, compatibleWith: nil)
//    }
    public class func image(named name: String) -> UIImage? {
        let bundle = self.bundle()
        
        // 优先匹配完整文件名
        if let path = bundle.path(forResource: name, ofType: nil) {
            return UIImage(contentsOfFile: path)
        }

        // 尝试 png
        if let path = bundle.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }

        // 尝试 jpg
        if let path = bundle.path(forResource: name, ofType: "jpg") {
            return UIImage(contentsOfFile: path)
        }

        return nil
    }



    // MARK: - JSON 资源
    public class func json(named name: String) -> [String: Any]? {
        let bundle = self.bundle()
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            print("❌ JSON file not found:", name)
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("❌ Failed to load JSON:", error)
            return nil
        }
    }

    // MARK: - 读取任意文件 URL
    public class func url(forResource name: String, withExtension ext: String) -> URL? {
        return bundle().url(forResource: name, withExtension: ext)
    }
}

//// 图片
//let image = BSWHBundle.image(named: "wedding-sticker-bg01")
//
//// JSON
//if let dict = BSWHBundle.json(named: "sticker_config") {
//    print(dict)
//}
//
//// 任意文件 URL
//if let fileURL = BSWHBundle.url(forResource: "sticker_config", withExtension: "json") {
//    print(fileURL)
//}

public class BSWHPhotoPickerLocalization {

    public static let shared = BSWHPhotoPickerLocalization()
    public var currentLanguage: String = Locale.current.identifier {
        didSet {
            bundle = bundleForLanguage(currentLanguage)
        }
    }

    private var bundle: Bundle?

    private init() {
        bundle = bundleForLanguage(currentLanguage)
    }

    private func bundleForLanguage(_ lang: String) -> Bundle? {
        let podBundle = BSWHBundle.bundle()
        guard let path = podBundle.path(forResource: lang, ofType: "lproj"),
              let langBundle = Bundle(path: path) else {
            return podBundle
        }
        return langBundle
    }

    public func localized(_ key: String) -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}
