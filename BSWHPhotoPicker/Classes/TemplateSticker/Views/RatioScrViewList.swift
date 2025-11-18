//
//  TemplateList.swift
//  BSWHPhotoPicker_Example
//
//  Created by 笔尚文化 on 2025/11/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

protocol RatioScrViewListDelegate: AnyObject {
    func ratioScrViewDidSelect(index: Int)
}
class RatioScrViewList: UIView {

    var titles: [String] = [] {
        didSet { reloadData() }
    }
    
    var btnFont: UIFont = .systemFont(ofSize: 14.h, weight: .regular)
    var btnSelectedFont: UIFont = .systemFont(ofSize: 14.h, weight: .bold)
    
    var btnColor: UIColor = .black
    var btnSelectedTextColor: UIColor = kkColorFromHex("A216FF")   // 选中颜色（你可以改）
    
    weak var delegate: RatioScrViewListDelegate?

    private let scrollView = UIScrollView()
    private var buttonArray: [UIButton] = []
    private var indicatorArray: [UIView] = []   // 🔥 小圆点数组
    private var selectedIndex: Int = 0
    
    private var isLinking = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func reloadData() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        buttonArray.removeAll()
        indicatorArray.removeAll()
        
        var lastView: UIView?

        for (i, title) in titles.enumerated() {

            // -----------------
            // 按钮
            // -----------------
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(btnColor, for: .normal)
            btn.setTitleColor(btnSelectedTextColor, for: .selected)
            btn.titleLabel?.font = btnFont
            btn.tag = i
            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)
            btn.addTarget(self, action: #selector(btnTapped(_:)), for: .touchUpInside)
            scrollView.addSubview(btn)
            buttonArray.append(btn)

            btn.snp.makeConstraints { make in
                make.top.equalToSuperview()
                if let last = lastView {
                    make.left.equalTo(last.snp.right).offset(18)
                } else {
                    make.left.equalToSuperview().offset(18)
                }
            }
            
            // -----------------
            // 小圆点 indicator
            // -----------------
            let indicator = UIView()
            indicator.backgroundColor = btnSelectedTextColor
            indicator.layer.cornerRadius = 2
            indicator.isHidden = true
            scrollView.addSubview(indicator)
            indicatorArray.append(indicator)

            indicator.snp.makeConstraints { make in
                make.top.equalTo(btn.snp.bottom).offset(-2)
                make.centerX.equalTo(btn)
                make.width.height.equalTo(4)
                make.bottom.equalToSuperview() // 让 scrollView contentSize 自动撑开
            }

            lastView = indicator
        }

        layoutIfNeeded()
        updateSelection(index: selectedIndex, animated: false)
    }

    @objc private func btnTapped(_ sender: UIButton) {
        selectIndex(index: sender.tag, animated: true)
        delegate?.ratioScrViewDidSelect(index: sender.tag)
    }

    func selectIndex(index: Int, animated: Bool) {
        guard index >= 0, index < buttonArray.count else { return }
        isLinking = true
        updateSelection(index: index, animated: animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLinking = false
        }
    }

    private func updateSelection(index: Int, animated: Bool) {
        selectedIndex = index
        
        for (i, btn) in buttonArray.enumerated() {
            let indicator = indicatorArray[i]
            
            if i == index {
                btn.isSelected = true
                btn.titleLabel?.font = btnSelectedFont
                indicator.isHidden = false       // 🔥 显示圆点
            } else {
                btn.isSelected = false
                btn.titleLabel?.font = btnFont
                indicator.isHidden = true        // 🔥 隐藏圆点
            }
        }

        // 居中滚动
        let selBtn = buttonArray[index]
        DispatchQueue.main.async {
            guard self.scrollView.contentSize.width > self.scrollView.frame.width else { return }

            let offsetX = max(0, selBtn.center.x - self.scrollView.frame.width / 2)
            let finalX = min(offsetX, self.scrollView.contentSize.width - self.scrollView.frame.width)
            self.scrollView.setContentOffset(CGPoint(x: finalX, y: 0), animated: animated)
        }
    }
}

