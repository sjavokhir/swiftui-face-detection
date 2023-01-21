//
//  FaceDetector.swift
//  BiometricPhoto
//
//  Created by Tobias Wissmüller on 11.01.22.
//

import Foundation
import Vision
import UIKit
import Combine
import AVFoundation

class FaceDetector: NSObject, ObservableObject {
    
    @Published var faceCaptureQuality: Float = 0.0
    
    @Published var boundingBox = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    
    @Published var landmarks: VNFaceLandmarks2D?
    
    @Published var yaw: Float = 0
    @Published var roll: Float = 0
    @Published var pitch: Float = 0
    
    private var sampleBuffer: CMSampleBuffer?
    
    let subject = PassthroughSubject<CMSampleBuffer?, Never>()
    var cancellables = [AnyCancellable]()
    
    override init() {
        super.init()
        subject.sink { sampleBuffer in
            self.sampleBuffer = sampleBuffer
            do {
                guard let sampleBuffer = sampleBuffer else {
                    return
                }
                try self.detect(sampleBuffer: sampleBuffer)
            } catch {
                print("Error has been thrown")
            }
            
        }.store(in: &cancellables)
    }
    
    
    func detect(sampleBuffer: CMSampleBuffer) throws {
        let handler = VNSequenceRequestHandler()
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest.init(completionHandler: handleRequests)
        faceLandmarksRequest.revision = VNDetectFaceLandmarksRequestRevision3
        
        let faceCaptureQualityRequest = VNDetectFaceCaptureQualityRequest.init(completionHandler: handleRequests)
        
        let faceRectanglesRequest = VNDetectFaceRectanglesRequest.init(completionHandler: handleRequests)
        faceLandmarksRequest.revision = VNDetectFaceRectanglesRequestRevision3
        
        DispatchQueue.global().async {
            do {
                try handler.perform([faceLandmarksRequest, faceCaptureQualityRequest, faceRectanglesRequest], on: sampleBuffer, orientation: .left)
            } catch {
                // don't do anything
            }
        }
        
    }
    
    func handleRequests(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard
                let results = request.results as? [VNFaceObservation],
                let result = results.first else { return }
            
            self.boundingBox = result.boundingBox
            
            if let yaw = result.yaw,
               let pitch = result.pitch,
               let roll = result.roll {
                self.yaw = yaw.floatValue
                self.pitch = pitch.floatValue
                self.roll = roll.floatValue
            }
            
            if let landmarks = result.landmarks {
                self.landmarks = landmarks
            }
            
            if let captureQuality = result.faceCaptureQuality {
                self.faceCaptureQuality = captureQuality
            }
        }
    }
}
