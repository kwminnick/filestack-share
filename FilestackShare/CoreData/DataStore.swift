//
//  DataStore.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 01/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import Foundation
import CoreData
import FSPicker

final class DataStore: NSObject {

    private static let coreDataStack = CoreDataStack()

    class func fetchedResultsController() -> NSFetchedResultsController {
        let context = coreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Blob")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "uploaded", ascending: false)]

        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }

    class func createCoreDataBlobFromBlob(blob: FSBlob) {
        let context = coreDataStack.managedObjectContext
        guard let entity = NSEntityDescription.entityForName("Blob", inManagedObjectContext: context) else {
            return
        }

        let cdBlob = Blob(entity: entity, insertIntoManagedObjectContext: context)
        let fsHandler = blob.url.componentsSeparatedByString("/").last

        if let handler = fsHandler {
            cdBlob.thumbURL = "https://process.filestackapi.com/resize=height:250,fit:max/\(handler)"
        } else {
            cdBlob.thumbURL = blob.url
        }

        cdBlob.url = blob.url
        cdBlob.fileName = blob.fileName
        cdBlob.size = blob.size
        cdBlob.mimeType = blob.mimeType

        if blob.mimeType.containsString("video") {
            cdBlob.isVideo = true
        } else if !blob.mimeType.containsString("image") {
            cdBlob.isFile = true
        }

        cdBlob.uploaded = NSDate().timeIntervalSince1970
        try! context.save()
    }

    class func deleteCoreDataBlob(blob: Blob) {
        let context = coreDataStack.managedObjectContext

        context.deleteObject(blob)
        try! context.save()
    }

    class func saveDB() {
        coreDataStack.saveContext()
    }
}

final class CoreDataStack {

    lazy var applicationDocumentsDirectory: NSURL = {
        let url = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.FilestackShare")
        return url!
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("FilestackShare", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("FilestackShare.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}