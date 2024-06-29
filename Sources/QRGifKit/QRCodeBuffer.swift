//
//  QRCodeBuffer.swift
//  
//
//  Created by Steven Strange on 6/29/24.
//

import Foundation
import CoreImage

// A class to buffer and manage QR codes during processing
public class QRCodeBuffer {
    
    // Array to store buffered QR codes
    private var buffer: [CIImage] = []
    
    // Maximum buffer size to prevent memory overflow
    private let maxBufferSize: Int
    
    // Initialize with a specified maximum buffer size
    public init(maxBufferSize: Int = 100) {
        self.maxBufferSize = maxBufferSize
    }
    
    // Function to add a QR code to the buffer
    public func addQRCode(_ qrCode: CIImage) {
        if buffer.count >= maxBufferSize {
            buffer.removeFirst()  // Remove the oldest QR code to make room
        }
        buffer.append(qrCode)
    }
    
    // Function to retrieve a QR code from the buffer by index
    public func getQRCode(at index: Int) -> CIImage? {
        guard index >= 0 && index < buffer.count else {
            return nil
        }
        return buffer[index]
    }
    
    // Function to clear all QR codes from the buffer
    public func clearBuffer() {
        buffer.removeAll()
    }
    
    // Function to get the current buffer size
    public func getBufferSize() -> Int {
        return buffer.count
    }
    
    // Function to get all QR codes in the buffer
    public func getAllQRCodes() -> [CIImage] {
        return buffer
    }
}
