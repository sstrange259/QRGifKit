//
//  QRCodeGenerator.swift
//
//
//  Created by Steven Strange on 6/29/24.
//

import UIKit
import CoreImage.CIFilterBuiltins

// A class to generate QR codes from binary data
public class QRCodeGenerator {
    
    // Function to generate a QR code from binary data
    public static func generateQRCode(from data: Data) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        if let qrCodeImage = filter.outputImage {
            return qrCodeImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        }
        return nil
    }
    
    // Function to ensure QR codes are properly formatted for scanning
    public static func generateQRCode(from data: Data, withCorrectionLevel correctionLevel: String = "M") -> CIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        if let qrCodeImage = filter.outputImage {
            return qrCodeImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        }
        
        return nil
    }
}
