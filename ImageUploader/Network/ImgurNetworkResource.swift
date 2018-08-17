//
//  ImgurNetworkResource.swift
//  ImageUploader
//
//  Created by David Proskin on 8/16/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation

class ImgurNetworkResource : NSObject, NetworkResource, URLSessionTaskDelegate {
    
    public static let IMGUR_UPLOAD_URL = "https://api.imgur.com/3/image";
    public static let IMAGE_BOUNDARY = "WebKitFormBoundary7MA4YWxkTrZu0gW"
    
    public static let IMGUR_CLIENT_ID = "ed3f0b82e522861";
    var urlSession:URLSession?
    
    public var delegate:NetworkResourceDelegate?;
    
    public override init() {
        super.init()
        let config = URLSessionConfiguration.default;
        
        self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil);
    }

    
    public func uploadImageData(_ data:Data?, completionHandler: @escaping UploadCompletionHandler)
    {
        let url = URL(string: ImgurNetworkResource.IMGUR_UPLOAD_URL);
        var request:URLRequest = URLRequest(url: url!);
        
        let authHeader = String(format: "Client-ID %@", ImgurNetworkResource.IMGUR_CLIENT_ID);
        
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=----" + ImgurNetworkResource.IMAGE_BOUNDARY,
                         forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST";
        
        let bodyData:Data? = self.constructFormData(imageData: data, boundary: ImgurNetworkResource.IMAGE_BOUNDARY, fileName: "TestFileName") as Data
        
        let uploadTask = self.urlSession?.uploadTask(with: request, from: bodyData, completionHandler: { (data, response, error) in
            if (response != nil) {
                NSLog(String(format:"got a response! %@", response!))
            }
            
            if let anError = error {
                completionHandler(false, nil, anError);
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    //                                self.handleServerError(response)
                    let string = String(data: data!, encoding: .utf8)
                    
                    NSLog(String(format:"Error Response: %@", string!));
                    
                    //TODO: construct an error
                    completionHandler(false, nil, nil);
                    
                    return
            }
            
            completionHandler(true, data, nil);
        });
        
        uploadTask?.resume()
    }
    
    func constructFormData(imageData:Data?,boundary:String,fileName:String) -> NSData {
        let fullData = NSMutableData()
        
        //TODO: Clean this up, it looks messy
        // 1 - Boundary should start with --
        let lineOne = "------" + boundary + "\r\n"
        let lineTwo = "Content-Disposition: form-data; name=\"image\"\r\n\r\n"
        let lineFive = "\r\n"
        let lineSix = "------" + boundary + "--\r\n"
        
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 2
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 4
        fullData.append(imageData!)
        
        // 5
        fullData.append(lineFive.data(using: String.Encoding.utf8)!)
        
        // 6 - The end. Notice -- at the start and at the end
        fullData.append(lineSix.data(using: String.Encoding.utf8)!)
        
        return fullData
    }
    
    // MARK: URLSessionTaskDelegate methods
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let bytesSent:Double = Double(totalBytesSent)
        let totalBytes:Double = Double(totalBytesExpectedToSend)
        
        let percent:Double = bytesSent / totalBytes
        
        
        self.delegate?.uploadProgress(percent);
    }
    
}
