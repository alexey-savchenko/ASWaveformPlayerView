//
//  ViewController.swift
//  ASWaveformPlayerView
//
//  Created by alexey-savchenko on 01/04/2018.
//  Copyright (c) 2018 alexey-savchenko. All rights reserved.
//

import UIKit
import ASWaveformPlayerView

class ViewController: UIViewController {
  
  let audioURL = Bundle.main.url(forResource: "testAudio", withExtension: "mp3")!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      
      let waveform = try ASWaveformPlayerView(audioURL: audioURL,
                                              sampleCount: 1024,
                                              amplificationFactor: 500)
      
      waveform.normalColor = .lightGray
      waveform.progressColor = .orange
      waveform.allowSpacing = false
      
      view.addSubview(waveform)
      
      waveform.translatesAutoresizingMaskIntoConstraints = false
      
      let safeArea = view.safeAreaLayoutGuide
      
      NSLayoutConstraint.activate([waveform.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                                   waveform.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
                                   waveform.heightAnchor.constraint(equalToConstant: 128),
                                   waveform.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                                   waveform.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)])
      
    } catch {
      print(error.localizedDescription)
    }
    
  }
  
}

