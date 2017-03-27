//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Łukasz Cichecki on 05/07/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit
import Filestack

final class ShareViewController: UIViewController {
    var fileName: String!
    var contentType: String!
    var progressView: UIProgressView!
    var itemProvider: NSItemProvider!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadItems()
    }

    private func loadItems() {
        displayProgressAlert()

        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            cancelRequest()
            return
        }

        for attachment in extensionItem.attachments! {
            guard let anItemProvider = attachment as? NSItemProvider else {
                cancelRequest()
                return
            }

            contentType = anItemProvider.registeredTypeIdentifiers.first as? String
            itemProvider = anItemProvider

            if itemProvider.hasItemConformingToTypeIdentifier("public.image") {
                rotateAndUploadImage()
            } else {
                uploadDataItem()
            }
        }
    }

    private func displayProgressAlert() {
        progressView = UIProgressView(progressViewStyle: .default)

        let progressAlert = UIAlertController(title: "Filestack Share", message: "Uploading\n", progressView: progressView)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.cancelRequest()
        }

        progressAlert.addAction(cancelAction)

        DispatchQueue.global(qos: .background).async {
            self.present(progressAlert, animated: true, completion: nil)
        }

    }

    private func rotateAndUploadImage() {
        itemProvider.loadItem(forTypeIdentifier: contentType!, options: nil) { (item, error) in
            guard let itemURL = item as? NSURL else {
                self.cancelRequest()
                return
            }

            self.fileName = itemURL.lastPathComponent ?? ""

            let image = UIImage(contentsOfFile: itemURL.path!)
            let rotatedImage = image?.fixRotation()
            let imageData = UIImageJPEGRepresentation(rotatedImage!, 0.95)

            self.uploadData(data: imageData! as NSData)
        }
    }

    private func uploadDataItem() {
        itemProvider.loadItem(forTypeIdentifier: contentType!, options: nil) { (item, error) in
            guard let itemURL = item as? NSURL else {
                self.cancelRequest()
                return
            }

            self.fileName = itemURL.lastPathComponent ?? ""

            guard let itemData = NSData(contentsOf: itemURL as URL) else {
                self.cancelRequest()
                return
            }

            self.uploadData(data: itemData)
        }
    }

    private func uploadData(data: NSData) {
        let filestack = Filestack(apiKey: Settings.apiKey)
        let storeOptions = FSStoreOptions()

        storeOptions.fileName = fileName

        filestack?.store(data as Data!, with: storeOptions, progress: { (progress) in
            DispatchQueue.main.async {
                self.progressView.setProgress(Float((progress?.fractionCompleted)!), animated: true)
            }
        }) { (blob, error) in
            guard blob != nil else {
                self.cancelRequest()
                return
            }

            DataStore.createCoreDataBlobFromBlob(blob!)

            let pasteboard = UIPasteboard.general
            pasteboard.string = blob?.url

            self.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: "Filestack Share", message: "Link has been copied to your clipboard.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.finishRequest()
                })

                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            })
        }
    }

    private func cancelRequest() {
        let error = NSError(domain: "filestack.com", code: 0, userInfo: nil)
        extensionContext?.cancelRequest(withError: error)
    }

    private func finishRequest() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
