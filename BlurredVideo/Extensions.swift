//
//  Extensions.swift
//  BlurredVideo
//
//  Created by Jonathan Landon on 10/20/16.
//  Copyright © 2016 Jonathan Landon. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UIView {
    @discardableResult
    func add(toSuperview superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }
}

extension CALayer {
    @discardableResult
    func add(to superlayer: CALayer) -> Self {
        superlayer.addSublayer(self)
        return self
    }
}

extension AVAsset {
    var totalRange: CMTimeRange {
        return CMTimeRange(start: kCMTimeZero, duration: duration)
    }
}

extension CMTime {
    static var zero: CMTime {
        return kCMTimeZero
    }
}

extension AVMutableCompositionTrack {
    func insertFirstVideoTrack(from asset: AVAsset) {
        let track = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        try! insertTimeRange(asset.totalRange, of: track, at: .zero)
    }
    
    func insertFirstAudioTrack(from asset: AVAsset) {
        let track = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
        try! insertTimeRange(asset.totalRange, of: track, at: .zero)
    }
}

extension AVMutableComposition {
    func addVideoTrack(id: CMPersistentTrackID) -> AVMutableCompositionTrack {
        return addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: id)
    }
    
    func addAudioTrack(id: CMPersistentTrackID) -> AVMutableCompositionTrack {
        return addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: id)
    }
}
