//
//  UILabel+Create.swift
//  MobileProject
//
//  Created by Yu on 2025/4/4.
//

import UIKit

public extension UILabel {
    //每个项目单独处理
    @discardableResult
    func hnFont(size: CGFloat, weight: InterWeightBase = .regularBase) -> Self {
        self.font = UIFont.interBase(size: size, weight: weight)
        return self
    }
    
    @discardableResult
    func abFont(size: CGFloat, weight: ArchivoBlackWeightBase = .regularBase) -> Self {
        self.font = UIFont.archivoBlackBase(size: size, weight: weight)
        return self
    }


    @discardableResult
    func text(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func minimumScaleFactor(_ scale: Double) -> Self {
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = scale
        return self
    }
    
    @discardableResult
    func color(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
    
    @discardableResult
    func systemFont(size: CGFloat, weight: UIFont.Weight = .regular) -> Self {
        font = .systemFont(ofSize: size, weight: weight)
        return self
    }
    
    @discardableResult
    func boldFont(size: CGFloat) -> Self {
        font = .boldSystemFont(ofSize: size)
        return self
    }
    
    @discardableResult
    func italicFont(size: CGFloat) -> Self {
        font = .italicSystemFont(ofSize: size)
        return self
    }
    
    @discardableResult
    func fontSize(_ size: CGFloat, weight: UIFont.Weight = .regular) -> Self {
        font = .systemFont(ofSize: size, weight: weight)
        return self
    }
    
    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func lines(_ number: Int) -> Self {
        numberOfLines = number
        return self
    }
    
    @discardableResult
    func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
        lineBreakMode = mode
        return self
    }
    
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString?) -> Self {
        self.attributedText = attributedText
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjusts: Bool) -> Self {
        adjustsFontSizeToFitWidth = adjusts
        return self
    }
    
    @discardableResult
    func centerAligned() -> Self {
        textAlignment = .center
        return self
    }
    
    @discardableResult
    func leftAligned() -> Self {
        textAlignment = .left
        return self
    }
    
    @discardableResult
    func rightAligned() -> Self {
        textAlignment = .right
        return self
    }
}

public extension UILabel {
    /// 设置行高,行间距
   @discardableResult
    func setLineHeight(_ lineHeight: CGFloat) -> Self {
       guard let content = self.text ?? attributedText?.string, !content.isEmpty else { return self }
       
       let targetFont = self.font ?? UIFont.systemFont(ofSize: 17)
       let attributedString = NSMutableAttributedString(string: content)
       
       let paragraphStyle = NSMutableParagraphStyle()
       paragraphStyle.minimumLineHeight = lineHeight
       paragraphStyle.maximumLineHeight = lineHeight
       paragraphStyle.alignment = self.textAlignment
       paragraphStyle.lineBreakMode = self.lineBreakMode
       
       attributedString.addAttributes([
           .font: targetFont,
           .foregroundColor: self.textColor ?? .label,
           .paragraphStyle: paragraphStyle
       ], range: NSRange(location: 0, length: attributedString.length))
       self.attributedText = attributedString
       return self
   }
    
    /// 设置文字填充色（富文本）
    @discardableResult
    func foregroundColor(_ color: UIColor) -> Self {
        if let currentAttributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
            mutableAttributedText.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: mutableAttributedText.length))
            attributedText = mutableAttributedText
        } else if let text = text {
            attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: color])
        }
        return self
    }
    
    /// 设置文字描边颜色（富文本）
    @discardableResult
    func strokeColor(_ color: UIColor) -> Self {
        if let currentAttributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
            mutableAttributedText.addAttribute(.strokeColor, value: color, range: NSRange(location: 0, length: mutableAttributedText.length))
            attributedText = mutableAttributedText
        } else if let text = text {
            attributedText = NSAttributedString(string: text, attributes: [.strokeColor: color])
        }
        return self
    }
    
    /// 设置文字描边宽度（富文本）
    /// 正值：只描边 | 负值：描边+填充 | 0：无效果
    @discardableResult
    func strokeWidth(_ width: CGFloat) -> Self {
        if let currentAttributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
            mutableAttributedText.addAttribute(.strokeWidth, value: width, range: NSRange(location: 0, length: mutableAttributedText.length))
            attributedText = mutableAttributedText
        } else if let text = text {
            attributedText = NSAttributedString(string: text, attributes: [.strokeWidth: width])
        }
        return self
    }
    
    /// 快速设置描边文字效果
    @discardableResult
    func strokeText(foreground: UIColor, strokeColor: UIColor, strokeWidth: CGFloat) -> Self {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: foreground,
            .strokeColor: strokeColor,
            .strokeWidth: strokeWidth
        ]
        
        if let currentAttributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
            mutableAttributedText.addAttributes(attributes, range: NSRange(location: 0, length: mutableAttributedText.length))
            attributedText = mutableAttributedText
        } else if let text = text {
            attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        return self
    }
    
    /// 设置字符间距
    @discardableResult
    func kern(_ spacing: CGFloat) -> Self {
        if let currentAttributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
            mutableAttributedText.addAttribute(.kern, value: spacing, range: NSRange(location: 0, length: mutableAttributedText.length))
            attributedText = mutableAttributedText
        } else if let text = text {
            attributedText = NSAttributedString(string: text, attributes: [.kern: spacing])
        }
        return self
    }
    
    /// 设置下划线
    @discardableResult
    func underline(style: NSUnderlineStyle = .single, color: UIColor? = nil) -> Self {
        if let currentAttributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
            mutableAttributedText.addAttribute(.underlineStyle, value: style.rawValue, range: NSRange(location: 0, length: mutableAttributedText.length))
            if let color = color {
                mutableAttributedText.addAttribute(.underlineColor, value: color, range: NSRange(location: 0, length: mutableAttributedText.length))
            }
            attributedText = mutableAttributedText
        } else if let text = text {
            var attributes: [NSAttributedString.Key: Any] = [.underlineStyle: style.rawValue]
            if let color = color {
                attributes[.underlineColor] = color
            }
            attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        return self
    }
    
    /// 设置删除线
    @discardableResult
    func strikethrough(style: NSUnderlineStyle = .single, color: UIColor? = nil) -> Self {
        if let currentAttributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
            mutableAttributedText.addAttribute(.strikethroughStyle, value: style.rawValue, range: NSRange(location: 0, length: mutableAttributedText.length))
            if let color = color {
                mutableAttributedText.addAttribute(.strikethroughColor, value: color, range: NSRange(location: 0, length: mutableAttributedText.length))
            }
            attributedText = mutableAttributedText
        } else if let text = text {
            var attributes: [NSAttributedString.Key: Any] = [.strikethroughStyle: style.rawValue]
            if let color = color {
                attributes[.strikethroughColor] = color
            }
            attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        return self
    }
}
