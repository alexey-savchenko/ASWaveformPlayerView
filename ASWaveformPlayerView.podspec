#
# Be sure to run `pod lib lint ASWaveformPlayerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ASWaveformPlayerView'
  s.version          = '0.1.2'
  s.summary          = 'Audio waveform view with playback functionality.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC

A UIView subclass that displays waveform of a provided local audio file.

This view has 2 gesture recognizers attached:
1) UITapGestureRecognizer - Play - Pause associated with a view audio file.
2) UIPanGestureRecognizer - Seek audio file to specified position.

There are 3 public properties:

normalColor - default color of waveform, displays on section of waveform that is yet to be played.
progressColor - already played section of waveform fills with this color.
allowSpacing - inserts little spacing between bars in waveform.

                       DESC

  s.homepage         = 'https://github.com/alexey-savchenko/ASWaveformPlayerView'
  s.screenshots     = 'https://i.imgur.com/GAKHlxq.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'alexey-savchenko' => 'alexey.savchenko.home@gmail.com' }
  s.source           = { :git => 'https://github.com/alexey-savchenko/ASWaveformPlayerView.git',
                         :branch => "master",
                         :tag => s.version.to_s }

  s.social_media_url = 'https://twitter.com/Alex_Svch'

  s.ios.deployment_target = '11.0'

  s.source_files = 'ASWaveformPlayerView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ASWaveformPlayerView' => ['ASWaveformPlayerView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation', 'Accelerate', 'AVFoundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
