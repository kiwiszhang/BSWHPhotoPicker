//
//  SuperView.swift
//  MobileProgect
//
//  Created by csqiuzhi on 2019/5/24.
//  Copyright © 2019 于晓杰. All rights reserved.
//

import UIKit

open class SuperView: UIView {
    // ✅ 指定初始化方法
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    // ✅ 从 Storyboard / XIB 初始化
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // ✅ 抽取公共初始化逻辑
    private func commonInit() {
        setUpUI()
        getData()
    }
}

//MARK: ----------UI-----------
extension SuperView {
    @objc open func setUpUI() {
        backgroundColor(.clear)
    }
    
    @objc open func getData() {
        
    }
}

//MARK: ----------切换语言-----------
extension SuperView {
    @objc open func updateLanguageUI() {
        // 子类重写此方法实现具体更新逻辑
    }
}

public func kkColorFromHexWithAlpha(_ hex: Int, _ alpha: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(((hex & 0xFF0000) >> 16)) / 255.0,
                   green: CGFloat(((hex & 0xFF00) >> 8)) / 255.0,
                   blue: CGFloat((hex & 0xFF)) / 255.0,
                   alpha: alpha)
}
public func kkColorFromHex(_ hex: Int) -> UIColor {
    return kkColorFromHexWithAlpha(hex, 1)
}

public func kkColorFromHex(_ hex: String) -> UIColor {
    var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexString.hasPrefix("#") {
        hexString.remove(at: hexString.startIndex)
    }
    
    var rgbValue: UInt64 = 0
    Scanner(string: hexString).scanHexInt64(&rgbValue)
    
    // 根据十六进制字符串长度判断是否包含透明度
    switch hexString.count {
    case 8: // 包含透明度 #RRGGBBAA
        return UIColor(red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                  blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                  alpha: CGFloat(rgbValue & 0x000000FF) / 255.0)
        
    case 6: // 不包含透明度 #RRGGBB
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: 1)
        
    default: // 默认返回黑色
        return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
