//
//  ViewController.swift
//  BlurredVideo
//
//  Created by Jonathan Landon on 10/19/16.
//  Copyright © 2016 Jonathan Landon. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

final class ViewController: UIViewController {
    
    let composition = AVMutableComposition()
    let videoComposition = AVMutableVideoComposition()
    let instruction = AVMutableVideoCompositionInstruction()
    var assetExport: AVAssetExportSession?
    
    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "videoplayback", ofType: "mp4")!)
    
    var videoRect: CGRect = .zero
    var naturalSize: CGSize = .zero
    var frontWidth: CGFloat = 0
    var sideWidth: CGFloat = 0
    
    let playerLayer = AVPlayerLayer()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let progressView = UIProgressView()
    let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        prepare()
        addOverlays()
        export()
    }
    
    func setupViews() {
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.repeatCount = .infinity
        playerLayer.frame = view.bounds
        playerLayer.add(to: view.layer)
        playerLayer.player = AVPlayer(url: url)
        playerLayer.player?.play()
        playerLayer.player?.isMuted = true
        
        blurView.frame = view.bounds
        blurView.add(toSuperview: view)
        
        progressView.frame = CGRect(x: 200, y: view.bounds.midY - 2, width: view.bounds.width - 400, height: 4)
        progressView.add(toSuperview: view)
        
        statusLabel.text = "Exporting Media..."
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 15)
        statusLabel.sizeToFit()
        statusLabel.frame.origin.x = view.bounds.midX - statusLabel.bounds.width/2
        statusLabel.frame.origin.y = progressView.frame.minY - statusLabel.bounds.height - 20
        statusLabel.add(toSuperview: view)
    }
    
    func prepare() {
        let asset = AVAsset(url: url)
        
        let blurTrack = composition.addVideoTrack(id: 1)
        blurTrack.insertFirstVideoTrack(from: asset)
        
        let track = composition.addVideoTrack(id: 2)
        track.insertFirstVideoTrack(from: asset)
        
        let audioTrack = composition.addAudioTrack(id: 3)
        audioTrack.insertFirstAudioTrack(from: asset)
        
        naturalSize = composition.naturalSize
        videoRect = CGRect(origin: .zero, size: naturalSize)
        frontWidth = naturalSize.height * 9/16
        sideWidth = ((naturalSize.width - frontWidth)/2).rounded()
        
        let blurInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: blurTrack)
        let blurTransform: CGAffineTransform = {
            let scale = CGAffineTransform(scaleX: 2, y: 2)
            let translate = CGAffineTransform(translationX: -naturalSize.width/2, y: -naturalSize.height/2)
            return scale.concatenating(translate)
        }()
        blurInstruction.setTransform(blurTransform, at: .zero)
        
        let foregroundInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        foregroundInstruction.setCropRectangle(CGRect(
            x: sideWidth,
            y: 0,
            width: naturalSize.width - sideWidth * 2,
            height: naturalSize.height
        ), at: .zero)
        
        instruction.timeRange = asset.totalRange
        instruction.layerInstructions = [foregroundInstruction, blurInstruction]
        
        videoComposition.instructions = [instruction]
        videoComposition.renderSize = composition.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    }
    
    func addOverlays() {
        
        let parentLayer = CALayer()
        parentLayer.frame = videoRect
        
        let videoLayer = CALayer()
        videoLayer.frame = videoRect
        videoLayer.add(to: parentLayer)
        
        let blurViewLeft = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurViewLeft.frame = CGRect(x: 0, y: 0, width: sideWidth, height: composition.naturalSize.height)
        blurViewLeft.layer.add(to: parentLayer)
        
        for subview in blurViewLeft.subviews {
            subview.frame = CGRect(x: 0, y: 0, width: sideWidth, height: composition.naturalSize.height)
            subview.layer.add(to: parentLayer)
        }
        
        let blurViewRight = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurViewRight.frame = CGRect(x: composition.naturalSize.width - sideWidth, y: 0, width: sideWidth, height: composition.naturalSize.height)
        blurViewRight.layer.add(to: parentLayer)
        
        for subview in blurViewRight.subviews {
            subview.frame = CGRect(x: composition.naturalSize.width - sideWidth, y: 0, width: sideWidth, height: composition.naturalSize.height)
            subview.layer.add(to: parentLayer)
        }
        
        let leftGradientView = GradientView(colors: [.clear, UIColor.black.withAlphaComponent(0.25)], direction: .horizontal)
        leftGradientView.frame = CGRect(x: 0, y: 0, width: sideWidth, height: composition.naturalSize.height)
        leftGradientView.locations = [0.8, 1]
        leftGradientView.layer.add(to: parentLayer)
        
        let rightGradientView = GradientView(colors: [UIColor.black.withAlphaComponent(0.25), .clear], direction: .horizontal)
        rightGradientView.locations = [0, 0.2]
        rightGradientView.frame = CGRect(x: composition.naturalSize.width - sideWidth, y: 0, width: sideWidth, height: composition.naturalSize.height)
        rightGradientView.layer.add(to: parentLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let animator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
            blurViewLeft.effect = nil
            blurViewRight.effect = nil
        }
        animator.fractionComplete = 0.1
    }
    
    func export() {
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportURL = documents.appendingPathComponent("\(Date.timeIntervalSinceReferenceDate)_tmp.mp4")
        
        assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        assetExport?.outputFileType = AVFileTypeQuickTimeMovie
        assetExport?.outputURL = exportURL
        assetExport?.videoComposition = videoComposition
        assetExport?.exportAsynchronously { [weak self] in
            if case .completed? = self?.assetExport?.status {
                print("Saved to: \(exportURL.absoluteString)")
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
                }) { [weak self] bool, error in
                    print("Completion: \(bool), \(error)")
                    DispatchQueue.main.async {
                        self?.playVideo(at: exportURL)
                    }
                }
            }
        }
        
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] timer in
            let progress = self?.assetExport?.progress ?? 0
            self?.progressView.progress = progress
            if progress >= 1.0 {
                timer.invalidate()
            }
        }
        RunLoop.main.add(timer, forMode: .commonModes)
    }

    func playVideo(at url: URL) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: [], animations: {
            self.statusLabel.text = "Export Successul!"
            self.statusLabel.transform = CGAffineTransform(translationX: 0, y: 20 + self.statusLabel.frame.height/2)
            self.progressView.alpha = 0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                print("Play")
                self?.playerLayer.player = AVPlayer(url: url)
                self?.playerLayer.player?.play()
                self?.playerLayer.player?.isMuted = false
                
                UIView.animate(withDuration: 0.5) {
                    self?.blurView.effect = nil
                    self?.progressView.alpha = 0
                    self?.statusLabel.alpha = 0
                }
            }
        }
    }
}

