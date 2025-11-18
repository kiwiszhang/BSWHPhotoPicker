//
//  UIView+Create.swift
//  MobileProject
//
//  Created by Yu on 2025/4/4.
//

import UIKit

public extension UIImageView {
    @discardableResult
    func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
//    UIImage 必须是 模板图片（renderingMode = .alwaysTemplate），tintColor 才会生效。
//    模板图片就是忽略原来的颜色，只保留形状（Alpha 通道），然后用 tintColor 来着色。
//    常见的系统图标（SF Symbols，或者 UIImage(systemName:)）默认就是模板图片
    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        tintColor = color
        return self
    }
    
    func loadGif(name: String, cropRect: CGRect? = nil, animated: Bool = false, duration: TimeInterval = 0.25) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                return
            }

            let count = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var totalDuration: TimeInterval = 0

            // 读取每一帧
            for i in 0 ..< count {
                guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                    continue
                }
                
                // 如果指定了裁剪区域，进行裁剪
                let finalImage: CGImage
                if let rect = cropRect, let croppedImage = cgImage.cropping(to: rect) {
                    finalImage = croppedImage
                } else {
                    finalImage = cgImage
                }

                // 获取帧延迟时间
                guard let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                      let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                      let duration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double else {
                    continue
                }

                totalDuration += duration
                images.append(UIImage(cgImage: finalImage))
            }
            let image = UIImage.animatedImage(with: images, duration: totalDuration)
            DispatchQueue.main.async {
                if animated {
                    UIView.transition(
                        with: self,
                        duration: duration,
                        options: [.transitionCrossDissolve, .curveEaseInOut, .allowUserInteraction]
                    ) {
                        self.image = image
                    }
                } else {
                    self.image = image
                }
            }
        }
    }
}

extension UIView {
    func toImage(targetSize: CGSize? = nil) -> UIImage {
        self.layoutIfNeeded()

        let renderSize = targetSize ?? self.bounds.size
        guard renderSize.width > 0, renderSize.height > 0 else {
            print("❌ Invalid render size:", renderSize)
            return UIImage()
        }

        // 🔥 临时调整 bounds
        let oldBounds = self.bounds
        self.bounds = CGRect(origin: .zero, size: renderSize)

        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        let img = renderer.image { ctx in
            self.layer.render(in: ctx.cgContext)
        }

        self.bounds = oldBounds // 恢复
        return img
    }
}

