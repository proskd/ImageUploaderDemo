//
//  PhotosCollectionViewController.swift
//  ImageUploader
//
//  Created by David Proskin on 8/4/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import UIKit
import Photos


class PhotosCollectionViewController: UICollectionViewController, PhotosDataProviderDelegate {
    
    var photosDataProvider = PhotosDataProvider()
    
    override func viewDidLoad() {
        
        self.photosDataProvider.fetchPhotos()
        
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosDataProvider.countOfPhotos()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell

        guard let asset = self.photosDataProvider.photoAt(indexPath.row) else {
            return cell;
        }
        configureCell(cell, withAsset: asset)
        return cell;
    }
    
    func configureCell(_ cell:PhotoCollectionViewCell,  withAsset asset: PHAsset) {
        cell.label!.text = asset.localIdentifier
        
        let options:PHImageRequestOptions = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { (image, info) in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        
    }
    
    // MARK: - Photos Delegate
    
    func authStatusChanged(status: PHAuthorizationStatus) {
        self.photosDataProvider.fetchPhotos()
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
}
