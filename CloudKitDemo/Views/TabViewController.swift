//
//  TabViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/1.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - View
    
    func setupViews() {
        view.backgroundColor = .white
        
        let ideasVC = IdeasViewController()
        ideasVC.title = "Ideas"
        let ideasNav = UINavigationController(rootViewController: ideasVC)
        ideasNav.tabBarItem = UITabBarItem(title: "CRUD", image: .checkmark, tag: 0)
        
        
        let photosVC = PhotosViewController()
        photosVC.title = "Photos"
        let photosNav = UINavigationController(rootViewController: photosVC)
        photosNav.tabBarItem = UITabBarItem(title: "Share", image: .checkmark, tag: 1)
        
        viewControllers = [ideasNav, photosNav]
    }
    
}
