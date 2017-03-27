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

    fileprivate static let coreDataStack = CoreDataStack()

    class func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let context = coreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Blob")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "uploaded", ascending: false)]

        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }

    class func createCoreDataBlobFromBlob(_ blob: FSBlob) {
        let context = coreDataStack.managedObjectContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Blob", in: context) else {
            return
        }

        let cdBlob = Blob(entity: entity, insertInto: context)
        let fsHandler = blob.url.components(separatedBy: "/").last

        if let handler = fsHandler {
            cdBlob.thumbURL = "https://process.filestackapi.com/resize=height:250,fit:max/\(handler)"
        } else {
            cdBlob.thumbURL = blob.url
        }

        cdBlob.url = blob.url
        cdBlob.fileName = blob.fileName
        cdBlob.size = blob.size as NSNumber?
        cdBlob.mimeType = blob.mimeType

        if blob.mimeType.contains("video") {
            cdBlob.isVideo = true
        } else if !blob.mimeType.contains("image") {
            cdBlob.isFile = true
        }

        cdBlob.uploaded = Date().timeIntervalSince1970 as NSNumber?
        try! context.save()
    }

    class func deleteCoreDataBlob(_ blob: Blob) {
        let context = coreDataStack.managedObjectContext

        context.delete(blob)
        try! context.save()
    }

    class func saveDB() {
        coreDataStack.saveContext()
    }
}

final class CoreDataStack {

    lazy var applicationDocumentsDirectory: URL = {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.FilestackShare")
        return url!
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "FilestackShare", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("FilestackShare.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
