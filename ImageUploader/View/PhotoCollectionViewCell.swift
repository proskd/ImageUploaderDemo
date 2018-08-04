//
//  PhotoCollectionViewCell.swift
//  ImageUploader
//
//  Created by David Proskin on 8/4/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    public var imageRequest:PHImageRequestID = PHInvalidImageRequestID;
}
