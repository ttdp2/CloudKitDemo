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

class NoteEditorViewController: UIViewController, UINavigationControllerDelegate {
    
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
    
    var noteImage: Data?
    
    var delegate: NoteEditorViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        navigationItem.rightBarButtonItem = saveButton
        
        noteView.text = note?.text
        noteImage = note?.image
        
        saveButton.isEnabled = !noteView.text.isEmpty
        
        setupViews()
        
        CloudKitOperation<Category>.query(type: CKConstant.RecordType.Categories) { categories in
            self.categories = categories
            self.tableView.reloadSections([0], with: .fade)
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
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(NoteCategoryTableViewCell.self)
        tableView.registerCell(NoteImageTableViewCell.self)
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
        
        view.addSubview(tableView)
        view.addConstraints(format: "H:|[v0]|", views: tableView)
        tableView.topAnchor.constraint(equalTo: noteView.bottomAnchor, constant: 15).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomEdge.topAnchor, constant: 15).isActive = true
    }
    
    // MARK: - Action
    
    @objc func handleSave() {
        guard let text = noteView.text else {
            return
        }
        
        if let note = note {
            var editedNote = Note(uuid: note.uuid, createdAt: note.createdAt, updatedAt: Date(), text: text)
            editedNote.categoryId = category?.uuid
            editedNote.image = noteImage
            delegate?.editorView(didChange: editedNote)
        } else {
            var newNote = Note(text: text)
            newNote.categoryId = category?.uuid
            newNote.image = noteImage
            delegate?.editorView(didAdd: newNote)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Method
    
    func pickImage() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
}

extension NoteEditorViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        noteImage = image.jpegData(compressionQuality: 0.3)
        tableView.reloadData()
    }
    
}

extension NoteEditorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = !noteView.text.isEmpty
    }
    
}

extension NoteEditorViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categories.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NoteCategoryTableViewCell
            cell.textLabel?.text = categories[indexPath.row].name
            if categories[indexPath.row].uuid == category?.uuid {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NoteImageTableViewCell
            cell.controller = self
            if let imageData = noteImage {
                cell.noteImageView.image = UIImage(data: imageData)
            } else {
                cell.noteImageView.image = nil
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Category"
        } else {
            return "Image"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        if editingStyle == .delete {
            noteImage = nil
            tableView.reloadData()
        }
    }
    
}

extension NoteEditorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selected = categories[indexPath.row]
            category = selected.uuid == category?.uuid ? nil : selected
            tableView.reloadData()
        } else {
            pickImage()
        }
    }
    
}

class NoteCategoryTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
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

class NoteImageTableViewCell: UITableViewCell {
    
    weak var controller: NoteEditorViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let noteImageContainerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    let noteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func setupViews() {
        addSubview(noteImageContainerView)
        addConstraints(format: "H:|-15-[v0]-15-|", views: noteImageContainerView)
        addConstraints(format: "V:|-15-[v0(120)]-15-|", views: noteImageContainerView)
        
        noteImageContainerView.addSubview(addButton)
        noteImageContainerView.addConstraints(format: "H:|[v0]|", views: addButton)
        noteImageContainerView.addConstraints(format: "V:|[v0]|", views: addButton)
        
        addSubview(noteImageView)
        addConstraints(format: "H:|-15-[v0]-15-|", views: noteImageView)
        addConstraints(format: "V:|-15-[v0(120)]-15-|", views: noteImageView)
    }
    
    // MARK: - Action
    
    @objc func handleAdd(){
        controller?.pickImage()
    }
    
}
