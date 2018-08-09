//
//  PhotoImageUploader.swift
//  ImageUploader
//
//  Created by David Proskin on 8/4/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import Photos


class PhotoImageUploader {
    
    public static let PhotoUploadedNotification = "PhotoUploadedNotification";
    
    private static let MAX_CONCURRENT_UPLOADS = 1;
    
    private static var defaultImageUploader:PhotoImageUploader?;
   
    private var uploadQueue:PhotoUploadQueue;
    private var numUploadsInProgress:Int;
    
    //enforce singleton for this class
    open class func `default`() -> PhotoImageUploader {
        if defaultImageUploader == nil {
            defaultImageUploader = PhotoImageUploader()
        }
        
        return defaultImageUploader!;
    }
    
    private init() {
        uploadQueue = PhotoUploadQueue();
        numUploadsInProgress = 0;
    }
    
    public func enqueueAsset(_ asset:PHAsset) {
        uploadQueue.enqueueAsset(asset);
        uploadNextInQueue();
    }
    
    public func cancelUpload(_ asset:PHAsset) {
        if (uploadQueue.isAssetQueued(asset.localIdentifier)) {
            uploadQueue.removeAsset(asset.localIdentifier)
        }
    }
    
    public func isAssetQueued(_ asset:PHAsset) -> Bool {
        return uploadQueue.isAssetQueued(asset.localIdentifier)
    }
    
    private func uploadNextInQueue() {
        if (self.numUploadsInProgress < PhotoImageUploader.MAX_CONCURRENT_UPLOADS && !uploadQueue.isEmpty()) {
            
            //begin uploading the photo with a completion handler
            
            //when photo is done, remove it from the queue and post a notification that it was completed.
        }
    }
}
