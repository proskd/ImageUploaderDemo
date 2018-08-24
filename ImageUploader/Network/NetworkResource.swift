//
//  NetworkResource.swift
//  ImageUploader
//
//  Created by David Proskin on 8/16/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation

public protocol NetworkResourceDelegate {
    func uploadProgress(_ progress:Double) -> Void;
}

public protocol NetworkResource {
    
    //Consider moving this to a delegate method?  
    typealias UploadCompletionHandler = (Bool, Data?, Error?) -> Swift.Void;
    
    func uploadImageData(_ data:Data?, completionHandler: @escaping UploadCompletionHandler);
}
