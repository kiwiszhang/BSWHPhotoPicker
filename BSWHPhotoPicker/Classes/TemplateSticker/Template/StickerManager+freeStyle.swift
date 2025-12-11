
//
//  StickerManager.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/10/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//
extension StickerManager {

    func freeStyleAddImages(images: [UIImage], canvasSize: CGSize) {
        let sizes = images.map { $0.size }
            var frames: [CGRect] = []

        switch images.count {
            case 1: frames = [layout1(imageSize: sizes[0], canvas: canvasSize)]
            case 2: frames = layout2(imageSizes: sizes, canvas: canvasSize)
            case 3: frames = layout3(imageSizes: sizes, canvas: canvasSize)
            case 4: frames = layout4(imageSizes: sizes, canvas: canvasSize)
            case 5: frames = layout5(imageSizes: sizes, canvas: canvasSize)
            case 6: frames = layout6(imageSizes: sizes, canvas: canvasSize)
            case 7: frames = layout7(imageSizes: sizes, canvas: canvasSize)
            case 8: frames = layout8(imageSizes: sizes, canvas: canvasSize)
            case 9: frames = layout9(imageSizes: sizes, canvas: canvasSize)
            case 10: frames = layout10(imageSizes: sizes, canvas: canvasSize)
            case 11: frames = layout11(imageSizes: sizes, canvas: canvasSize)
            case 12: frames = layout12(imageSizes: sizes, canvas: canvasSize)
            default: return
            }


            for (index, img) in images.enumerated() {

                let frame = frames[index]

                let state = ImageStickerModel(
                    imageName: "empty",
                    imageData: img.jpegData(compressionQuality: 1),
                    originFrame: frame,
                    gesScale: 1,
                    gesRotation: 0,
                    overlayRect: CGRect(x:0,y:0,width:1,height:1),
                    isBgImage: false
                )

            let sticker = self.controller!.addImageSticker01(state: state,isFreeStyle: true)
            sticker.stickerModel = state
            StickerManager.shared.modelMap[sticker.id] = state
            StickerManager.shared.stickerArr.append(sticker)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.stickerTapped(_:)))
            sticker.addGestureRecognizer(tap)
            if let image = sticker.stickerModel?.stickerImage {
                sticker.updateImage(image, stickerModel: sticker.stickerModel!, withBaseImage: sticker.image,vc: self.controller!)
            }
            self.controller?.backAndreBackStatus()
        }
    }

    
    func aspectFitSize(imageSize: CGSize, boundingSize: CGSize) -> CGSize {
        let wScale = boundingSize.width / imageSize.width
        let hScale = boundingSize.height / imageSize.height
        let scale = min(wScale, hScale) * 0.9

        return CGSize(width: imageSize.width * scale,
                      height: imageSize.height * scale)
    }

    func layout1(imageSize: CGSize, canvas: CGSize) -> CGRect {
        let size = aspectFitSize(imageSize: imageSize, boundingSize: canvas)
        return CGRect(
            x: (canvas.width - size.width)/2,
            y: (canvas.height - size.height)/2,
            width: size.width, height: size.height
        )
    }

    func layout2(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        let halfWidth = canvas.width / 2

        return imageSizes.enumerated().map { index, imgSize in
            let bounding = CGSize(width: halfWidth, height: canvas.height)
            let size = aspectFitSize(imageSize: imgSize, boundingSize: bounding)

            let originX = index == 0 ? (halfWidth - size.width)/2 : (halfWidth + (halfWidth - size.width)/2)

            return CGRect(
                x: originX,
                y: (canvas.height - size.height)/2,
                width: size.width,
                height: size.height
            )
        }
    }

    func layout3(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        let topHeight = canvas.height / 2
        let bottomHeight = canvas.height / 2
        let halfWidth = canvas.width / 2

        var frames: [CGRect] = []

        // 第一张 → 顶部单张
        let topBounding = CGSize(width: canvas.width, height: topHeight)
        let topSize = aspectFitSize(imageSize: imageSizes[0], boundingSize: topBounding)
        frames.append(
            CGRect(x: (canvas.width-topSize.width)/2,
                   y: (topHeight-topSize.height)/2,
                   width: topSize.width, height: topSize.height)
        )

        // 第二、三张 → 底部左右
        for (i, imgSize) in imageSizes[1...].enumerated() {
            let bounding = CGSize(width: halfWidth, height: bottomHeight)
            let size = aspectFitSize(imageSize: imgSize, boundingSize: bounding)

            let originX = i == 0 ? (halfWidth - size.width)/2 : (halfWidth + (halfWidth - size.width)/2)

            frames.append(
                CGRect(x: originX,
                       y: topHeight + (bottomHeight-size.height)/2,
                       width: size.width, height: size.height)
            )
        }

        return frames
    }

    func layout4(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        let halfW = canvas.width / 2
        let halfH = canvas.height / 2

        return imageSizes.enumerated().map { index, imgSize in
            let bounding = CGSize(width: halfW, height: halfH)
            let size = aspectFitSize(imageSize: imgSize, boundingSize: bounding)

            let col = index % 2
            let row = index / 2

            let x = CGFloat(col) * halfW + (halfW - size.width)/2
            let y = CGFloat(row) * halfH + (halfH - size.height)/2

            return CGRect(x: x, y: y, width: size.width, height: size.height)
        }
    }

    func layout5(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        let cols = 3
        let rows = 2
        let cellW = canvas.width / CGFloat(cols)
        let cellH = canvas.height / CGFloat(rows)

        var frames = layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: rows, cols: cols)

        // 最后一张居中偏移（位置 index=4 → 第 2 行第 2 列）
        let centerX = cellW * 1 + cellW/2
        let centerY = cellH * 1 + cellH/2

        let last = frames[4]
        frames[4] = CGRect(
            x: centerX - last.width/2,
            y: centerY - last.height/2,
            width: last.width,
            height: last.height
        )
        return frames
    }

    func layout6(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        return layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: 2, cols: 3)
    }

    func layout7(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {

        // 1. 做一个 3x3 grid
        let grid = layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: 3, cols: 3)

        // grid indexes:
        // 0 1 2
        // 3 4 5
        // 6 7 8

        // 2. 放置前 6 张（不使用中间格子 4）
        let indexMap = [0, 1, 2, 3, 5, 6]
        var frames: [CGRect] = []

        for i in 0..<6 {
            frames.append(grid[indexMap[i]])
        }

        // 3. 第 7 张（最后一张）手动居中
        let lastSize = imageSizes[6]
        let fitted = fitSizeToGrid(size: lastSize, cell: CGRect(x: 0, y: 0, width: canvas.width/3, height: canvas.height/3))

        let centerFrame = CGRect(
            x: (canvas.width - fitted.width) / 2,
            y: (canvas.height - fitted.height) / 2,
            width: fitted.width,
            height: fitted.height
        )

        frames.append(centerFrame)

        return frames
    }

    func fitSizeToGrid(size: CGSize, cell: CGRect) -> CGSize {
        let bounding = CGSize(width: cell.width, height: cell.height)
        return aspectFitSize(imageSize: size, boundingSize: bounding)
    }
    func layout8(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {

        // 1. 创建 3×3 grid
        let grid = layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: 3, cols: 3)

        // grid indexes:
        // 0 1 2
        // 3 4 5
        // 6 7 8

        // 2. 前 7 张：跳过 4（中间格子）
        let indexMap = [0, 1, 2, 3, 5, 6, 7]  // 不放 4（中间）
        var frames: [CGRect] = []

        for i in 0..<7 {
            let gridFrame = grid[indexMap[i]]
            let fittedSize = fitSizeToGrid(size: imageSizes[i], cell: gridFrame)

            let frame = CGRect(
                x: gridFrame.midX - fittedSize.width / 2,
                y: gridFrame.midY - fittedSize.height / 2,
                width: fittedSize.width,
                height: fittedSize.height
            )

            frames.append(frame)
        }

        // 3. 第 8 张（最后一张）居中放置
        let lastSize = imageSizes[7]

        // 中间 cell 空着 → 自己计算中心
        let centerCell = CGRect(
            x: canvas.width / 3,
            y: canvas.height / 3,
            width: canvas.width / 3,
            height: canvas.height / 3
        )

        let lastFit = fitSizeToGrid(size: lastSize, cell: centerCell)

        let centerFrame = CGRect(
            x: (canvas.width - lastFit.width) / 2,
            y: (canvas.height - lastFit.height) / 2,
            width: lastFit.width,
            height: lastFit.height
        )

        frames.append(centerFrame)

        return frames
    }


    func layout9(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        return layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: 3, cols: 3)
    }

    func layout10(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        return layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: 3, cols: 4)
    }

    func layout11(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        return layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: 3, cols: 4)
    }

    func layout12(imageSizes: [CGSize], canvas: CGSize) -> [CGRect] {
        return layoutGrid(imageSizes: imageSizes, canvas: canvas, rows: 3, cols: 4)
    }

    func layoutGrid(imageSizes: [CGSize], canvas: CGSize, rows: Int, cols: Int) -> [CGRect] {

        let cellW = canvas.width / CGFloat(cols)
        let cellH = canvas.height / CGFloat(rows)

        var frames: [CGRect] = []

        for index in 0..<imageSizes.count {
            let row = index / cols
            let col = index % cols

            let bounding = CGSize(width: cellW, height: cellH)
            let size = aspectFitSize(imageSize: imageSizes[index], boundingSize: bounding)

            let x = CGFloat(col) * cellW + (cellW - size.width)/2
            let y = CGFloat(row) * cellH + (cellH - size.height)/2

            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
        }

        return frames
    }

    
}
