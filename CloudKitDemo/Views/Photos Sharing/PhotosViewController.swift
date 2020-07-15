//
//  PhotosViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/7.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit
import CloudKit

class PhotosViewController: UIViewController {
    
    // MARK: - Property
    
    var album: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        navigationItem.rightBarButtonItem = shareButton
        
        setupViews()
        
        CloudKitOperation<Album>.query(type: CKConstant.RecordType.Albums) { albums in
            self.album = albums.first
        }
    }
    
    // MARK: - View
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.delegate = self
        collection.dataSource = self
        collection.registerCell(PhotoCollectionCell.self)
        return collection
    }()
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addConstraints(format: "H:|[v0]|", views: collectionView)
        view.addConstraints(format: "V:|[v0]|", views: collectionView)
    }
    
    // MARK: - Action
    
    @objc func handleShare() {
//        guard let sfAlbum = album else { return }
        let record = Album(name: "TTSY").convertToCKRecord()
        let share = CKShare(rootRecord: record)
        
        prepareToShare(share: share, record: record)
    }
    
    // MARK: - Method
    
    func prepareToShare(share: CKShare, record: CKRecord) {
        let sharingController = UICloudSharingController { (UICloudSharingController, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            let operation = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: nil)
            operation.modifyRecordsCompletionBlock = { record, recordID, error in
                handler(share, CKContainer.default(), error)
            }
            
            CloudKitManager.privateDB.add(operation)
        }
        
        sharingController.delegate = self
        sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
        
        navigationController?.present(sharingController, animated: true)
    }
    
}

extension PhotosViewController: UICloudSharingControllerDelegate {
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Saved successfully")
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Here error: \(error)")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return "TTSY"
    }
    
    func itemType(for csc: UICloudSharingController) -> String? {
        return "com.ttdp.CloudKit"
    }
    
}

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as PhotoCollectionCell
        cell.backgroundColor = .red
        return cell
    }
    
}

extension PhotosViewController: UICollectionViewDelegate {
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

class PhotoCollectionCell: UICollectionViewCell {
    
}
