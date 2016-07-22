//
//  MainCollectionDataSource.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 01/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit
import Nuke
import CoreData

final class MainCollectionDataSource: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    weak var sourcedController: MainCollectionViewController?
    private var fetchedResultsController: NSFetchedResultsController!
    private var noOfFetchedItems: Int!

    func prepareFetchedResultsController() {
        fetchedResultsController = DataStore.fetchedResultsController()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    func refetchData() {
        try! fetchedResultsController.performFetch()
        let currentNoOfItems = fetchedResultsController.sections?[0].numberOfObjects

        if noOfFetchedItems != currentNoOfItems {
            sourcedController?.collectionView?.reloadData()
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }

        noOfFetchedItems = sections[section].numberOfObjects

        return noOfFetchedItems
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("blobCell", forIndexPath: indexPath) as! BlobCollectionViewCell
        let blob = fetchedResultsController.objectAtIndexPath(indexPath) as? Blob

        guard let unwrBlob = blob else {
            return cell
        }

        cell.imageView?.image = nil

        if unwrBlob.isVideo {
            cell.type = .Video
        } else if unwrBlob.isFile {
            cell.type = .File
        } else {
            let imageURL = NSURL(string: unwrBlob.thumbURL!)
            cell.type = .Image
            cell.imageView?.nk_setImageWith(imageURL!)
        }

        cell.blobLabel?.text = unwrBlob.fileName
        cell.moreButton?.addTarget(self, action: #selector(presentActionController(_:)), forControlEvents: .TouchUpInside)
        cell.blob = unwrBlob

        return cell
    }

    func presentActionController(sender: UIButton) {
        guard let cell = sender.superview as? BlobCollectionViewCell else {
            return
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.sourcedController?.presentActionControllerForBlob(cell.blob)
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let collectionView = sourcedController?.collectionView

        collectionView?.performBatchUpdates({
            switch(type) {
            case .Insert:
                collectionView?.insertSections(NSIndexSet(index: sectionIndex))
            case .Delete:
                collectionView?.deleteSections(NSIndexSet(index: sectionIndex))
            default:
                break
            }
        }, completion: nil)
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let collectionView = sourcedController?.collectionView

        collectionView?.performBatchUpdates({
            switch(type) {
            case .Insert:
                collectionView?.insertItemsAtIndexPaths([newIndexPath!])
            case .Delete:
                collectionView?.deleteItemsAtIndexPaths([indexPath!])
            case .Update:
                collectionView?.reloadItemsAtIndexPaths([indexPath!])
            case .Move:
                collectionView?.deleteItemsAtIndexPaths([indexPath!])
                collectionView?.insertItemsAtIndexPaths([newIndexPath!])
            }
        }, completion: nil)
    }
}