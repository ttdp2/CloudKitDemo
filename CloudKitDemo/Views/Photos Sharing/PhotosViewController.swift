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
    var photos: [Photo] = []
    
    var isParticipant = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = addButton
        
        setupViews()
        
        CloudKitOperation<Album>.query(type: CKConstant.RecordType.Albums) { albums in
            self.album = albums.first
        }
        
        CloudKitOperation<Photo>.query(type: CKConstant.RecordType.Photos) { photos in
            if !photos.isEmpty {
                self.photos = photos
                self.collectionView.reloadData()
            }
        }
        
        fetchSharedPhotos()
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
    
    @objc func handleAdd() {
        if isParticipant || album != nil {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            present(imagePickerVC, animated: true)
        } else {
            setupAlbum()
        }
    }
    
    // MARK: - Method
    
    func setupAlbum() {
        if album == nil {
            let _album = Album(name: "Shared Album")
            let record = _album.convertToCKRecord()
            let share = CKShare(rootRecord: record)
            
            prepareToShare(share: share, record: record)
        }
    }
    
    func prepareToShare(share: CKShare, record: CKRecord) {
        let sharingController = UICloudSharingController { (UICloudSharingController, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            let operation = CKModifyRecordsOperation(recordsToSave: [share, record], recordIDsToDelete: nil)
            operation.modifyRecordsCompletionBlock = { _, _, error in
                if let error = error {
                    print("Modify error: \(error)")
                } else {
                    print("Modified successfully")
                    self.album = Album(record: record)
                }
                handler(share, CKContainer.default(), error)
            }
            
            CloudKitManager.privateDB.add(operation)
        }
        
        sharingController.delegate = self
        sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
        
        navigationController?.present(sharingController, animated: true)
    }
    
    func fetchSharedPhotos() {
        CloudKitManager.sharedDB.fetchAllRecordZones { zones, error in
            guard let photoZone = zones?.first else { return }

            self.isParticipant = true
            let query = CKQuery(recordType: CKConstant.RecordType.Photos, predicate: NSPredicate(value: true))
            
            CloudKitManager.sharedDB.perform(query, inZoneWith: photoZone.zoneID) { records, error in
                if let photoRecords = records {
                    self.photos = photoRecords.map { Photo(record: $0)}
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

}

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 0.3)!
        var photo = Photo(data: imageData)
        photos.append(photo)
        collectionView.reloadData()
        
        // When converting to CKRecord, album will be set as parent record
        photo.album = album
        
        CloudKitOperation.save(model: photo) { _ in }
    }
    
}

extension PhotosViewController: UICloudSharingControllerDelegate {
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Saved successfully")
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Save error: \(error)")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return "Shared Album"
    }

}

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as PhotoCollectionCell
        cell.imageView.image = UIImage(data: photos[indexPath.row].data)
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
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    func setupViews() {
        addSubview(imageView)
        addConstraints(format: "H:|[v0]|", views: imageView)
        addConstraints(format: "V:|[v0]|", views: imageView)
    }
    
}
