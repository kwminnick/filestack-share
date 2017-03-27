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

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

        title = "Filestack Share"
        view.backgroundColor = FSColor.lightGrey

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem(_:)))
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    fileprivate func setupCollectionView() {
        collectionView?.register(BlobCollectionViewCell.self, forCellWithReuseIdentifier: "blobCell")
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
    func presentActionControllerForBlob(_ blob: Blob?) {
        guard let unwrBlob = blob else {
            actionSheetFailure()
            return
        }

        let actionController = FSActionController(blob: unwrBlob, delegate: self)
        present(actionController, animated: true, completion: nil)
    }

    fileprivate func actionSheetFailure() {
        let alert = UIAlertController(message: "Selected action has failed.")
        present(alert, animated: true, completion: nil)
    }

    func addItem(_ sender: UIBarButtonItem) {
        let config = FSConfig()
        config.apiKey = Settings.apiKey
        config.selectMultiple = false

        let pickerController = FSPickerController(config: config, theme: FSTheme.filestack())
        pickerController?.fsDelegate = self

        present(pickerController!, animated: true, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? BlobCollectionViewCell

        if cell?.type == .image {
            let imageFullScreenViewController = ImageFullScreenViewController()
            imageFullScreenViewController.imageURL = cell?.blob?.url

            navigationController?.pushViewController(imageFullScreenViewController, animated: true)
        } else if cell?.type == .file {
            guard let url = cell?.blob?.url else {
                return
            }

            UIApplication.shared.openURL(URL(string:url)!)
        } else if cell?.type == .video {
            guard let url = cell?.blob?.url else {
                return
            }

            let videoPlayerViewController = VideoPlayerViewController()
            videoPlayerViewController.videoURL = url
            navigationController?.pushViewController(videoPlayerViewController, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: FSActionViewControllerDelegate extension
extension MainCollectionViewController: FSActionViewControllerDelegate {
    func copyBlobURLToClipboard(_ blob: Blob) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = blob.url

        let alert = UIAlertController(message: "Link has been copied to your clipboard.")
        present(alert, animated: true, completion: nil)
    }

    func exportBlob(_ blob: Blob) {
        let alert = UIAlertController(message: "Preparing to export...", noButtons: true)
        self.present(alert, animated: true, completion: nil)

        getBlobData(blob) { (data) in
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: {
                    let config = FSConfig()
                    config.apiKey = Settings.apiKey
                    config.data = data

                    let fileNameAndExtension = blob.fileName!.components(separatedBy: ".")

                    config.proposedFileName = fileNameAndExtension[0]
                    config.dataExtension = fileNameAndExtension[1]
                    config.dataMimeType = blob.mimeType!

                    let saveController = FSSaveController(config: config, theme: FSTheme.filestack())
                    saveController?.fsDelegate = self

                    self.present(saveController!, animated: true, completion: nil)
                })
            })
        }
    }

    func shareBlob(_ blob: Blob) {
        let alert = UIAlertController(message: "Preparing to share...", noButtons: true)
        self.present(alert, animated: true, completion: nil)

        getBlobData(blob) { (data) in
            let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: {
                    self.present(activityController, animated: true, completion: nil)
                })
            })
        }
    }

    fileprivate func getBlobData(_ blob: Blob, completion: @escaping (Data) -> ()) {
        let url = URL(string: blob.url!)
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        var dataTask: URLSessionDataTask?

        defer {
            defaultSession.finishTasksAndInvalidate()
        }

        dataTask = defaultSession.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                self.dismiss(animated: true, completion: nil)
                return
            }

            if let data = data {
                completion(data)
            }
        })

        dataTask?.resume()
    }

    func deleteBlob(_ blob: Blob) {
        guard let blobURL = blob.url else {
            actionSheetFailure()
            return
        }

        let alert = UIAlertController(title: "Are you sure you want to delete this file?", message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            let deletingAlert = UIAlertController(message: "Deleting the file...", noButtons: true)
            self.present(deletingAlert, animated: true, completion: nil)
            self.deleteBlobAction(blobURL, blob: blob)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func deleteBlobAction(_ blobURL: String, blob: Blob) {
        let filestack = Filestack(apiKey: Settings.apiKey)
        let fsBlob = FSBlob(url: blobURL)

        filestack?.remove(fsBlob) { error in
            if error != nil {
                self.actionSheetFailure()
            } else {
                DataStore.deleteCoreDataBlob(blob)
            }

            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}

// MARK: FSSaveDelegate extension
extension MainCollectionViewController: FSSaveDelegate {
    func fsSaveController(_ saveController: FSSaveController!, didFinishSavingMediaWith blob: FSBlob!) {
        self.dismiss(animated: true, completion: nil)
    }

    @nonobjc func fsSaveController(_ saveController: FSSaveController!, savingDidError error: NSError!) {
        self.dismiss(animated: true) {
            let alert = UIAlertController(message: "Oh! Something went wrong while exporting your file :(")
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: FSPickerDelegate extension
extension MainCollectionViewController: FSPickerDelegate {
    func fsPicker(_ picker: FSPickerController!, didFinishPickingMediaWith blobs: [FSBlob]!) {
        DataStore.createCoreDataBlobFromBlob(blobs[0])
        self.dismiss(animated: true, completion: nil)
    }

    func fsPicker(_ picker: FSPickerController!, pickingDidError error: Error!) {
        dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1)) {
                let alert = UIAlertController(message: "Oh! Something went wrong while sharing your file :(")
                self.present(alert, animated: true, completion: nil)
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
        self.itemSize = CGSize(width: itemSize, height: itemSize)
    }
}
