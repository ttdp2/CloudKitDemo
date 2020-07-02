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
    
    var categories: [Category] = [Category(name: "Work"), Category(name: "Travel"), Category(name: "Home"), Category(name: "Fitness")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
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
        }
    }
    
}

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryEditorVC = CategoryEditorViewController()
        navigationController?.pushViewController(categoryEditorVC, animated: true)
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
