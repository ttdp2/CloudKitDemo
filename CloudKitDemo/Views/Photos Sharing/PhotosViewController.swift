//
//  PhotosViewController.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/7.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    // MARK: - Property
    
    var album: Album?
    var photos: [Photo] = []
    
    var sharedRoot: CKRecord?
    var isParticipant = false
    
    var share: CKShare?
    
    var viewModel: PhotosViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = PhotosViewModel()
        
        setupViews()
        
        viewModel.fetchPhotos {
            self.collectionView.reloadData()
        }
        
        CloudKitOperation<Album>.query(type: CKConstant.RecordType.Albums) { albums in
            self.album = albums.first
        }
        
        CloudKitOperation<Photo>.query(type: CKConstant.RecordType.Photos) { photos in
            if !photos.isEmpty {
                self.photos = photos
                self.collectionView.reloadData()
            }
        }
        
        CloudKitManager.privateDB.perform(CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true)), inZoneWith: CloudKitManager.photosZone.zoneID) { (records, error) in
            if let share = records?.first as? CKShare {
                self.share = share
                print(share)
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
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        navigationItem.rightBarButtonItems = [addButton, shareButton]
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
    
    @objc func handleShare() {
        let record = album!.convertToCKRecord()
        
        continueToShare(share: share!, record: record)
    }
    
    // MARK: - Method
    
    func setupAlbum() {
        if album == nil {
            let _album = Album(name: "Shared Album")
            let record = _album.convertToCKRecord()
            let share = CKShare(rootRecord: record)
            
            prepareToShare(share: share, record: record)
        } else {
            let record = album!.convertToCKRecord()
            let share = CKShare(rootRecord: record)
            
            continueToShare(share: share, record: record)
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
    
    func continueToShare(share: CKShare, record: CKRecord) {
        let sharingController = UICloudSharingController(share: share, container: CKContainer.default())
        sharingController.delegate = self
        sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
        
        navigationController?.present(sharingController, animated: true)
    }
    
    var zoneID: CKRecordZone.ID?
    var zoneRecordID: CKRecord.ID?
    
    func fetchSharedPhotos() {
        CloudKitManager.sharedDB.fetchAllRecordZones { zones, error in
            guard let sharedPhotoZone = zones?.first else { return }

            self.isParticipant = true
            
            let predicate = NSPredicate(value: true)
            let photoQuery = CKQuery(recordType: CKConstant.RecordType.Photos, predicate: predicate)
            
            CloudKitManager.sharedDB.perform(photoQuery, inZoneWith: sharedPhotoZone.zoneID) { records, error in
                if let photoRecords = records {
                    self.photos = photoRecords.map { Photo(record: $0)}
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                    self.zoneID = sharedPhotoZone.zoneID
                    self.zoneRecordID = records?.first?.recordID
                }
            }
            
            let albumQuery = CKQuery(recordType: CKConstant.RecordType.Albums, predicate: predicate)
            
            CloudKitManager.sharedDB.perform(albumQuery, inZoneWith: sharedPhotoZone.zoneID) { records, error in
                self.sharedRoot = records?.first
                print(error ?? "Done")
            }
        }
    }
    
    // Participant Zone: <CKRecordZoneID: 0x280b991c0; ownerName=_a9bdc43038d1f1d3fee0b5b9e5c6010e, zoneName=Photos Zone>
    // Owner Zone: <CKRecordZoneID: 0x2816a0e60; ownerName=__defaultOwner__, zoneName=Photos Zone>
    func saveSharedPhoto(_ photo: Photo) {
        if isParticipant {
            guard let zoneID = sharedRoot?.recordID.zoneID else {
                return
            }
            
            let recordID = CKRecord.ID(recordName: photo.uuid, zoneID: zoneID)
            let record = CKRecord(recordType: CKConstant.RecordType.Photos, recordID: recordID)
            let photoRecord = photo.mergeWithCKRecord(record)
            
            let shareOperation = CloudKitShareOperation(isOwner: false)
            shareOperation.save(record: photoRecord, parent: sharedRoot) { success in
                print(success)
            }
        } else {
            let photoRecord = photo.convertToCKRecord()
            let albumRecord = album?.convertToCKRecord()
            
            let shareOperation = CloudKitShareOperation(isOwner: true)
            shareOperation.save(record: photoRecord, parent: albumRecord) { success in
                print(success)
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
        let photo = Photo(data: imageData)
        photos.append(photo)
        collectionView.reloadData()
        
        saveSharedPhoto(photo)
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
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as PhotoCollectionCell
        
        let photo = viewModel.photos[indexPath.row]
        cell.photoView.image = UIImage(data: photo.data)
        
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
    
    var photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    func setupViews() {
        addSubview(photoView)
        addConstraints(format: "H:|[v0]|", views: photoView)
        addConstraints(format: "V:|[v0]|", views: photoView)
    }
    
}
