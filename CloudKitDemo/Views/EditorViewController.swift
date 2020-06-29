//
//  EditorViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/18.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit
import CloudKit

protocol EditorViewDelegate {
    func editorView(didAddIdea text: String)
    func editorView(didChangeIdea text: String, orignal: String)
}

class EditorViewController: UIViewController {
    
    var idea: String?
    
    var delegate: EditorViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        navigationItem.rightBarButtonItem = saveButton
        
        ideaView.text = idea
        saveButton.isEnabled = !ideaView.text.isEmpty
        
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
    
    lazy var ideaView: UITextView = {
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
        
        view.addSubview(ideaView)
        view.addConstraints(format: "H:|-15-[v0]-15-|", views: ideaView)
        view.addConstraints(format: "V:[v0(80)]", views: ideaView)
        ideaView.topAnchor.constraint(equalTo: naviEdge.bottomAnchor, constant: 15).isActive = true
    }
    
    // MARK: - Action
    
    @objc func handleSave() {
        guard let text = ideaView.text else {
            return
        }
        
        if let idea = idea {
            delegate?.editorView(didChangeIdea: text, orignal: idea)
        } else {
            delegate?.editorView(didAddIdea: text)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}

extension EditorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.isEmpty
    }
    
}
