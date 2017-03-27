//
//  ImageFullScreenViewController.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 13/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit
import Nuke

final class ImageFullScreenViewController: UIViewController {

    fileprivate let imageView = UIImageView()
    fileprivate let scrollView = UIScrollView()
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    fileprivate var imageViewTopConstraint: NSLayoutConstraint!
    fileprivate var imageViewBottomConstraint: NSLayoutConstraint!
    fileprivate var imageViewTrailingConstraint: NSLayoutConstraint!
    fileprivate var imageViewLeadingConstraint: NSLayoutConstraint!
    var imageURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreen))
        scrollView.addGestureRecognizer(recognizer)

        view.backgroundColor = FSColor.darkGrey

        setupScrollView()
        setupActivityIndicator()
        setupImageView()

        updateConstraintsForSize(view.bounds.size)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()


        updateMinZoomScaleForSize(view.bounds.size)
    }

    fileprivate func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)

        activityIndicator.constraintWidth(30)
        activityIndicator.constraintHeight(30)
        activityIndicator.centerXToItem(view, constant: 0)
        activityIndicator.centerYToItem(view, constant: 0)

        activityIndicator.startAnimating()
    }

    fileprivate func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.maximumZoomScale = 5
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true

        view.addSubview(scrollView)
        scrollView.spreadOutOnView(view)
    }

    fileprivate func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(imageView)

        imageViewBottomConstraint = NSLayoutConstraint(item: imageView,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: scrollView,
                                                       attribute: .bottom,
                                                       multiplier: 1,
                                                       constant: 0)

        imageViewTopConstraint = NSLayoutConstraint(item: imageView,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: scrollView,
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: 0)

        imageViewLeadingConstraint = NSLayoutConstraint(item: imageView,
                                                        attribute: .left,
                                                        relatedBy: .equal,
                                                        toItem: scrollView,
                                                        attribute: .left,
                                                        multiplier: 1,
                                                        constant: 0)

        imageViewTrailingConstraint = NSLayoutConstraint(item: imageView,
                                                         attribute: .right,
                                                         relatedBy: .equal,
                                                         toItem: scrollView,
                                                         attribute: .right,
                                                         multiplier: 1,
                                                         constant: 0)

        scrollView.addConstraints([
            imageViewTopConstraint,
            imageViewBottomConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint])
        
        let cts = CancellationTokenSource()
        let request = Request(url: URL(string: imageURL!)!)

        Loader.shared.loadImage(with: request, token: cts.token) { (Image) in
            self.activityIndicator.stopAnimating()
            if (Image.value != nil) {
                self.imageView.image = Image.value
                self.updateMinZoomScaleForSize(self.view.bounds.size)
                self.updateConstraintsForSize(self.view.bounds.size)
            }
        }
        cts.cancel()
    }

    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let minScale: CGFloat

        if (Int(imageView.bounds.width) == 0 || Int(imageView.bounds.height) == 0) {
            if let image = imageView.image {
                let widthScale = size.width / image.size.width
                let heightScale = size.height / image.size.height
                minScale = min(widthScale, heightScale)
            } else {
                minScale = 1.0
            }
        } else {
            let widthScale = size.width / imageView.bounds.width
            let heightScale = size.height / imageView.bounds.height
            minScale = min(widthScale, heightScale)
        }

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }

    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = Int(imageView.bounds.height) == 0 ? 0.0 : max(0, (size.height - imageView.frame.height) / 2)
        let xOffset = Int(imageView.bounds.width) == 0 ? 0.0 : max(0, (size.width - imageView.frame.width) / 2)

        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        view.layoutIfNeeded()
    }

    func dismissFullScreen() {
        navigationController?.popViewController(animated: true)
    }

}

extension ImageFullScreenViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}
