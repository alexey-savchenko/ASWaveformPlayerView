//
//  WaveFormView.swift
//  WaveformPlayer
//
//  Created by iosUser on 03.01.2018.
//  Copyright © 2018 svch. All rights reserved.
//

import UIKit
import AVFoundation

public class ASWaveformPlayerView: UIView {
  
  //MARK: Public properties
  public var normalColor = UIColor.lightGray
  
  public var progressColor = UIColor.orange
  
  public var allowSpacing = true
  
  
  
  //MARK: Private properties
  private var playerToken: Any?
  
  private var audioPlayer: AVPlayer!
  
  private var audioAnalyzer = AudioAnalyzer()
  
  private var waveformDataArray = [Float]()
  
  private var waveforms = [CALayer]()
  
  private var currentPlaybackTime: CMTime?
  
  private var shouldAutoUpdateWaveform = true
  
  
  
  //MARK: Initialization
  public init(audioURL: URL,
       sampleCount: Int,
       amplificationFactor: Float) throws {
    
    guard sampleCount > 0 else {
      throw WaveFormViewInitError.incorrectSampleCount
    }
    
    // Get raw data from URL
    let rawWaveformDataArray = try audioAnalyzer.analyzeAudioFile(url: audioURL)
    // Resample it
    let resampledDataArray = audioAnalyzer.resample(rawWaveformDataArray, to: sampleCount)
    // And amplify
    waveformDataArray = audioAnalyzer.amplify(resampledDataArray, by: amplificationFactor)
    
    audioPlayer = AVPlayer(url: audioURL)
    
    super.init(frame: .zero)
    
    playerToken = audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 60),
                                                      queue: .main) { [weak self] (time) in
                                                        
                                                        // Update waveform with current playback time value.
                                                        self?.updatePlotWith(time)
    }
    
    // Tap gesture for play - pause support.
    let tapGestureRecornizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    tapGestureRecornizer.numberOfTouchesRequired = 1
    tapGestureRecornizer.cancelsTouchesInView = false
    self.addGestureRecognizer(tapGestureRecornizer)
    
    // Pan gesture for scrubbing support.
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    panGestureRecognizer.cancelsTouchesInView = false
    self.addGestureRecognizer(panGestureRecognizer)
    
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  deinit {
    audioPlayer.removeTimeObserver(playerToken!)
    playerToken = nil
    print("\(self) dealloc")
  }
  
  
  
  //MARK: Methods
  override public func layoutSubviews() {
    super.layoutSubviews()
    populateWithData()
    addOverlay()
    
    if audioPlayer.rate == 0 && currentPlaybackTime != nil {
      // When orientation changes, update plot with currentPlaybackTime value.
      updatePlotWith(currentPlaybackTime!)
    }
    
  }
  


  @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
    
    switch recognizer.state {
      
    case .began:
      
      shouldAutoUpdateWaveform = false
      
    case .changed:
      let xLocation = Float(recognizer.location(in: self).x)
      
      //Update waveform with translation value
      updatePlotWith(xLocation)
      
    case .ended:
      
      if let totalAudioDuration = audioPlayer.currentItem?.asset.duration {
        
        let xLocation = recognizer.location(in: self).x
        
        let percentageInSelf = Double(xLocation / bounds.width)
        
        let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
        
        let scrubbedDutation = totalAudioDurationSeconds * percentageInSelf
        
        let scrubbedDutationMediaTime = CMTimeMakeWithSeconds(scrubbedDutation, 1000)
        
        audioPlayer.seek(to: scrubbedDutationMediaTime, completionHandler: { [weak self] (_) in
          self?.shouldAutoUpdateWaveform = true
        })
        
      }

    default:
      break
    }
    
  }
  
  @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
    if audioPlayer.rate == 0 {
      audioPlayer.play()
    } else {
      audioPlayer.pause()
    }
  }
  
  private func populateWithData() {
    clear()
    
    let barWidth: CGFloat
    
    if allowSpacing {
      barWidth = bounds.width / CGFloat(waveformDataArray.count) - 0.5
    } else {
      barWidth = bounds.width / CGFloat(waveformDataArray.count)
    }
    
    //Make initial offset equal to half width of bar.
    var offset: CGFloat = (bounds.width / CGFloat(waveformDataArray.count)) / 2
    //Iterate through waveformDataArray to calculate size and positions of waveform bars.
    for value in waveformDataArray {
      
      let waveformBarRect = CGRect(x: offset,
                                   y:   bounds.height / 2,
                                   width: barWidth,
                                   height: -CGFloat(value))
      
      let barLayer = CALayer()
      barLayer.drawsAsynchronously = true
      barLayer.bounds = waveformBarRect
      barLayer.position = CGPoint(x: offset + (bounds.width / CGFloat(waveformDataArray.count)) / 2,
                                  y: bounds.height / 2)
      
      barLayer.backgroundColor = self.normalColor.cgColor
      
      self.layer.addSublayer(barLayer)
      self.waveforms.append(barLayer)
      
      offset += self.frame.width / CGFloat(waveformDataArray.count)
      
    }
    
  }
  
  private func updatePlotWith(_ location: Float) {
    
    let percentageInSelf = location / Float(bounds.width)
    
    let waveformsToBeRecolored = Float(waveforms.count) * percentageInSelf
    
    for (idx, item) in waveforms.enumerated() {
      
      if (0..<lrintf(waveformsToBeRecolored)).contains(idx) {
        item.backgroundColor = progressColor.cgColor
      } else {
        item.backgroundColor = normalColor.cgColor
      }
      
    }
    
  }
  
  private func updatePlotWith(_ currentTime: CMTime) {
    
    guard shouldAutoUpdateWaveform == true else {
      return
    }
    
    if let totalAudioDuration = audioPlayer.currentItem?.asset.duration {
      
      let currentTimeSeconds = CMTimeGetSeconds(currentTime)
      
      self.currentPlaybackTime = currentTime // Track current time value. This is needed to keep waveform playback progress when device orientaion changes and waveform needs to be redrawn.
      
      let totalAudioDurationSeconds = CMTimeGetSeconds(totalAudioDuration)
      
      let percentagePlayed = currentTimeSeconds / totalAudioDurationSeconds
      
      let waveformBarsToBeUpdated = lrint(Double(waveforms.count) * percentagePlayed)
      
      for (idx, item) in waveforms.enumerated() {
        
        if (0..<waveformBarsToBeUpdated).contains(idx) {
          item.backgroundColor = progressColor.cgColor
        } else {
          item.backgroundColor = normalColor.cgColor
        }
        
      }
      
    }
    
  }
  
  private func addOverlay() {
    
    let maskLayer = CALayer()
    maskLayer.frame = bounds
    
    let upperOverlayLayer = CALayer()
    let bottomOverlayLayer = CALayer()
    
    upperOverlayLayer.backgroundColor = UIColor.black.cgColor
    bottomOverlayLayer.backgroundColor = UIColor.black.cgColor
    
    upperOverlayLayer.opacity = 1
    bottomOverlayLayer.opacity = 0.75
    
    maskLayer.addSublayer(upperOverlayLayer)
    maskLayer.addSublayer(bottomOverlayLayer)
    
    upperOverlayLayer.frame = CGRect(origin: .zero,
                                     size: CGSize(width: maskLayer.bounds.width,
                                                  height: (maskLayer.bounds.height / 2) - 0.25))
    
    bottomOverlayLayer.frame = CGRect(origin: CGPoint(x: 0,
                                                      y: (maskLayer.bounds.height / 2) + 0.25),
                                      size: CGSize(width: maskLayer.bounds.width,
                                                   height: maskLayer.bounds.height / 2))
    
    layer.mask = maskLayer
    
  }
  
  /// Reset progress of playback and waveform
  public func reset() {
    waveforms.forEach {
      $0.backgroundColor = normalColor.cgColor
    }
  }
  
  public func clear() {
    layer.sublayers?.forEach {
      $0.removeFromSuperlayer()
    }
    waveforms = []
  }
  
}

enum WaveFormViewInitError: Error {
  case incorrectSampleCount
}
