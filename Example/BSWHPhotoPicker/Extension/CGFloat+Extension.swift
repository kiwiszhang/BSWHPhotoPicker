//
//  CGFloat+Extension.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/4/23.
//

import UIKit

public extension CGFloat {
    //屏幕宽高
    var w: CGFloat {
        let standardWidth: CGFloat = 375
        let screenWidth = UIScreen.main.bounds.width
        return self * (screenWidth / standardWidth)
    }

    var h: CGFloat {
        let standardHeight: CGFloat = 812
        let screenHeight = UIScreen.main.bounds.height
        return self * (screenHeight / standardHeight)
    }
}
