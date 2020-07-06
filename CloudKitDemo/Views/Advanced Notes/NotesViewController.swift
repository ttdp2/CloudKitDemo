//
//  NotesViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/1.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

// Advanced Features including: Reference, Batch Operation, Subscription

class NotesViewController: UIViewController {
    
    // MARK: - Property
    
    var notes: [Note] = [] {
        didSet {
            combineNoteWithCategory()
        }
    }
    
    var categories: [Category] = [] {
        didSet {
            combineNoteWithCategory()
        }
    }
    
    var combinedCategories: [Category] = []
    
    var isCategoriesFetched = false
    var isNotesFetched = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let categoriesButton = UIBarButtonItem(title: "Categories", style: .plain, target: self, action: #selector(handleCategories))
        navigationItem.leftBarButtonItem = categoriesButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = addButton

        setupViews()
        
        CloudKitOperation<Note>.query(type: CKConstant.RecordType.Notes) { notes in
            self.isNotesFetched = true
            self.notes = notes
            self.tableView.reloadData()
        }
        
        CloudKitOperation<Category>.query(type: CKConstant.RecordType.Categories) { categories in
            self.isCategoriesFetched = true
            self.categories = categories
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(NoteTableViewCell.self)
        return tableView
    }()
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addConstraints(format: "H:|[v0]|", views: tableView)
        view.addConstraints(format: "V:|[v0]|", views: tableView)
    }
    
    // MARK: - Action
    
    @objc func handleCategories() {
        let categoriesVC = CategoriesViewController()
        navigationController?.pushViewController(categoriesVC, animated: true)
    }

    @objc func handleAdd() {
        showEditor()
    }
    
    // MARK: - Method
    
    func showEditor(note: Note? = nil) {
        let editViewController = NoteEditorViewController()
        editViewController.delegate = self
        editViewController.note = note
        
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    func combineNoteWithCategory() {
        guard isNotesFetched && isCategoriesFetched else { return }
        
        combinedCategories.removeAll()
        
        for var category in categories {
            category.notes = notes.filter { $0.categoryId == category.uuid }
            combinedCategories.append(category)
        }
        
        let noCategoryNotes = notes.filter { $0.categoryId == nil }
        var category = Category(name: "No Categories")
        category.notes = noCategoryNotes
        
        combinedCategories.append(category)
    }
    
}

extension NotesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return combinedCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return combinedCategories[section].notes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NoteTableViewCell
        let category = combinedCategories[indexPath.section]
        let note = category.notes?[indexPath.row]
        cell.textLabel?.text = note?.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = combinedCategories[indexPath.section]
            
            guard let note = category.notes?[indexPath.row] else { return }
            guard let index = notes.map({ $0.uuid }).firstIndex(of: note.uuid) else {
                return
            }
            
            notes.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            CloudKitOperation.delete(model: note) { _ in }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return combinedCategories[section].name
    }
    
}

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = combinedCategories[indexPath.section]
        let note = category.notes?[indexPath.row]
        showEditor(note: note)
    }
    
}

extension NotesViewController: NoteEditorViewDelegate {
    
    func editorView(didAdd note: Note) {
        notes.append(note)
        tableView.reloadData()
        
        CloudKitOperation.save(model: note) { _ in }
    }
    
    func editorView(didChange note: Note) {
        guard let index = notes.map({ $0.uuid }).firstIndex(of: note.uuid) else {
            return
        }
        
        notes[index] = note
        tableView.reloadData()
        
        CloudKitOperation.update(model: note) { _ in }
    }
    
}

class NoteTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.numberOfLines = 0
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
