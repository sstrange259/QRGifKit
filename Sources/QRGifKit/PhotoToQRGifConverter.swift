//
//  PhotoToQRGifConverter.swift
//
//
//  Created by Steven Strange on 6/29/24.
//

import UIKit
import CoreImage.CIFilterBuiltins
import ImageIO
import MobileCoreServices

// A class to handle the conversion process from a photo to a QR code GIF
public class PhotoToQRGifConverter {
    
    // Function to convert a photo to a QR code GIF
    public static func convertPhotoToQRGif(photo: UIImage, chunkSize: Int, frameRate: Int) -> URL? {
        guard let binaryData = BinaryConverter.convertImageToBinary(photo) else {
            return nil
        }
        
        let dataChunks = BinaryConverter.splitBinaryData(binaryData, chunkSize: chunkSize)
        
        var qrCodeImages: [CIImage] = []
        for chunk in dataChunks {
            if let qrCodeImage = generateQRCode(from: chunk) {
                qrCodeImages.append(qrCodeImage)
            }
        }
        
        return createGif(from: qrCodeImages, frameRate: frameRate)
    }
    
    // Helper function to generate a QR code from binary data
    private static func generateQRCode(from data: Data) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        if let qrCodeImage = filter.outputImage {
            return qrCodeImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        }
        return nil
    }
    
    // Helper function to create a GIF from an array of CIImage QR codes
    private static func createGif(from images: [CIImage], frameRate: Int) -> URL? {
        let fileProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ]
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: 1.0 / Double(frameRate)
            ]
        ]
        
        let documentsDirectory = FileManager.default.temporaryDirectory
        let gifURL = documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("gif")
        
        guard let destination = CGImageDestinationCreateWithURL(gifURL as CFURL, kUTTypeGIF, images.count, nil) else {
            return nil
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        let context = CIContext()
        for image in images {
            if let cgImage = context.createCGImage(image, from: image.extent) {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        if CGImageDestinationFinalize(destination) {
            return gifURL
        } else {
            return nil
        }
    }
}

