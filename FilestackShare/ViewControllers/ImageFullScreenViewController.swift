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

    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewBottomConstraint: NSLayoutConstraint!
    private var imageViewTrailingConstraint: NSLayoutConstraint!
    private var imageViewLeadingConstraint: NSLayoutConstraint!
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()


        updateMinZoomScaleForSize(view.bounds.size)
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)

        activityIndicator.constraintWidth(30)
        activityIndicator.constraintHeight(30)
        activityIndicator.centerXToItem(view, constant: 0)
        activityIndicator.centerYToItem(view, constant: 0)

        activityIndicator.startAnimating()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.maximumZoomScale = 5
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true

        view.addSubview(scrollView)
        scrollView.spreadOutOnView(view)
    }

    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(imageView)

        imageViewBottomConstraint = NSLayoutConstraint(item: imageView,
                                                       attribute: .Bottom,
                                                       relatedBy: .Equal,
                                                       toItem: scrollView,
                                                       attribute: .Bottom,
                                                       multiplier: 1,
                                                       constant: 0)

        imageViewTopConstraint = NSLayoutConstraint(item: imageView,
                                                    attribute: .Top,
                                                    relatedBy: .Equal,
                                                    toItem: scrollView,
                                                    attribute: .Top,
                                                    multiplier: 1,
                                                    constant: 0)

        imageViewLeadingConstraint = NSLayoutConstraint(item: imageView,
                                                        attribute: .Left,
                                                        relatedBy: .Equal,
                                                        toItem: scrollView,
                                                        attribute: .Left,
                                                        multiplier: 1,
                                                        constant: 0)

        imageViewTrailingConstraint = NSLayoutConstraint(item: imageView,
                                                         attribute: .Right,
                                                         relatedBy: .Equal,
                                                         toItem: scrollView,
                                                         attribute: .Right,
                                                         multiplier: 1,
                                                         constant: 0)

        scrollView.addConstraints([
            imageViewTopConstraint,
            imageViewBottomConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint])

        Nuke.taskWith(NSURL(string: imageURL!)!) { (response) in
            self.activityIndicator.stopAnimating()
            if let image = response.image {
                self.imageView.image = image
                self.updateMinZoomScaleForSize(self.view.bounds.size)
                self.updateConstraintsForSize(self.view.bounds.size)
            }
        }.resume()
    }

    private func updateMinZoomScaleForSize(size: CGSize) {
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

    private func updateConstraintsForSize(size: CGSize) {
        let yOffset = Int(imageView.bounds.height) == 0 ? 0.0 : max(0, (size.height - imageView.frame.height) / 2)
        let xOffset = Int(imageView.bounds.width) == 0 ? 0.0 : max(0, (size.width - imageView.frame.width) / 2)

        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        view.layoutIfNeeded()
    }

    func dismissFullScreen() {
        navigationController?.popViewControllerAnimated(true)
    }

}

extension ImageFullScreenViewController: UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}
