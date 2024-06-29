// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import CoreImage

// A class to provide the main functionality for the QR Gif Kit
public class QRGifKit {
    
    // Function to convert a photo to a QR code GIF
    public static func createQRGif(from photo: UIImage, chunkSize: Int, frameRate: Int) -> URL? {
        return PhotoToQRGifConverter.convertPhotoToQRGif(photo: photo, chunkSize: chunkSize, frameRate: frameRate)
    }
    
    // Function to read a QR code GIF and reconstruct the original photo
    public static func readQRGif(from gifURL: URL, completion: @escaping (UIImage?) -> Void) {
        guard let gifData = try? Data(contentsOf: gifURL) else {
            completion(nil)
            return
        }
        
        var qrCodes: [CIImage] = []
        
        if let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
            let count = CGImageSourceGetCount(source)
            for index in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                    let ciImage = CIImage(cgImage: cgImage)
                    qrCodes.append(ciImage)
                }
            }
        }
        
        decodeQRCodes(qrCodes: qrCodes, completion: completion)
    }
    
    // Helper function to decode QR codes and reconstruct the binary data
    private static func decodeQRCodes(qrCodes: [CIImage], completion: @escaping (UIImage?) -> Void) {
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
        completion(reconstructedImage)
    }
}
