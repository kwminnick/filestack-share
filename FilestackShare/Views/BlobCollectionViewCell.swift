//
//  BlobCollectionViewCell.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 01/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit

enum BlobCellType {
    case unknown
    case image
    case video
    case file
}

class BlobCollectionViewCell: UICollectionViewCell {

    fileprivate let barLabelHeight: CGFloat = 24.0
    fileprivate var blackBar: UIView?
    var moreButton: UIButton?
    var blobLabel: UILabel?
    var imageView: UIImageView?
    var blob: Blob?

    var type: BlobCellType {
        didSet {
            switch type {
            case .file:
                self.imageView?.contentMode = .center
                self.imageView?.image = FSIcons.iconFile
            case .image:
                self.imageView?.contentMode = .scaleToFill
            case .video:
                self.imageView?.contentMode = .center
                self.imageView?.image = FSIcons.iconVideo
            default:
                self.imageView?.contentMode = .scaleToFill
            }
        }
    }

    override init(frame: CGRect) {
        self.type = .unknown
        super.init(frame: frame)

        setupImageView()
        setupBlackBar()
        setupMoreButton()
        setupBlobLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupBlobLabel() {
        blobLabel = UILabel()
        let font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        blobLabel?.textAlignment = .left
        blobLabel?.translatesAutoresizingMaskIntoConstraints = false
        blobLabel?.font = font
        blobLabel?.textColor = UIColor.white

        self.addSubview(blobLabel!)

        blobLabel?.constraintHeight(barLabelHeight)
        blobLabel?.leftConstraintToItem(self, constant: 5)
        blobLabel?.rightConstraintToItem(self, constant: -34)
        blobLabel?.bottomConstraintToItem(self, constant: 0)
    }

    fileprivate func setupBlackBar() {
        blackBar = UIView()
        blackBar?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        blackBar?.translatesAutoresizingMaskIntoConstraints = false

        addSubview(blackBar!)

        blackBar?.constraintHeight(24)
        blackBar?.leftConstraintToItem(self, constant: 0)
        blackBar?.rightConstraintToItem(self, constant: 0)
        blackBar?.bottomConstraintToItem(self, constant: 0)
    }

    fileprivate func setupMoreButton() {
        let moreIcon = FSIcons.iconMore
        moreButton = UIButton(frame: CGRect(x: 0, y: 0, width: barLabelHeight, height: barLabelHeight))
        moreButton?.setImage(moreIcon, for: UIControlState())
        moreButton?.translatesAutoresizingMaskIntoConstraints = false

        addSubview(moreButton!)

        moreButton?.constraintWidth(barLabelHeight)
        moreButton?.constraintHeight(barLabelHeight)
        moreButton?.bottomConstraintToItem(self, constant: 0)
        moreButton?.rightConstraintToItem(self, constant: -5)
    }

    fileprivate func setupImageView() {
        imageView = UIImageView()
        imageView?.backgroundColor = FSColor.darkGrey
        imageView?.tintColor = FSColor.iconTint
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView!)

        imageView?.constraintWidth(self.frame.width)
        imageView?.constraintHeight(self.frame.width - barLabelHeight)
        imageView?.topConstraintToItem(self, constant: 0)
        imageView?.leftConstraintToItem(self, constant: 0)
    }
}
