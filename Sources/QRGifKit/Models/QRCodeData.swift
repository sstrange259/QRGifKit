//
//  QRCodeData.swift
//  
//
//  Created by Steven Strange on 6/29/24.
//

import Foundation
import CoreImage.CIFilterBuiltins

// A class to manage QR code data
public class QRCodeData: ObservableObject {
    
    // Array to store QR code sequences
    @Published public var qrCodes: [CIImage] = []
    
    // Function to add a QR code to the sequence
    public func addQRCode(_ qrCode: CIImage) {
        qrCodes.append(qrCode)
    }
    
    // Function to retrieve a QR code from the sequence
    public func getQRCode(at index: Int) -> CIImage? {
        guard index >= 0 && index < qrCodes.count else {
            return nil
        }
        return qrCodes[index]
    }
    
    // Function to clear all QR codes from the sequence
    public func clearQRCodes() {
        qrCodes.removeAll()
    }
    
    // Function to convert binary data to a QR code
    public func generateQRCode(from data: Data) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        if let qrCodeImage = filter.outputImage {
            return qrCodeImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        }
        return nil
    }
    
    // Function to decode a QR code back to binary data
    public func decodeQRCode(_ qrCode: CIImage) -> Data? {
        let context = CIContext()
        guard let cgImage = context.createCGImage(qrCode, from: qrCode.extent) else {
            return nil
        }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: CIImage(cgImage: cgImage))
        for feature in features as! [CIQRCodeFeature] {
            if let decodedMessage = feature.messageString, let data = decodedMessage.data(using: .utf8) {
                return data
            }
        }
        return nil
    }
}

