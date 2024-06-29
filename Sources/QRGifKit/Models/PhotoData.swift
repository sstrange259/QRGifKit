//
//  PhotoData.swift
//  
//
//  Created by Steven Strange on 6/29/24.
//

import SwiftUI
import UIKit
import PhotosUI

// A class to handle loading and storing image data
public class PhotoData: NSObject, ObservableObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // The selected UIImage
    @Published public var image: UIImage?
    
    // The binary data representation of the image
    @Published public var imageData: Data?
    
    // Initialize with optional existing image
    public init(image: UIImage? = nil) {
        if let image = image {
            self.image = image
            self.imageData = image.pngData()
        }
    }
    
    // Function to present image picker and allow user to select an image
    public func selectImage(from viewController: UIViewController) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        viewController.present(picker, animated: true, completion: nil)
    }
    
    // Function to load the selected image
    public func loadImage(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            self.image = selectedImage
            self.imageData = selectedImage.pngData()
        }
    }
    
    // Function to convert the UIImage to binary data
    public func convertImageToBinary() {
        guard let image = self.image else {
            return
        }
        self.imageData = image.pngData()
    }
    
    // Function to convert binary data back to UIImage
    public func convertBinaryToImage() {
        guard let imageData = self.imageData else {
            return
        }
        self.image = UIImage(data: imageData)
    }
    
    // UIImagePickerControllerDelegate method
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        loadImage(picker: picker, didFinishPickingMediaWithInfo: info)
    }
    
    // UIImagePickerControllerDelegate method
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
