//
//  ImageStickerModel.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/10/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

struct ImageStickerModel: Codable {
    let image:String
    let originScale:Double
    let originAngle:Double
    let originFrameX:Double
    let originFrameY:Double
    let originFrameWidth:Double
    let originFrameHeight:Double
    let gesScale:Double
    let gesRotation:Double
}
