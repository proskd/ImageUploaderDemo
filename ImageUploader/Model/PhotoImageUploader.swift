//
//  PhotoImageUploader.swift
//  ImageUploader
//
//  Created by David Proskin on 8/4/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import Photos


class PhotoImageUploader: NSObject, URLSessionDelegate {
    
    public static let IMGUR_UPLOAD_URL = "https://api.imgur.com/3/image";
    public static let IMAGE_BOUNDARY = "WebKitFormBoundary7MA4YWxkTrZu0gW"
    public static let PhotoUploadedNotification = "PhotoUploadedNotification";
    
    private static let MAX_CONCURRENT_UPLOADS = 1;
    
    private static var defaultImageUploader:PhotoImageUploader?;
   
    private var uploadQueue:PhotoUploadQueue;
    private var numUploadsInProgress:Int;
    private var urlSession:URLSession?;
    
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
        super.init()
        
        let config = URLSessionConfiguration.default;
        
        self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil);
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
            
            let url = URL(string: PhotoImageUploader.IMGUR_UPLOAD_URL);
            var request:URLRequest = URLRequest(url: url!);
            
            let authHeader = String(format: "Client-ID %@", "ed3f0b82e522861");
            
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            request.setValue("multipart/form-data; boundary=----" + PhotoImageUploader.IMAGE_BOUNDARY,
                              forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST";
            
            var bodyData:Data?
            
            PhotoImageLoader.default().loadImageData(for: (anAsset?.asset)!) { (data:Data?, dataUTI:String?, orientation:UIImageOrientation, info:[AnyHashable : Any]?) in
                if ((data) != nil) {
                    
                    bodyData = self.photoDataToFormData(imageData: data, boundary: PhotoImageUploader.IMAGE_BOUNDARY, fileName: "TestFileName") as Data
                    
                    let uploadTask = self.urlSession?.uploadTask(with: request, from: bodyData, completionHandler: { (data, response, error) in
                        if (response != nil) {
                            NSLog(String(format:"got a response! %@", response!))
                            
                        }
                        
                        if let anError = error {
//                            self.handleClientError(error)
                            self.numUploadsInProgress-=1
                            self.uploadNextInQueue()
                            return
                        }
                        guard let httpResponse = response as? HTTPURLResponse,
                            (200...299).contains(httpResponse.statusCode) else {
//                                self.handleServerError(response)
                                let string = String(data: data!, encoding: .utf8)
                                
                                NSLog(String(format:"Error Response: %@", string!));

                                self.numUploadsInProgress-=1
                                self.uploadNextInQueue()
                                return
                        }
                        let string = String(data: data!, encoding: .utf8)
                        
                        NSLog(String(format:"Successful Response: %@", string!));
                        
                        
                        self.uploadQueue.removeAsset((anAsset?.asset?.localIdentifier)!)
                        self.numUploadsInProgress-=1
                        self.uploadNextInQueue()
                    });
                    
                    uploadTask?.resume()
                }
            }
            
            //begin uploading the photo with a completion handler
            
            //when photo is done, remove it from the queue and post a notification that it was completed.
        }
    }
    
    func photoDataToFormData(imageData:Data?,boundary:String,fileName:String) -> NSData {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "------" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"image\"\r\n\r\n"
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
//        // 3
//        let lineThree = "Content-Type: image/jpg\r\n\r\n"
//        fullData.append(lineThree.data(
//            using: String.Encoding.utf8,
//            allowLossyConversion: false)!)
//        
//        
        // 4
        fullData.append(imageData!)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(using: String.Encoding.utf8)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "------" + boundary + "--\r\n"
        fullData.append(lineSix.data(using: String.Encoding.utf8)!)
        
        return fullData
    }
}
