//
//  QRScannerView.swift
//  
//
//  Created by Steven Strange on 6/29/24.
//

import SwiftUI
import AVFoundation

// A SwiftUI view to scan QR codes using the device camera
public struct QRScannerView: UIViewControllerRepresentable {
    public class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerView
        var detectedQRCodes: [String] = []
        var captureSession: AVCaptureSession?
        var videoPreviewLayer: AVCaptureVideoPreviewLayer?
        
        init(parent: QRScannerView) {
            self.parent = parent
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            for metadataObject in metadataObjects {
                if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                    if let stringValue = readableObject.stringValue {
                        detectedQRCodes.append(stringValue)
                    }
                }
            }
            
            if detectedQRCodes.count >= 30 { // Arbitrary number to decide when to process the captured QR codes
                parent.completion(detectedQRCodes)
                parent.isScanning = false
            }
        }
    }
    
    @Binding var isScanning: Bool
    var completion: ([String]) -> Void
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        if isScanning {
            startScanning(in: viewController.view, context: context)
        }
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isScanning {
            startScanning(in: uiViewController.view, context: context)
        } else {
            stopScanning(context: context)
        }
    }
    
    private func startScanning(in view: UIView, context: Context) {
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
        
        context.coordinator.captureSession = captureSession
        context.coordinator.videoPreviewLayer = videoPreviewLayer
    }
    
    private func stopScanning(context: Context) {
        context.coordinator.captureSession?.stopRunning()
        context.coordinator.captureSession = nil
        context.coordinator.videoPreviewLayer?.removeFromSuperlayer()
        context.coordinator.videoPreviewLayer = nil
    }
}
