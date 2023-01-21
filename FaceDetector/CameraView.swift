//
//  CameraView.swift
//  BiometricPhoto
//
//  Created by Tobias Wissmüller on 12.01.22.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

struct CameraView: UIViewRepresentable {
    typealias UIViewType = PreviewView
    
    var captureSession: AVCaptureSession
    
    func makeUIView(context: Context) -> UIViewType {
        return UIViewType(captureSession: captureSession)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

class PreviewView: UIView {
    private var captureSession: AVCaptureSession
    
    init(captureSession: AVCaptureSession) {
        self.captureSession = captureSession
        super.init(frame: .zero)
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let previewLayer = self.videoPreviewLayer
        
        previewLayer.frame = self.bounds
        
        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.from(deviceOrientation)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if nil != self.superview {
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspect
        }
    }
}
