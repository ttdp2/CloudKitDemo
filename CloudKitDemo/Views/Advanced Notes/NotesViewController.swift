//
//  NotesViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/1.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

// Advanced Features including: Asset, Reference, Batch Operation, Subscription

class NotesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let categoriesButton = UIBarButtonItem(title: "Categories", style: .plain, target: self, action: #selector(handleCategories))
        navigationItem.leftBarButtonItem = categoriesButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = addButton

        setupViews()
    }
    
    // MARK: - View
    
    func setupViews() {
        view.backgroundColor = .white
    }
    
    // MARK: - Action
    
    @objc func handleCategories() {
        let categoriesVC = CategoriesViewController()
        navigationController?.pushViewController(categoriesVC, animated: true)
    }

    @objc func handleAdd() {
        let noteEditorVC = NoteEditorViewController()
        navigationController?.pushViewController(noteEditorVC, animated: true)
        
        let note = Note(text: "This is a test note")
        print(note)
        CloudKitOperation.save(model: note) { record in
            print(record)
        }
    }
    
}
