//
//  CategoryEditorViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/2.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

protocol CategoryEditorViewDelegate {
    func editorView(didAdd category: Category)
    func editorView(didChange category: Category)
}

class CategoryEditorViewController: UIViewController {
    
    // MARK: - Property
    
    var category: Category?
    
    var delegate: CategoryEditorViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        navigationItem.rightBarButtonItem = saveButton
        
        categoryView.text = category?.name
        saveButton.isEnabled = !categoryView.text.isEmpty
        
        setupViews()
    }
    
    // MARK: - View
    
    let naviEdge: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let bottomEdge: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var categoryView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.font = UIFont.systemFont(ofSize: 17)
        
        textView.delegate = self
        return textView
    }()
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(naviEdge)
        view.addConstraints(format: "H:|[v0]|", views: naviEdge)
        view.addConstraints(format: "V:|-\(naviGap)-[v0(1)]", views: naviEdge)
        
        view.addSubview(bottomEdge)
        view.addConstraints(format: "H:|[v0]|", views: bottomEdge)
        view.addConstraints(format: "V:[v0(1)]-\(bottomGap)-|", views: bottomEdge)
        
        view.addSubview(categoryView)
        view.addConstraints(format: "H:|-15-[v0]-15-|", views: categoryView)
        view.addConstraints(format: "V:[v0(80)]", views: categoryView)
        categoryView.topAnchor.constraint(equalTo: naviEdge.bottomAnchor, constant: 15).isActive = true
    }
    
    // MARK: - Action
    
    @objc func handleSave() {
        guard let name = categoryView.text else {
            return
        }
        
        if let category = category {
            let _category = Category(uuid: category.uuid, createdAt: category.createdAt, updatedAt: Date(), name: name)
            delegate?.editorView(didChange: _category)
        } else {
            delegate?.editorView(didAdd: Category(name: name))
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}

extension CategoryEditorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.isEmpty
    }
    
}
