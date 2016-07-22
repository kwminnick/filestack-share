//
//  Blob+CoreDataProperties.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 02/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import Foundation
import CoreData

extension Blob {
    @NSManaged var thumbURL: String?
    @NSManaged var fileName: String?
    @NSManaged var size: NSNumber?
    @NSManaged var uploaded: NSNumber?
    @NSManaged var url: String?
    @NSManaged var mimeType: String?
    @NSManaged var isVideo: Bool
    @NSManaged var isFile: Bool
}
