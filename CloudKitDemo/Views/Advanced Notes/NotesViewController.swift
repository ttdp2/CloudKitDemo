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
    
    var notes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let categoriesButton = UIBarButtonItem(title: "Categories", style: .plain, target: self, action: #selector(handleCategories))
        navigationItem.leftBarButtonItem = categoriesButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = addButton

        setupViews()
        
        CloudKitOperation<Note>.query(type: CKConstant.RecordType.Notes) { notes in
            self.notes = notes
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
    
}

extension NotesViewController: NoteEditorViewDelegate {
    
    func editorView(didAdd note: Note) {
        notes.append(note)
        tableView.reloadData()
        
        CloudKitOperation.save(model: note) { savedIdea in
            self.notes[self.notes.count - 1] = savedIdea
            self.tableView.reloadData()
        }
    }
    
    func editorView(didChange note: Note) {
        guard let index = notes.map({ $0.uuid }).firstIndex(of: note.uuid) else {
            return
        }
        
        notes[index] = note
        tableView.reloadData()
        
        CloudKitOperation.update(model: note) { updatedNote in
            self.notes[index] = updatedNote
            self.tableView.reloadData()
        }
    }
    
}

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as IdeaTableViewCell
        
        cell.textLabel?.text = notes[indexPath.row].text
        cell.detailTextLabel?.text = "\(notes[indexPath.row].updatedAt)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let idea = notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            CloudKitOperation.delete(model: idea) { _ in }
        }
    }
    
}

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        showEditor(note: note)
    }
    
}
