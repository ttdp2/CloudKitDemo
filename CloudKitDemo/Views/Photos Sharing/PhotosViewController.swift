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
    
    var viewModel: PhotosViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = PhotosViewModel()
        viewModel.delegate = self
        
        setupViews()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        navigationItem.rightBarButtonItems = [addButton, shareButton]
        
        viewModel.fetchPhotos {
            self.collectionView.reloadData()
            
            if self.viewModel.isOwner {
                self.navigationItem.rightBarButtonItems = [addButton, shareButton]
            } else {
                self.navigationItem.rightBarButtonItems = [addButton]
            }
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
    
    @objc func handleAdd() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
    @objc func handleShare() {
        viewModel.addShare()
    }

}

extension PhotosViewController: PhotosViewModelDelegate {
    
    func showSharingController(_ controller: UICloudSharingController) {
        controller.delegate = self
        navigationController?.present(controller, animated: true)
    }
    
}

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 0.3)!
        let photo = Photo(data: imageData)
        
        viewModel.addPhoto(photo)
        collectionView.reloadData()
    }
    
}

extension PhotosViewController: UICloudSharingControllerDelegate {
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Sharing save successfully")
        viewModel.fetchShare()
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("Sharing stop successfully")
        viewModel.stopShare()
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Sharing save error: \(error)")
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
