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
    var queuedUploads:NSMutableDictionary = NSMutableDictionary(capacity: 0);
    
    public func isAssetQueued(_ asset:PHAsset) ->Bool {
        return false;
    }
    
    public func queueAsset(_ asset:PHAsset) {
        
    }
    
    public func removeAsset(_ asset:PHAsset) {
    
    }
}
