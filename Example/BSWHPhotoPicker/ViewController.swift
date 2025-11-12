//
//  ViewController.swift
//  BSWHPhotoPicker
//
//  Created by caoguangming on 09/11/2025.
//  Copyright (c) 2025 caoguangming. All rights reserved.
//

public let kkScreenWidth = UIScreen.main.bounds.size.width
public let kkScreenHeight = UIScreen.main.bounds.size.height


import UIKit
import BSWHPhotoPicker

class ViewController: UIViewController {
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("模版列表", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .blue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(50)
        }
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
    }
    @objc private func onClickBack(_ sender: UIButton) {
        let vc = UINavigationController(rootViewController: TemplateViewController())
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}


