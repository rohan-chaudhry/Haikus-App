//
//  ImageSaver.swift
//  Haikus
//
//  Created by Rohan Chaudhry on 10/13/24.
//

import UIKit

class ImageSaver: NSObject{
    func writeToPhotoAlbum(image: UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted (_ image: UIImage,didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        print("Image has been saved onto phone!")
    }
}
