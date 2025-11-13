//
//  UIFont+Extension.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/4/17.
//

import Foundation
import UIKit

//enum HelveticaNeueWeight: String {
//    case ultraLight = "UltraLight"
//    case light = "Light"
//    case regular = ""          // HelveticaNeue 无后缀
//    case medium = "Medium"
//    case bold = "Bold"
//    case condensedBold = "CondensedBold"
//}

public enum InterWeightBase {
    case lightBase, regularBase, mediumBase, boldBase
}

public enum ArchivoBlackWeightBase {
    case  regularBase
}



public extension UIFont {
    static func interBase(size: CGFloat, weight: InterWeightBase = .regularBase) -> UIFont {
        
//        let fontName = "HelveticaNeue" + (weight.rawValue.isEmpty ? "" : "-\(weight.rawValue)")
//        if let font = UIFont(name: fontName, size: size) {
//            return font
//        }
        
//        // 对应 SwiftGen fonts.yml 里生成的
//        let fontConvertible: FontConvertible
//        switch weight {
//        case .light:
//            fontConvertible = FontFamily.Inter.lightBETA
//        case .regular:
//            fontConvertible = FontFamily.Inter.regular
//        case .medium:
//            fontConvertible = FontFamily.Inter.medium
//        case .bold:
//            fontConvertible = FontFamily.Inter.bold
//        }
//
//        let customFont = fontConvertible.font(size: size)
//        return customFont
        
        let systemWeight: UIFont.Weight
        switch weight {
        case .lightBase:      systemWeight = .light
        case .regularBase:    systemWeight = .regular
        case .mediumBase:     systemWeight = .medium
        case .boldBase:       systemWeight = .bold
        }
        return UIFont.systemFont(ofSize: size, weight: systemWeight)

    }
    
    static func archivoBlackBase(size: CGFloat, weight: ArchivoBlackWeightBase = .regularBase) -> UIFont {
        // 对应 SwiftGen fonts.yml 里生成的
        let systemWeight: UIFont.Weight
        switch weight {
            case .regularBase:    systemWeight = .regular
        }
        return UIFont.systemFont(ofSize: size, weight: systemWeight)
    }

}
