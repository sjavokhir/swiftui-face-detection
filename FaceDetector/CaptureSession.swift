//
//  CaptureSession.swift
//  BiometricPhoto
//
//  Created by Tobias Wissmüller on 12.01.22.
//

import Foundation
import AVFoundation

class CaptureSession: NSObject, ObservableObject {
    @Published var sampleBuffer: CMSampleBuffer?
    
    var captureSession: AVCaptureSession?
    
    func setup() {
        var allowedAccess = false
        let blocker = DispatchGroup()
        blocker.enter()
        AVCaptureDevice.requestAccess(for: .video) { flag in
            allowedAccess = flag
            blocker.leave()
        }
        blocker.wait()
        if !allowedAccess { return }
        
        if !allowedAccess {
            print("Camera access is not allowed.")
            return
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
        guard videoDevice != nil, let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), session.canAddInput(videoDeviceInput) else {
            print("Unable to detect camera.")
            return
        }
        session.addInput(videoDeviceInput)
        session.commitConfiguration()
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "SampleBuffer"))
        if (session.canAddOutput(videoOutput)) {
            session.addOutput(videoOutput)
        }
        
        self.captureSession = session
    }
    
    func start() {
        guard let captureSession = self.captureSession else {
            return
        }
        
        if (!captureSession.isRunning) {
            captureSession.startRunning()
        }
    }
    
    func stop() {
        guard let captureSession = self.captureSession else {
            return
        }
        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }
}

extension CaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.sampleBuffer = sampleBuffer
        }
    }
}


