//
//  PhotosDataProvider.swift
//  ImageUploader
//
//  Created by David Proskin on 8/3/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import Photos

protocol PhotosDataProviderDelegate {
    func authStatusChanged(status:PHAuthorizationStatus);
}

class PhotosDataProvider {
    
    public var delegate:PhotosDataProviderDelegate?;
    public var authStatus = PHAuthorizationStatus.notDetermined;
    public var sortAscending = true;
    var photoAssets = [PHAsset]();
    
    public func verifyPermission() {
        self.authStatus = PHPhotoLibrary.authorizationStatus();
        if self.authStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                self.authStatus = status;
                self.delegate?.authStatusChanged(status: status);
            }
        }
    }
    
    public func fetchPhotos() {
        
        self.verifyPermission()
        
        if self.authStatus != .authorized {
            return
        }
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: self.sortAscending)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options);
        
        fetchResult.enumerateObjects { (asset, index, obj) in
            self.photoAssets.append(asset);
        };
    }
    
    public func countOfPhotos() -> Int {
        return self.photoAssets.count;
    }
    
    public func photoAt(_ index:Int) -> PHAsset? {
        return self.photoAssets[index];
    }
    
}
