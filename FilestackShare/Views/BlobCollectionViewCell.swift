//
//  BlobCollectionViewCell.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 01/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit

enum BlobCellType {
    case Unknown
    case Image
    case Video
    case File
}

class BlobCollectionViewCell: UICollectionViewCell {

    private let barLabelHeight: CGFloat = 24.0
    private var blackBar: UIView?
    var moreButton: UIButton?
    var blobLabel: UILabel?
    var imageView: UIImageView?
    var blob: Blob?

    var type: BlobCellType {
        didSet {
            switch type {
            case .File:
                self.imageView?.contentMode = .Center
                self.imageView?.image = FSIcons.iconFile
            case .Image:
                self.imageView?.contentMode = .ScaleToFill
            case .Video:
                self.imageView?.contentMode = .Center
                self.imageView?.image = FSIcons.iconVideo
            default:
                self.imageView?.contentMode = .ScaleToFill
            }
        }
    }

    override init(frame: CGRect) {
        self.type = .Unknown
        super.init(frame: frame)

        setupImageView()
        setupBlackBar()
        setupMoreButton()
        setupBlobLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBlobLabel() {
        blobLabel = UILabel()
        let font = UIFont.systemFontOfSize(12, weight: UIFontWeightRegular)
        blobLabel?.textAlignment = .Left
        blobLabel?.translatesAutoresizingMaskIntoConstraints = false
        blobLabel?.font = font
        blobLabel?.textColor = UIColor.whiteColor()

        self.addSubview(blobLabel!)

        blobLabel?.constraintHeight(barLabelHeight)
        blobLabel?.leftConstraintToItem(self, constant: 5)
        blobLabel?.rightConstraintToItem(self, constant: -34)
        blobLabel?.bottomConstraintToItem(self, constant: 0)
    }

    private func setupBlackBar() {
        blackBar = UIView()
        blackBar?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        blackBar?.translatesAutoresizingMaskIntoConstraints = false

        addSubview(blackBar!)

        blackBar?.constraintHeight(24)
        blackBar?.leftConstraintToItem(self, constant: 0)
        blackBar?.rightConstraintToItem(self, constant: 0)
        blackBar?.bottomConstraintToItem(self, constant: 0)
    }

    private func setupMoreButton() {
        let moreIcon = FSIcons.iconMore
        moreButton = UIButton(frame: CGRectMake(0, 0, barLabelHeight, barLabelHeight))
        moreButton?.setImage(moreIcon, forState: .Normal)
        moreButton?.translatesAutoresizingMaskIntoConstraints = false

        addSubview(moreButton!)

        moreButton?.constraintWidth(barLabelHeight)
        moreButton?.constraintHeight(barLabelHeight)
        moreButton?.bottomConstraintToItem(self, constant: 0)
        moreButton?.rightConstraintToItem(self, constant: -5)
    }

    private func setupImageView() {
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
