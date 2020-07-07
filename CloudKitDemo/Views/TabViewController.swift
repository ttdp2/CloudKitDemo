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
        ideasNav.tabBarItem = UITabBarItem(title: "Basic", image: .checkmark, tag: 0)
        
        let ideasPlusVC = NotesViewController()
        ideasPlusVC.title = "Notes"
        let ideasPlusNav = UINavigationController(rootViewController: ideasPlusVC)
        ideasPlusNav.tabBarItem = UITabBarItem(title: "Advanced", image: .checkmark, tag: 1)
        
        let photosVC = PhotosViewController()
        photosVC.title = "Photos"
        let photosNav = UINavigationController(rootViewController: photosVC)
        photosNav.tabBarItem = UITabBarItem(title: "Share", image: .checkmark, tag: 2)
        
        viewControllers = [ideasNav, ideasPlusNav, photosNav]
    }
    
}
