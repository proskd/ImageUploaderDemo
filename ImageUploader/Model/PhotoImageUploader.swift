//
//  PhotoImageUploader.swift
//  ImageUploader
//
//  Created by David Proskin on 8/4/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import Photos


class PhotoImageUploader: NSObject, NetworkResourceDelegate {
    
    public static let PhotoUploadedNotification = "PhotoUploadedNotification";
    
    private static let MAX_CONCURRENT_UPLOADS = 1;
    
    private static var defaultImageUploader:PhotoImageUploader?;
   
    private var uploadQueue:PhotoUploadQueue;
    private var numUploadsInProgress:Int;
    private var imgurNetworkResource:ImgurNetworkResource;
    
    //enforce singleton for this class
    open class func `default`() -> PhotoImageUploader {
        if defaultImageUploader == nil {
            defaultImageUploader = PhotoImageUploader()
        }
        
        return defaultImageUploader!;
    }
    
    private override init() {
        self.uploadQueue = PhotoUploadQueue();
        self.numUploadsInProgress = 0;
        self.imgurNetworkResource = ImgurNetworkResource()
        super.init()
        
        self.imgurNetworkResource.delegate = self;
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
            self.numUploadsInProgress+=1;
            
            let anAsset = uploadQueue.dequeAsset();
            
            PhotoImageLoader.default().loadImageData(for: (anAsset?.asset)!) { (data:Data?, dataUTI:String?, orientation:UIImageOrientation, info:[AnyHashable : Any]?) in
                if ((data) != nil) {
                    self.imgurNetworkResource.uploadImageData(data, completionHandler: { (success, responseData, error) in
                        if success {
                           //parse response and handle result
                            let string = String(data: responseData!, encoding: .utf8)
                            
                            NSLog(String(format:"Successful Response: %@", string!));
                        } else {
                            //handle error
                        }
                        
                        //regardless of success or failure, continue on with the queue if needed
                        self.uploadQueue.removeAsset((anAsset?.asset?.localIdentifier)!)
                        self.numUploadsInProgress-=1
                        self.uploadNextInQueue()
                    })
                }
            }
            
            //when photo is done, remove it from the queue and post a notification that it was completed.
        }
    }
    
    //MARK: NetworkResourceDelegate
    
    func uploadProgress(_ progress: Double) {
        let log = String(format: "Uplaod progress %f", progress);
        
        NSLog(log);
    }
}
