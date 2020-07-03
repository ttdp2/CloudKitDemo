//
//  NoteEditorViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/2.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

protocol NoteEditorViewDelegate {
    func editorView(didAdd note: Note)
    func editorView(didChange note: Note)
}

class NoteEditorViewController: UIViewController {
    
    // MARK: - Property
    
    var note: Note?
    var category: Category?
    var categories: [Category] = [] {
        didSet {
            categories.forEach { _category in
                if _category.uuid == note?.categoryId {
                    category = _category
                }
            }
        }
    }
    
    var delegate: NoteEditorViewDelegate?
    
    var isSaveEnable: Bool {
        return !noteView.text.isEmpty && category != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        navigationItem.rightBarButtonItem = saveButton
        
        noteView.text = note?.text
        saveButton.isEnabled = !noteView.text.isEmpty && category != nil
        
        setupViews()
        
        CloudKitOperation<Category>.query(type: CKConstant.RecordType.Categories) { categories in
            self.categories = categories
            self.categoryTable.reloadData()
        }
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
    
    lazy var noteView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.font = UIFont.systemFont(ofSize: 17)
        
        textView.delegate = self
        return textView
    }()
    
    lazy var categoryTable: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(NoteCategoryTableViewCell.self)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(naviEdge)
        view.addConstraints(format: "H:|[v0]|", views: naviEdge)
        view.addConstraints(format: "V:|-\(naviGap)-[v0(1)]", views: naviEdge)
        
        view.addSubview(bottomEdge)
        view.addConstraints(format: "H:|[v0]|", views: bottomEdge)
        view.addConstraints(format: "V:[v0(1)]-\(bottomGap)-|", views: bottomEdge)
        
        view.addSubview(noteView)
        view.addConstraints(format: "H:|-15-[v0]-15-|", views: noteView)
        view.addConstraints(format: "V:[v0(80)]", views: noteView)
        noteView.topAnchor.constraint(equalTo: naviEdge.bottomAnchor, constant: 15).isActive = true
        
        view.addSubview(categoryTable)
        view.addConstraints(format: "H:|[v0]|", views: categoryTable)
        categoryTable.topAnchor.constraint(equalTo: noteView.bottomAnchor, constant: 15).isActive = true
        categoryTable.bottomAnchor.constraint(equalTo: bottomEdge.topAnchor, constant: 15).isActive = true
    }
    
    // MARK: - Action
    
    @objc func handleSave() {
        guard let text = noteView.text else {
            return
        }
        
        if let note = note {
            var _note = Note(uuid: note.uuid, createdAt: note.createdAt, updatedAt: Date(), text: text)
            _note.categoryId = category?.uuid
            delegate?.editorView(didChange: _note)
        } else {
            var note = Note(text: text)
            note.categoryId = category?.uuid
            delegate?.editorView(didAdd: note)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}

extension NoteEditorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = isSaveEnable
    }
    
}

extension NoteEditorViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NoteCategoryTableViewCell
        cell.textLabel?.text = categories[indexPath.row].name
        if categories[indexPath.row].uuid == category?.uuid {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a category"
    }
    
}

extension NoteEditorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        category = categories[indexPath.row]
        categoryTable.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = isSaveEnable
    }
    
}

class NoteCategoryTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.accessoryType = .checkmark
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let bottomLine = UIView()
        bottomLine.backgroundColor = .lightGray
        
        addSubview(bottomLine)
        addConstraints(format: "H:|-15-[v0]-15-|", views: bottomLine)
        addConstraints(format: "V:[v0(0.5)]|", views: bottomLine)
    }
    
}
