//
//  UIImage+Rotation.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 06/07/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    func fixRotation() -> UIImage {
        let imgRef = self.cgImage

        let width = CGFloat(imgRef!.width)
        let height = CGFloat(imgRef!.height)

        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let scaleRatio: CGFloat = bounds.width / width
        let imageSize = CGSize(width: width, height: height)

        var boundHeight: CGFloat
        var transform = CGAffineTransform.identity

        let orientation = self.imageOrientation

        switch orientation {
        case .up:
            transform = CGAffineTransform.identity
        case .upMirrored:
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .down:
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height);
            transform = transform.rotated(by: CGFloat(M_PI));
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height);
            transform = transform.scaledBy(x: 1.0, y: -1.0);
        case .leftMirrored:
            boundHeight = bounds.height;
            bounds.size.height = bounds.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width);
            transform = transform.scaledBy(x: -1.0, y: 1.0);
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0);
        case .left:
            boundHeight = bounds.height;
            bounds.size.height = bounds.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.width);
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0);
        case .rightMirrored:
            boundHeight = bounds.height;
            bounds.size.height = bounds.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0);
        case .right:
            boundHeight = bounds.height;
            bounds.size.height = bounds.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0);
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0);
        }

        UIGraphicsBeginImageContext(bounds.size);

        let context = UIGraphicsGetCurrentContext();

        if (orientation == .right || orientation == .left) {
            context!.scaleBy(x: -scaleRatio, y: scaleRatio);
            context!.translateBy(x: -height, y: 0);
        } else {
            context!.scaleBy(x: scaleRatio, y: -scaleRatio);
            context!.translateBy(x: 0, y: -height);
        }

        context!.concatenate(transform);

        context?.draw(imgRef!, in: CGRect(x: 0, y: 0, width: width, height: height))
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return imageCopy!
    }
}
