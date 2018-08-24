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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = self.photosDataProvider.photoAt(indexPath.row) else {
            return;
        }
        
        if (PhotoImageUploader.default().isAssetQueued(asset)) {
            PhotoImageUploader.default().cancelUpload(asset);
        } else {
            PhotoImageUploader.default().enqueueAsset(asset);
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func configureCell(_ cell:PhotoCollectionViewCell,  withAsset asset: PHAsset) {
        cell.label!.text = asset.localIdentifier
        
        //cancel any in-flight requests for this cell, if any.
        if cell.imageRequest != PHInvalidImageRequestID {
            PhotoImageLoader.default().cancelImageRequest(for: cell.imageRequest)
            cell.imageRequest = PHInvalidImageRequestID
        }
        
        cell.imageRequest = PhotoImageLoader.default().loadThumbnail(for: asset) { (image, info) in
            cell.imageRequest = PHInvalidImageRequestID;
            cell.imageView.image = image
        }
        
        if PhotoImageUploader.default().isAssetQueued(asset) {
            cell.activityIndicator.isHidden = false;
            cell.activityIndicator.startAnimating();
        } else {
            cell.activityIndicator.isHidden = true;
            cell.activityIndicator.stopAnimating();
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
