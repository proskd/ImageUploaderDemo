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
    
    private static var defaultImageUploader:PhotoImageUploader?;
    
    private var urlSession:URLSession?;
    
    //enforce singleton for this class
    open class func `default`() -> PhotoImageUploader {
        if defaultImageUploader == nil {
            defaultImageUploader = PhotoImageUploader()
        }
        
        return defaultImageUploader!;
    }
    
    private init() {
        
        
        
        
    }
    
    public func enqueueAsset(_ asset:PHAsset) {
        
    }
    
    public func cancelUpload(_ asset:PHAsset) {
        
    }    
}
