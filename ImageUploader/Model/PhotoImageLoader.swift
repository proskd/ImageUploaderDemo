//
//  PhotoImageLoader.swift
//  ImageUploader
//
//  Created by David Proskin on 8/4/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import Photos
import UIKit

class PhotoImageLoader {
    
    private static var defaultImageLoader:PhotoImageLoader?;
    
    //enforce singleton for Dthis class
    open class func `default`() -> PhotoImageLoader {
        if defaultImageLoader == nil {
            defaultImageLoader = PhotoImageLoader()
        }
        
        return defaultImageLoader!;
    }
    
    private init() {
    }
    
    private let defaultThumbnailSize = CGSize(width: 200, height: 200);
    
    public func cancelImageRequest(for identifier:PHImageRequestID) {
        PHImageManager.default().cancelImageRequest(identifier);
    }
    
    public func loadThumbnail(for asset:PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID
    {
    
        let options:PHImageRequestOptions = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
    
        return PHImageManager.default().requestImage(for: asset, targetSize: defaultThumbnailSize, contentMode: .aspectFill, options: options, resultHandler: resultHandler);
    }
}
