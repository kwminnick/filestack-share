//
//  FSIcons.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 02/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import Foundation

struct FSIcons {

    static var iconMore: UIImage {
        get {
            return UIImage(named: "icon-more")!
        }
    }

    static var iconVideo: UIImage {
        get {
            return UIImage(named: "icon-video")!
        }
    }

    static var iconFile: UIImage {
        get {
            return UIImage(named: "icon-file")!
        }
    }

    static var iconExport: UIImage {
        get {
            return UIImage(named: "icon-export")!.withRenderingMode(.alwaysTemplate)
        }
    }

    static var iconDownload: UIImage {
        get {
            return UIImage(named: "icon-download")!.withRenderingMode(.alwaysTemplate)
        }
    }

    static var iconShare: UIImage {
        get {
            return UIImage(named: "icon-share")!.withRenderingMode(.alwaysTemplate)
        }
    }

    static var iconTrash: UIImage {
        get {
            return UIImage(named: "icon-trash")!.withRenderingMode(.alwaysTemplate)
        }
    }

    static var iconLink: UIImage {
        get {
            return UIImage(named: "icon-link")!.withRenderingMode(.alwaysTemplate)
        }
    }

    static var iconCancel: UIImage {
        get {
            return UIImage(named: "icon-cancel")!.withRenderingMode(.alwaysTemplate)
        }
    }
}
