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
    
    var ideas: [Idea] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = addButton
        
        setupViews()
        
        CloudKitOperation<Idea>.query(type: CKConstant.RecordType.Ideas) { ideas in
            self.ideas = ideas
            self.tableView.reloadData()
        }
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
    
    func showEdit(idea: Idea? = nil) {
        let editViewController = EditorViewController()
        editViewController.delegate = self
        editViewController.idea = idea
        
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
}

extension IdeasViewController: EditorViewDelegate {
    
    func editorView(didAdd idea: Idea) {
        ideas.append(idea)
        tableView.reloadData()
        
        CloudKitOperation.save(model: idea) { savedIdea in
            self.ideas[self.ideas.count - 1] = savedIdea
            self.tableView.reloadData()
        }
    }
    
    func editorView(didChange idea: Idea) {
        guard let index = ideas.map({ $0.uuid }).firstIndex(of: idea.uuid) else {
            return
        }
        
        ideas[index] = idea
        tableView.reloadData()
        
        CloudKitOperation.update(model: idea) { updatedIdea in
            self.ideas[index] = updatedIdea
            self.tableView.reloadData()
        }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let idea = ideas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            CloudKitOperation.delete(model: idea) { _ in }
        }
    }
    
}

extension IdeasViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idea = ideas[indexPath.row]
        showEdit(idea: idea)
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
