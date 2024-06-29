//
//  BinaryConverter.swift
//  
//
//  Created by Steven Strange on 6/29/24.
//

import UIKit

// A class to convert image data to binary and vice versa
public class BinaryConverter {
    
    // Function to convert UIImage to binary data
    public static func convertImageToBinary(_ image: UIImage) -> Data? {
        return image.pngData()
    }
    
    // Function to convert binary data back to UIImage
    public static func convertBinaryToImage(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    // Function to split binary data into chunks
    public static func splitBinaryData(_ data: Data, chunkSize: Int) -> [Data] {
        var chunks: [Data] = []
        let totalSize = data.count
        var offset = 0
        
        while offset < totalSize {
            let chunk = data.subdata(in: offset..<min(offset + chunkSize, totalSize))
            chunks.append(chunk)
            offset += chunkSize
        }
        
        return chunks
    }
    
    // Function to merge chunks of binary data back into a single Data object
    public static func mergeBinaryData(chunks: [Data]) -> Data {
        var mergedData = Data()
        for chunk in chunks {
            mergedData.append(chunk)
        }
        return mergedData
    }
}
