//
//  IdeasViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/18.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

class IdeasViewController: UIViewController {
    
    // MARK: - Property
    
    var ideas = [Idea(title: "Go to Apple WWDC in 2021"),
                 Idea(title: "Playing basketball in this weekend"),
                 Idea(title: "Write a blog about CloudKit")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = addButton
        
        setupViews()
        
        CloudKitManager.shared.query {}
    }
    
    // MARK: - View
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(IdeaTableViewCell.self)
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
        showEdit()
    }
    
    // MARK: - Method
    
    func showEdit(idea: String? = nil) {
        let editViewController = EditorViewController()
        editViewController.delegate = self
        editViewController.idea = idea
        
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
}

extension IdeasViewController: EditorViewDelegate {
    
    func editorView(didAddIdea text: String) {
        let idea = Idea(title: text)
        ideas.append(idea)
        tableView.reloadData()
        
        CloudKitManager.shared.save(idea: idea)
    }
    
    func editorView(didChangeIdea text: String, orignal: String) {
        guard let index = ideas.map({ $0.title }).firstIndex(of: orignal) else {
            return
        }
        
        ideas[index] = Idea(title: text)
        tableView.reloadData()
    }
    
}

extension IdeasViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as IdeaTableViewCell
        
        cell.textLabel?.text = ideas[indexPath.row].title
        cell.detailTextLabel?.text = "\(ideas[indexPath.row].updatedAt)"
        return cell
    }
    
}

extension IdeasViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idea = ideas[indexPath.row]
        showEdit(idea: idea.title)
    }
    
}

class IdeaTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.numberOfLines = 0
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
