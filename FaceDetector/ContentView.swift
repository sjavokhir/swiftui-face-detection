//
//  ContentView.swift
//  Shared
//
//  Created by Tobias Wissmüller on 11.01.22.
//

import SwiftUI
import Vision

struct ContentView: View {
    
    @EnvironmentObject var faceDetector: FaceDetector
    @EnvironmentObject var captureSession: CaptureSession
    
    @State var allPoints = [CGPoint]()
    
    var body: some View {
        ZStack {
            cameraView()
            VStack {
                qualityView()
                Spacer()
            }
            VStack {
                Spacer()
                positionView()
            }
        }.onChange(of: faceDetector.landmarks) { landmarks in
            guard let allPoints = landmarks?.allPoints else {
                return
            }
            self.allPoints = allPoints.normalizedPoints
        }
    }
    
    @ViewBuilder
    func cameraView() -> some View {
        if let captureSession = captureSession.captureSession {
            CameraView(captureSession: captureSession)
                .overlay(
                    GeometryReader { geometry in
                        
                        let path = VNImageRectForNormalizedRect(faceDetector.boundingBox, Int(geometry.size.width), Int(geometry.size.height))
                        
                        Rectangle()
                            .path(in: path)
                            .stroke(Color.red, lineWidth: 2.0)
                        
                        
                        ForEach(allPoints, id: \.self) { point in
                            let vectoredPoint = vector2(Float(point.x),Float(point.y))
                            
                            let vnImagePoint = VNImagePointForFaceLandmarkPoint(
                                vectoredPoint,
                                faceDetector.boundingBox,
                                Int(geometry.size.width),
                                Int(geometry.size.height))
                            
                            let imagePoint = CGPoint(x: vnImagePoint.x, y: vnImagePoint.y)
                            
                            Circle().fill(Color.green).frame(width: 3, height: 3).position(imagePoint)
                        }
                    })
        } else {
            Text("Preparing Capture Session ...")
        }
    }
    
    @ViewBuilder
    func qualityView() -> some View {
        HStack {
            Text(String(format: "Face Capture Quality: %.2f", faceDetector.faceCaptureQuality))
            Spacer()
        }.padding().background(Color.gray)
    }
    
    @ViewBuilder
    func positionView() -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
            ],
            alignment: .leading,
            spacing: 0,
            pinnedViews: [],
            content: {
                Text(String(format: "Pitch: %.2f", faceDetector.pitch))
                Text(String(format: "Roll: %.2f", faceDetector.roll))
                Text(String(format: "Yaw: %.2f", faceDetector.yaw))
            }).padding().background(Color.gray)
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}
