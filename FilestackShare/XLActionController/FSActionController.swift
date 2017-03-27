//  Youtube.swift
//  Youtube ( https://github.com/xmartlabs/XLActionController )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import XLActionController

final class FSActionCell: ActionCell {

    lazy var animatableBackgroundView: UIView = { [weak self] in
        let view = UIView(frame: self?.frame ?? CGRect.zero)
        view.backgroundColor = UIColor.red.withAlphaComponent(0.40)
        return view
        }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    func initialize() {
        backgroundColor = FSColor.darkGrey
        actionTitleLabel?.textColor = FSColor.lightGrey
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backgroundView.addSubview(animatableBackgroundView)
        selectedBackgroundView = backgroundView
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                animatableBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                animatableBackgroundView.frame = CGRect(x: 0, y: 0, width: 30, height: frame.height)
                animatableBackgroundView.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)

                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    guard let me = self else {
                        return
                    }

                    me.animatableBackgroundView.frame = CGRect(x: 0, y: 0, width: me.frame.width, height: me.frame.height)
                    me.animatableBackgroundView.backgroundColor = FSColor.lightGreen.withAlphaComponent(0.4)
                }) 
            } else {
                animatableBackgroundView.backgroundColor = animatableBackgroundView.backgroundColor?.withAlphaComponent(0.0)
            }
        }
    }
}

protocol FSActionViewControllerDelegate: class {
    func copyBlobURLToClipboard(_ blob: Blob)
    func shareBlob(_ blob: Blob)
    func exportBlob(_ blob: Blob)
    func deleteBlob(_ blob: Blob)
}

final class FSActionController: ActionController<FSActionCell, ActionData, UICollectionReusableView, Void, UICollectionReusableView, Void> {
    weak var delegate: FSActionViewControllerDelegate?
    weak var blob: Blob!

    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        collectionViewLayout.minimumLineSpacing = -0.5

        settings.behavior.hideOnTap = false
        settings.behavior.hideOnScrollDown = false
        settings.animation.scale = nil
        settings.animation.present.duration = 0.4
        settings.animation.dismiss.duration = 0.4
        settings.animation.dismiss.offset = 30
        settings.animation.dismiss.options = .curveLinear

        cellSpec = .nibFile(nibName: "FSActionCell", bundle: Bundle(for: FSActionCell.self), height: { _  in 46 })

        onConfigureCellForAction = { cell, action, indexPath in
            cell.setup(action.data?.title, detail: action.data?.subtitle, image: action.data?.image)
            cell.alpha = action.enabled ? 1.0 : 0.5
            cell.actionImageView?.tintColor = FSColor.iconTint
            cell.actionTitleLabel?.textColor = action.style == .destructive ? FSColor.darkOrange : FSColor.textLightGrey
            let font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
            cell.actionTitleLabel?.font = font

            // Hackity, hack, hack
            if action.data?.title != "Cancel" {
                let separator = UIView(frame: CGRect(x: 0, y: cell.frame.height - 1, width: cell.frame.width, height: 1))
                separator.backgroundColor = FSColor.grey
                cell.addSubview(separator)
            }
        }
    }

    convenience init(blob: Blob, delegate: FSActionViewControllerDelegate) {
        self.init()
        self.delegate = delegate
        self.blob = blob

        setupFilestackSheet()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func dismiss() {
        // NO-OP
    }

    fileprivate func setupFilestackSheet() {
        addAction(Action(ActionData(title: "Share", image: FSIcons.iconShare), style: .default, handler: { _ in
            DispatchQueue.main.async(execute: {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                self.delegate?.shareBlob(self.blob)
            })
        }))

        addAction(Action(ActionData(title: "Copy Link", image: FSIcons.iconLink), style: .default, handler: { _ in
            DispatchQueue.main.async(execute: {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                self.delegate?.copyBlobURLToClipboard(self.blob)
            })
        }))

        addAction(Action(ActionData(title: "Export", image: FSIcons.iconExport), style: .default, handler: { _ in
            DispatchQueue.main.async(execute: {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                self.delegate?.exportBlob(self.blob)
            })
        }))

        addAction(Action(ActionData(title: "Delete", image: FSIcons.iconTrash), style: .default, handler: { _ in
            DispatchQueue.main.async(execute: {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                self.delegate?.deleteBlob(self.blob)
            })
        }))
        
        addAction(Action(ActionData(title: "Cancel", image: FSIcons.iconCancel), style: .default, handler: { _ in
            DispatchQueue.main.async(execute: {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            })
        }))
    }
}
