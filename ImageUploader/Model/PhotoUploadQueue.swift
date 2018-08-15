//
//  PhotoUploadQueue.swift
//  ImageUploader
//
//  Created by David Proskin on 8/4/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import Photos


class PhotoUploadQueue {
    var orderedUploads:[PhotoUpload];
    
    init() {
        orderedUploads = [];
    }
    
    public func isEmpty() -> Bool {
        return orderedUploads.count == 0;
    }
    
    public func count() -> Int {
        return orderedUploads.count;
    }
    
    public func isAssetQueued(_ assetIdentifier:String) -> Bool {
        if (self.orderedUploads.isEmpty) {
            return false;
        }
        
        var targetIndex = -1;
        for i in 0 ... self.orderedUploads.count - 1 {
            let anUpload = self.orderedUploads[i];
            if anUpload.asset?.localIdentifier == assetIdentifier {
                targetIndex = i;
                break;
            }
        }
        
        return targetIndex != -1;
    }
    
    public func enqueueAsset(_ asset:PHAsset) {
        let assetIdentifier = asset.localIdentifier;
        if (isAssetQueued(assetIdentifier)) {
            return;
        }
        
        let photoUpload = PhotoUpload(asset: asset)
        self.orderedUploads.append(photoUpload);
    }
    
    public func removeAsset(_ assetIdentifier:String) {
        var targetIndex = -1;
        for i in 0 ... self.orderedUploads.count {
            let anUpload = self.orderedUploads[i];
            if anUpload.asset?.localIdentifier == assetIdentifier {
                targetIndex = i;
                break;
            }
        }
        
        if targetIndex != -1 {
            self.orderedUploads.remove(at: targetIndex);
        }
    }
    
    public func dequeAsset() -> PhotoUpload? {
        if (isEmpty()) {
            return nil;
        }
        
        return self.orderedUploads[0];
    }
}
