//
//  AudioAnalyser.swift
//  CheckMyTrack
//
//  Created by Alexey Savchenko on 22.05.17.
//  Copyright © 2017 Alexey Savchenko. All rights reserved.
//

import Foundation
import AVFoundation
import Accelerate

public class AudioAnalyzer {
  
  public func analyzeAudioFile(url: URL) throws -> [Float] {
    
    //Read File into AVAudioFile
    let file = try AVAudioFile(forReading: url)
    
    //Format of the file
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                               sampleRate: file.fileFormat.sampleRate,
                               channels: file.fileFormat.channelCount,
                               interleaved: false)
    
    //Buffer
    let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: UInt32(file.length))
    
    //Read Floats
    try file.read(into: pcmBuffer!)
    
    //Store raw float data
    let rawFloatData = Array(UnsafeBufferPointer(start: pcmBuffer?.floatChannelData?[0],
                                                 count: Int(pcmBuffer!.frameLength)))
    
    //Init processing buffer
    var resultVector = [Float](repeating: 0.0, count: rawFloatData.count)
    
    //Perform abs function on all values in rawFloatData
    vDSP_vabs(rawFloatData,
              1,
              &resultVector,
              1,
              vDSP_Length(rawFloatData.count))
    
    return resultVector
    
  }
  
  public func amplify(_ inputArray: [Float], by amplificationFactor: Float) -> [Float] {
    
    let amplificationVector = [Float](repeating: amplificationFactor, count: inputArray.count)
    
    var resultVector = [Float](repeating: 0.0, count: inputArray.count)
    
    vDSP_vmul(inputArray,
              1,
              amplificationVector,
              1,
              &resultVector,
              1,
              vDSP_Length(inputArray.count))
    
    return resultVector
    
  }
  
  public func resample(_ inputArray: [Float], to targetSize: Int) -> [Float] {
    
    let stride = vDSP_Stride(inputArray.count / targetSize)
    
    let filterVector = [Float](repeating: 0.002, count: stride)
    
    var resultVector = [Float](repeating:0.0, count: targetSize)
    
    vDSP_desamp(inputArray,
                stride,
                filterVector,
                &resultVector,
                vDSP_Length(resultVector.count),
                vDSP_Length(filterVector.count))
    
    return resultVector
    
  }
  
}
