//
//  MainViewController.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 31/05/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit
import FSPicker
import Filestack
import XLActionController

final class MainCollectionViewController: UICollectionViewController {

    let collectionViewDataSource = MainCollectionDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)

        title = "Filestack Share"
        view.backgroundColor = FSColor.lightGrey

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addItem(_:)))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(becomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)

        setupCollectionView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupCollectionView() {
        collectionView?.registerClass(BlobCollectionViewCell.self, forCellWithReuseIdentifier: "blobCell")
        collectionView?.dataSource = collectionViewDataSource
        collectionViewDataSource.prepareFetchedResultsController()
        collectionViewDataSource.sourcedController = self
        collectionView?.backgroundColor = FSColor.grey
        collectionView?.alwaysBounceVertical = true

        let layout = UICollectionViewFlowLayout(width: self.view.frame.width)
        collectionView?.collectionViewLayout = layout
    }

    func becomeActive() {
        collectionViewDataSource.refetchData()
    }

    // Called from dataSource
    func presentActionControllerForBlob(blob: Blob?) {
        guard let unwrBlob = blob else {
            actionSheetFailure()
            return
        }

        let actionController = FSActionController(blob: unwrBlob, delegate: self)
        presentViewController(actionController, animated: true, completion: nil)
    }

    private func actionSheetFailure() {
        let alert = UIAlertController(message: "Selected action has failed.")
        presentViewController(alert, animated: true, completion: nil)
    }

    func addItem(sender: UIBarButtonItem) {
        let config = FSConfig()
        config.apiKey = Settings.apiKey
        config.title = "Select a file"
        config.selectMultiple = false

        let pickerController = FSPickerController(config: config, theme: FSTheme.filestackTheme())
        pickerController.fsDelegate = self

        presentViewController(pickerController, animated: true, completion: nil)
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? BlobCollectionViewCell

        if cell?.type == .Image {
            let imageFullScreenViewController = ImageFullScreenViewController()
            imageFullScreenViewController.imageURL = cell?.blob?.url

            navigationController?.pushViewController(imageFullScreenViewController, animated: true)
        } else if cell?.type == .File {
            guard let url = cell?.blob?.url else {
                return
            }

            UIApplication.sharedApplication().openURL(NSURL(string:url)!)
        } else if cell?.type == .Video {
            guard let url = cell?.blob?.url else {
                return
            }

            let videoPlayerViewController = VideoPlayerViewController()
            videoPlayerViewController.videoURL = url
            navigationController?.pushViewController(videoPlayerViewController, animated: true)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: FSActionViewControllerDelegate extension
extension MainCollectionViewController: FSActionViewControllerDelegate {
    func copyBlobURLToClipboard(blob: Blob) {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = blob.url

        let alert = UIAlertController(message: "Link has been copied to your clipboard.")
        presentViewController(alert, animated: true, completion: nil)
    }

    func exportBlob(blob: Blob) {
        let alert = UIAlertController(message: "Preparing to export...", noButtons: true)
        self.presentViewController(alert, animated: true, completion: nil)

        getBlobData(blob) { (data) in
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: {
                    let config = FSConfig()
                    config.apiKey = Settings.apiKey
                    config.title = "Select a service"
                    config.data = data

                    let fileNameAndExtension = blob.fileName!.componentsSeparatedByString(".")

                    config.proposedFileName = fileNameAndExtension[0]
                    config.dataExtension = fileNameAndExtension[1]
                    config.dataMimeType = blob.mimeType!

                    let saveController = FSSaveController(config: config, theme: FSTheme.filestackTheme())
                    saveController.fsDelegate = self

                    self.presentViewController(saveController, animated: true, completion: nil)
                })
            })
        }
    }

    func shareBlob(blob: Blob) {
        let alert = UIAlertController(message: "Preparing to share...", noButtons: true)
        self.presentViewController(alert, animated: true, completion: nil)

        getBlobData(blob) { (data) in
            let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: {
                    self.presentViewController(activityController, animated: true, completion: nil)
                })
            })
        }
    }

    private func getBlobData(blob: Blob, completion: (NSData) -> ()) {
        let url = NSURL(string: blob.url!)
        let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var dataTask: NSURLSessionDataTask?

        defer {
            defaultSession.finishTasksAndInvalidate()
        }

        dataTask = defaultSession.dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            if error != nil {
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }

            if let data = data {
                completion(data)
            }
        })

        dataTask?.resume()
    }

    func deleteBlob(blob: Blob) {
        guard let blobURL = blob.url else {
            actionSheetFailure()
            return
        }

        let alert = UIAlertController(title: "Are you sure you want to delete this file?", message: nil, preferredStyle: .Alert)

        let okAction = UIAlertAction(title: "Yes", style: .Destructive) { _ in
            let deletingAlert = UIAlertController(message: "Deleting the file...", noButtons: true)
            self.presentViewController(deletingAlert, animated: true, completion: nil)
            self.deleteBlobAction(blobURL, blob: blob)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func deleteBlobAction(blobURL: String, blob: Blob) {
        let filestack = Filestack(apiKey: Settings.apiKey)
        let fsBlob = FSBlob(URL: blobURL)

        filestack.remove(fsBlob) { error in
            if error != nil {
                self.actionSheetFailure()
            } else {
                DataStore.deleteCoreDataBlob(blob)
            }

            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
}

// MARK: FSSaveDelegate extension
extension MainCollectionViewController: FSSaveDelegate {
    func fsSaveController(saveController: FSSaveController!, didFinishSavingMediaWithBlob blob: FSBlob!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func fsSaveController(saveController: FSSaveController!, savingDidError error: NSError!) {
        self.dismissViewControllerAnimated(true) {
            let alert = UIAlertController(message: "Oh! Something went wrong while exporting your file :(")
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

// MARK: FSPickerDelegate extension
extension MainCollectionViewController: FSPickerDelegate {
    func fsPicker(picker: FSPickerController!, didFinishPickingMediaWithBlobs blobs: [FSBlob]!) {
        DataStore.createCoreDataBlobFromBlob(blobs[0])
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func fsPicker(picker: FSPickerController!, pickingDidError error: NSError!) {
        dismissViewControllerAnimated(true) {
            dispatch_after(dispatch_time_t(1), dispatch_get_main_queue()) {
                let alert = UIAlertController(message: "Oh! Something went wrong while sharing your file :(")
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}

extension UICollectionViewFlowLayout {
    convenience init(width: CGFloat) {
        self.init()

        let itemSize = (width / 2) - 20

        self.minimumLineSpacing = 15
        self.minimumInteritemSpacing = 10
        self.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15)
        self.itemSize = CGSizeMake(itemSize, itemSize)
    }
}
