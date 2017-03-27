//
//  VideoPlayerViewController.swift
//  FilestackShare
//
//  Created by Łukasz Cichecki on 15/06/16.
//  Copyright © 2016 Filestack. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: AVPlayerViewController {

    var videoURL: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.player = AVPlayer(url: URL(string: videoURL)!)
    }
}
