# ASWaveformPlayerView

[![CI Status](http://img.shields.io/travis/alexey-savchenko/ASWaveformPlayerView.svg?style=flat)](https://travis-ci.org/alexey-savchenko/ASWaveformPlayerView)
[![Version](https://img.shields.io/cocoapods/v/ASWaveformPlayerView.svg?style=flat)](http://cocoapods.org/pods/ASWaveformPlayerView)
[![License](https://img.shields.io/cocoapods/l/ASWaveformPlayerView.svg?style=flat)](http://cocoapods.org/pods/ASWaveformPlayerView)
[![Platform](https://img.shields.io/cocoapods/p/ASWaveformPlayerView.svg?style=flat)](http://cocoapods.org/pods/ASWaveformPlayerView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
Swift 4+
## Installation

ASWaveformPlayerView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ASWaveformPlayerView'
```

## Description


<p align="center">
<img src="https://i.imgur.com/4N46rjHl.png" alt="ASWaveformPlayerView"/>
</p>

A UIView subclass that displays waveform of a provided local audio file.

This view has 2 gesture recognizers attached:
1) `UITapGestureRecognizer` - Play - Pause associated with a view audio file.
2) `UIPanGestureRecognizer` - Seek audio file to specified position.

There are 3 public properties:

* `normalColor` - default color of waveform, fills section of waveform that is yet to be played.
* `progressColor` - already played section of waveform fills with this color.
* `allowSpacing` - inserts little spacing between bars in waveform.

## Usage

Since waveform initialization may fail due to invalid URL or ureadable file you should wrap initialization code in `try - catch` block.
Example:

```swift
import UIKit
import ASWaveformPlayerView

class ViewController: UIViewController {

  let audioURL = Bundle.main.url(forResource: "testAudio", withExtension: "mp3")!

  override func viewDidLoad() {
  super.viewDidLoad()

    do {

      let waveform = try ASWaveformPlayerView(audioURL: audioURL, // URL to local a audio file
                                              sampleCount: 1024, // higher numbers make waveform more detailed
                                              amplificationFactor: 500) // constant that affects height of each 'bar' in waveform

      waveform.normalColor = .lightGray
      waveform.progressColor = .orange
      //with high sampleCount passed to init method to avoid artifacts set this to false
      waveform.allowSpacing = false

      view.addSubview(waveform)

      //ASWaveformPlayerView supports both manual and AutoLayout
      waveform.translatesAutoresizingMaskIntoConstraints = false

      let safeArea = view.safeAreaLayoutGuide

      NSLayoutConstraint.activate([waveform.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                                   waveform.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
                                   waveform.heightAnchor.constraint(equalToConstant: 128),
                                   waveform.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                                   waveform.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)])

    } catch {
      //handle error thrown
      print(error.localizedDescription)
    }
  }
}
```

## Author

Alexey Savchenko, alexey.savchenko.home@gmail.com

## License

ASWaveformPlayerView is available under the MIT license. See the LICENSE file for more info.

