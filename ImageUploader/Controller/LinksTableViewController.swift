//
//  LinksTableViewController.swift
//  ImageUploader
//
//  Created by David Proskin on 8/23/18.
//  Copyright © 2018 Dave's Stuff. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LinksTableViewController : UITableViewController {
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
}
