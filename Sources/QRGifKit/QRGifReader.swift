//
//  QRGifReader.swift
//
//  Created by Steven Strange on 6/29/24.
//

import UIKit
import AVFoundation
import CoreImage

// A class to read and decode QR code GIFs
public class QRGifReader: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    // Properties for capturing QR codes
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var detectedQRCodes: [CIImage] = []
    private var completion: ((UIImage?) -> Void)?
    
    // Function to start capturing QR codes using the device camera
    public func startCapturing(in view: UIView, completion: @escaping (UIImage?) -> Void) {
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
    
    // Function to stop capturing QR codes
    public func stopCapturing() {
        captureSession.stopRunning()
        captureSession = nil
        videoPreviewLayer.removeFromSuperlayer()
    }
    
    // Delegate function to handle captured metadata objects (QR codes)
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                if let stringValue = readableObject.stringValue {
                    if let data = stringValue.data(using: .utf8), let qrCodeImage = generateQRCode(from: data) {
                        detectedQRCodes.append(qrCodeImage)
                    }
                }
            }
        }
        
        if detectedQRCodes.count >= 30 { // Arbitrary number to decide when to process the captured QR codes
            stopCapturing()
            decodeQRCodes(qrCodes: detectedQRCodes, completion: completion)
        }
    }
    
    // Helper function to generate a QR code from binary data
    private func generateQRCode(from data: Data) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        if let qrCodeImage = filter.outputImage {
            return qrCodeImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        }
        return nil
    }
    
    // Helper function to decode QR codes and reconstruct the binary data
    private func decodeQRCodes(qrCodes: [CIImage], completion: ((UIImage?) -> Void)?) {
        var binaryDataChunks: [Data] = []
        
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        for qrCode in qrCodes {
            if let cgImage = context.createCGImage(qrCode, from: qrCode.extent) {
                let ciImage = CIImage(cgImage: cgImage)
                if let features = detector?.features(in: ciImage) as? [CIQRCodeFeature] {
                    for feature in features {
                        if let decodedMessage = feature.messageString, let data = decodedMessage.data(using: .utf8) {
                            binaryDataChunks.append(data)
                        }
                    }
                }
            }
        }
        
        let binaryData = BinaryConverter.mergeBinaryData(chunks: binaryDataChunks)
        let reconstructedImage = BinaryConverter.convertBinaryToImage(binaryData)
        completion?(reconstructedImage)
    }
}
