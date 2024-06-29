//
//  QRScanner.swift
//
//
//  Created by Steven Strange on 6/29/24.
//

import UIKit
import AVFoundation
import CoreImage

// A class to scan QR codes using the device camera
public class QRScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    // Properties for capturing QR codes
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var detectedQRCodes: [String] = []
    private var completion: (([String]) -> Void)?
    
    // Function to start scanning QR codes using the device camera
    public func startScanning(in view: UIView, completion: @escaping ([String]) -> Void) {
        self.completion = completion
        
        captureSession = AVCaptureSession()
        
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
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
    }
    
    // Function to stop scanning QR codes
    public func stopScanning() {
        captureSession.stopRunning()
        captureSession = nil
        videoPreviewLayer.removeFromSuperlayer()
    }
    
    // Delegate function to handle captured metadata objects (QR codes)
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                if let stringValue = readableObject.stringValue {
                    detectedQRCodes.append(stringValue)
                }
            }
        }
        
        if detectedQRCodes.count >= 30 { // Arbitrary number to decide when to process the captured QR codes
            stopScanning()
            completion?(detectedQRCodes)
        }
    }
}
