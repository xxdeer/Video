//
//  ViewController.swift
//  VideoRecordAndPlayDemo
//
//  Created by Minewtech on 2018/10/24.
//  Copyright © 2018 Minewtech. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
//import ReplayKit

@available(iOS 11.1, *)
class ViewController: UIViewController,AVCaptureFileOutputRecordingDelegate {
    
    var fileOutput : AVCaptureMovieFileOutput?
    var captureSession : AVCaptureSession?
    var catureConnection : AVCaptureConnection?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brown
        
        let btn = UIButton.init(type: UIButton.ButtonType.custom)
        btn.setTitle("click", for: UIControl.State.normal)
        btn.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
        btn.addTarget(self, action: #selector(click), for: UIControl.Event.touchUpInside)
        self.view.addSubview(btn)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func initCapture() -> Void {
        captureSession = AVCaptureSession.init()
        if captureSession!.canSetSessionPreset(AVCaptureSession.Preset.hd1920x1080) {
            captureSession!.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        }
        //video
        let videoCaptureDevice : AVCaptureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInDualCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.back)!
        
        do {
            let videoInput = try AVCaptureDeviceInput.init(device: videoCaptureDevice)
            if captureSession!.canAddInput(videoInput) {
                captureSession!.addInput(videoInput)
            }
        } catch {
            print(error)
        }
        //audio
        let audioCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        do {
            let audioInput = try AVCaptureDeviceInput.init(device: audioCaptureDevice!)
            if captureSession!.canAddInput(audioInput) {
                captureSession!.addInput(audioInput)
            }
        } catch {
            print(error)
        }
        
        fileOutput = AVCaptureMovieFileOutput.init()
        catureConnection = fileOutput!.connection(with: AVMediaType.video)
        if (catureConnection?.isVideoStabilizationSupported)! {
            catureConnection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
        }

        if captureSession!.canAddOutput(fileOutput!) {
            captureSession!.addOutput(fileOutput!)
        }
    }
    
    func writeDataTofile() -> Void {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyHHmmss"
        let movieName = formatter.string(from: currentDateTime)+".mov"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent(movieName)
        
        print(soundURL)
        
        fileOutput?.startRecording(to: soundURL, recordingDelegate: self)
    }
    
    @objc func click() -> Void {
//        let viewC = imagePickerViewController()
//        viewC.sourceType = UIImagePickerController.SourceType.camera
//        viewC.mediaTypes = [kUTTypeMovie] as [String]
//
//        viewC.showsCameraControls = true
//        viewC.switchCameraIsFront(front: false)
//        viewC.cameraCaptureMode = UIImagePickerController.CameraCaptureMode.video
//        viewC.cameraFlashMode = UIImagePickerController.CameraFlashMode.auto
//        viewC.videoQuality = UIImagePickerController.QualityType.typeIFrame1280x720
//
//        viewC.videoMaximumDuration = 30
//        self.present(viewC, animated: true, completion: nil)
        
        let vc = AVCaptureViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print(error as Any)
        }
        else
        {
            self.writeDataTofile()
            captureSession?.stopRunning()
        }
    }
    
    @objc func startvideo() -> Void {
        self.initCapture()
        captureSession!.startRunning()
    }

}

