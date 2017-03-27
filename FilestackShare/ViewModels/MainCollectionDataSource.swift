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
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    fileprivate var noOfFetchedItems: Int!

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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }

        noOfFetchedItems = sections[section].numberOfObjects

        return noOfFetchedItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blobCell", for: indexPath) as! BlobCollectionViewCell
        let blob = fetchedResultsController.object(at: indexPath) as? Blob

        guard let unwrBlob = blob else {
            return cell
        }

        cell.imageView?.image = nil

        if unwrBlob.isVideo {
            cell.type = .video
        } else if unwrBlob.isFile {
            cell.type = .file
        } else {
            let imageURL = URL(string: unwrBlob.thumbURL!)
            cell.type = .image
            let request = Request(url: imageURL!)
            Nuke.loadImage(with: request, into: cell.imageView!)
        }

        cell.blobLabel?.text = unwrBlob.fileName
        cell.moreButton?.addTarget(self, action: #selector(presentActionController(_:)), for: .touchUpInside)
        cell.blob = unwrBlob

        return cell
    }

    func presentActionController(_ sender: UIButton) {
        guard let cell = sender.superview as? BlobCollectionViewCell else {
            return
        }

        DispatchQueue.main.async {
            self.sourcedController?.presentActionControllerForBlob(cell.blob)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let collectionView = sourcedController?.collectionView

        collectionView?.performBatchUpdates({
            switch(type) {
            case .insert:
                collectionView?.insertSections(IndexSet(integer: sectionIndex))
            case .delete:
                collectionView?.deleteSections(IndexSet(integer: sectionIndex))
            default:
                break
            }
        }, completion: nil)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let collectionView = sourcedController?.collectionView

        collectionView?.performBatchUpdates({
            switch(type) {
            case .insert:
                collectionView?.insertItems(at: [newIndexPath!])
            case .delete:
                collectionView?.deleteItems(at: [indexPath!])
            case .update:
                collectionView?.reloadItems(at: [indexPath!])
            case .move:
                collectionView?.deleteItems(at: [indexPath!])
                collectionView?.insertItems(at: [newIndexPath!])
            }
        }, completion: nil)
    }
}
