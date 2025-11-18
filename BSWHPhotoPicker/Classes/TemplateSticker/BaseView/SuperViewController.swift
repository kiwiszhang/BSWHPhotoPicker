//
//  SuperViewController.swift
//  MobileProgect
//
//  Created by csqiuzhi on 2019/4/30.
//  Copyright © 2019 于晓杰. All rights reserved.
//

import UIKit

open class SuperViewController: UIViewController {
    //MARK: ----------懒加载-----------
    //MARK: ----------系统方法-----------
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpUI()
        getData()
    }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
//MARK: ----------UI-----------
extension SuperViewController {
    @objc open func setUpUI() {
    }
}

//MARK: ----------网络请求-----------
extension SuperViewController {
    @objc open func getData() {
        
    }
}
//MARK: ----------其他-----------
extension SuperViewController {
    @objc open func closeBtnMethord() {
        dismiss(animated: true, completion: nil)
    }
}
//MARK: ----------切换语言-----------
extension SuperViewController {
    @objc open func updateLanguageUI() {
        // 子类重写此方法实现具体更新逻辑
    }
}

