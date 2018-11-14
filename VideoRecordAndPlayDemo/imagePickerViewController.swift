//
//  imagePickerViewController.swift
//  VideoRecordAndPlayDemo
//
//  Created by Minewtech on 2018/10/24.
//  Copyright © 2018 Minewtech. All rights reserved.
//

import UIKit
import CoreServices

class imagePickerViewController: UIImagePickerController, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isVideoRecordingAvailable() {
            return
        }
        
        self.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        
        
        // Do any additional setup after loading the view.
    }
    
    func isVideoRecordingAvailable() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera)
            if (availableMediaTypes?.contains(kUTTypeMovie as String))! {
                return true
            }
            
        }
        return false
    }
    
    func switchCameraIsFront(front : Bool) -> Void {
        if front {
            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.front) {
                self.cameraDevice = UIImagePickerController.CameraDevice.front
            }
            else{
                if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear) {
                    self.cameraDevice = UIImagePickerController.CameraDevice.rear
                }
            }
        }
    }

}
