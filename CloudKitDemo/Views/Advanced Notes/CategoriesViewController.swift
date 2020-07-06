//
//  CategoriesViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/2.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    // MARK: - Property
    
    var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        let batchButton = UIBarButtonItem(title: "Batch", style: .plain, target: self, action: #selector(handleBatch))
        
        navigationItem.rightBarButtonItems = [addButton, batchButton]

        setupViews()
        
        CloudKitOperation<Category>.query(type: CKConstant.RecordType.Categories) { categories in
            self.categories = categories
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(CategoryTableViewCell.self)
        return tableView
    }()
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addConstraints(format: "H:|[v0]|", views: tableView)
        view.addConstraints(format: "V:|[v0]|", views: tableView)
    }
    
    // MARK: - Action
       
    @objc func handleAdd() {
        showEditor()
    }
    
    @objc func handleBatch() {
        let categories = [Category(name: "Swift 1"),
                          Category(name: "Swift 2"),
                          Category(name: "Swift 3"),
                          Category(name: "Swift 4"),
                          Category(name: "Swift 5")]
        CloudKitOperation.batch(modelsToSave: categories, modelsToDelete: []) { (savedCategories, ids) in
            self.categories += savedCategories
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Method
    
    func showEditor(category: Category? = nil) {
        let editViewController = CategoryEditorViewController()
        editViewController.delegate = self
        editViewController.category = category
        
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
}

extension CategoriesViewController: CategoryEditorViewDelegate {
    
    func editorView(didAdd category: Category) {
        categories.append(category)
        tableView.reloadData()
        
        CloudKitOperation.save(model: category) { savedCategory in
            self.categories[self.categories.count - 1] = savedCategory
            self.tableView.reloadData()
        }
    }
    
    func editorView(didChange category: Category) {
        guard let index = categories.map({ $0.uuid }).firstIndex(of: category.uuid) else {
            return
        }
        
        categories[index] = category
        tableView.reloadData()
        
        CloudKitOperation.update(model: category) { updatedCategory in
            self.categories[index] = updatedCategory
            self.tableView.reloadData()
        }
    }
    
}

extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CategoryTableViewCell
        
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            CloudKitOperation.delete(model: category) { _ in }
        }
    }
    
}

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        showEditor(category: category)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let category = categories[indexPath.row]
        showEditor(category: category)
    }
    
}

class CategoryTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.textAlignment = .center
        self.selectionStyle = .none
        self.accessoryType = .detailButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
