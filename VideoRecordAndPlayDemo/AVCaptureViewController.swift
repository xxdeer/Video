//
//  AVCaptureViewController.swift
//  VideoRecordAndPlayDemo
//
//  Created by Minewtech on 2018/10/25.
//  Copyright © 2018 Minewtech. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

@available(iOS 11.1, *)
class AVCaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var backCameraInput : AVCaptureDeviceInput?
    var frontCameraInput : AVCaptureDeviceInput?
    var audioMicInput : AVCaptureDeviceInput?
    var videoConnection : AVCaptureConnection?
    var captureMovieFileOutput : AVCaptureMovieFileOutput?
    
    var timeLabel : UILabel!
    var timeStr : TimeInterval!
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !self.isAvailableWithCamera() {
            print("请开启相机权限")
            return
        }
        if !self.isAvailableWithMic() {
            print("请开启麦克风权限")
            return
        }
        self.initbackCameraInput()
        self.initfrontCameraInput()
        self.initCaptureMovieFileOutput()
        self.initMicInput()
        self.initVideoConnection()
        self.initcaptureSession()
        self.initpreviewLayer()
        
        let endBtn = UIButton.init(type: UIButton.ButtonType.custom)
        endBtn.backgroundColor = UIColor.red
        endBtn.addTarget(self, action: #selector(self.startOrStopCapture(sender:)), for: UIControl.Event.touchUpInside)
        endBtn.frame = CGRect.init(x: (self.view.frame.width-100)/2, y: self.view.frame.height-200, width: 100, height: 100)
        self.view.addSubview(endBtn)
        
        timeLabel = UILabel.init()
        timeLabel.backgroundColor = UIColor.brown
        timeLabel.text = "0:00"
        timeLabel.textAlignment = .center
        timeLabel.frame = CGRect.init(x: (self.view.frame.width-100)/2, y: self.view.frame.height-250, width: 100, height: 40)
        self.view.addSubview(timeLabel)
        
        
        
        // Do any additional setup after loading the view.
    }
    //MARK: - init
    func initcaptureSession() -> Void {
        if captureSession == nil {
            captureSession = AVCaptureSession.init()

            if (captureSession?.canSetSessionPreset(.hd1920x1080))! {
                captureSession?.sessionPreset = .hd1920x1080
            }
            let videoDevice = AVCaptureDevice.default(for: .video)
            var deviceInput : AVCaptureDeviceInput!
            do {
                deviceInput = try AVCaptureDeviceInput.init(device: videoDevice!)
            }
            catch {
                print(error)
            }
            
            captureSession?.beginConfiguration()
            if (captureSession?.canAddInput(deviceInput))! {
                captureSession?.addInput(deviceInput)
            }
            
//            if (captureSession?.canAddInput(backCameraInput!))! {
//                captureSession?.addInput(backCameraInput!)
//            }
            if (captureSession?.canAddInput(audioMicInput!))! {
                captureSession?.addInput(audioMicInput!)
            }
            if (captureSession?.canAddOutput(captureMovieFileOutput!))! {
                captureSession?.addOutput(captureMovieFileOutput!)
            }
            captureSession?.commitConfiguration()
//            self.videoConnection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }
    }
    
    func initpreviewLayer() -> Void {
        if captureSession == nil {
            return
        }
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession!)
            previewLayer?.frame = self.view.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer!)
            self.startRecord()
        }
    }
    
    func initbackCameraInput() -> Void {
        if backCameraInput == nil {
            let backDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
            do {
                backCameraInput = try AVCaptureDeviceInput.init(device: backDevice!)
            }
            catch {
                
            }
        }
    }
    func initfrontCameraInput() -> Void {
        if frontCameraInput == nil {
            
            let frontDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            do {
                frontCameraInput = try AVCaptureDeviceInput.init(device: frontDevice!)
            }
            catch {
                
            }
        }
    }
    func initMicInput() -> Void {
        if audioMicInput == nil {
            let audioCaptureDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            do {
                audioMicInput = try AVCaptureDeviceInput.init(device: audioCaptureDevice!)
            } catch {
                print(error)
            }
        }
    }
    func initVideoConnection() -> Void {
        if videoConnection == nil {
            videoConnection = AVCaptureConnection.init()
        }
    }
    func initCaptureMovieFileOutput() -> Void {
        if captureMovieFileOutput == nil {
            captureMovieFileOutput = AVCaptureMovieFileOutput.init()
        }
    }

    //MARK: - 权限判断
    func isAvailableWithCamera() -> Bool {
        return self.isAvailableWithDeviceMediatype(type: AVMediaType.video)
    }
    func isAvailableWithMic() -> Bool {
        return self.isAvailableWithDeviceMediatype(type: .audio)
    }
    func isAvailableWithDeviceMediatype(type:AVMediaType) -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied {
            return false
        }
        
        return true
    }
    //MARK: - 路径
    func getVideoPath() -> String {
        let videoCache = NSTemporaryDirectory().appending("videos/")
        
        let fileManager = FileManager.default
        let isExist = fileManager.fileExists(atPath: videoCache)
        if !isExist {
            do{
                try fileManager.createDirectory(atPath: videoCache, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                print(error)
            }
            
        }
        return videoCache
    }
    
    func getVideoNameWithType(fileType:String) -> String {
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let recordingName = formatter.string(from: nowDate)+".caf"
        
        print("\(recordingName),\(nowDate)")
        let timeStr = formatter.string(from: nowDate)
        let fileName = "video_\(timeStr)\(fileType)"
        
        return fileName
    }
    
    //MARK: - 启动录制
    func startRecord() -> Void {
        captureSession?.startRunning()
    }
    //MARK: - 关闭session
    func stopRecord() -> Void {
        if captureSession != nil {
            captureSession?.stopRunning()
        }
    }
    //MARK: - 开始录制
    func startCapture() -> Void {
        print("begain")
        
        let date = Date()
        timeStr = date.timeIntervalSince1970
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFunction), userInfo: nil, repeats: true)
        
        if (captureMovieFileOutput?.isRecording)! {
            return
        }
        let defultPath = self.getVideoPath()
        let outputFilePath = "file://"+defultPath+self.getVideoNameWithType(fileType: ".mp4")
        print(outputFilePath)
        
        let fileUrl = URL.init(string: outputFilePath)
        captureMovieFileOutput?.startRecording(to: fileUrl!, recordingDelegate: self as AVCaptureFileOutputRecordingDelegate)
    }
    //MARK: - 停止录制
    func stopCapture() -> Void {
        if (captureMovieFileOutput?.isRecording)! {
            captureMovieFileOutput?.stopRecording()
        }
        self.stopRecord()
    }
    
    @objc func startOrStopCapture(sender:UIButton) -> Void {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.startCapture()
        }
        else{
            self.stopCapture()
        }
    }
    
    @objc func timerFunction() -> Void {
        let date = Date()
        let timeNow = date.timeIntervalSince1970
        let time = Int(timeNow - timeStr)
        timeLabel.text = String.init(time)
    }
    
    //MARK: - delegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("结束录制")
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { (success, error) in
            if (error != nil) {
                print("保存失败,错误信息为:\(String(describing: error?.localizedDescription))")
            }
            else
            {
                print("成功保存")
                self.stopRecord()
                self.startRecord()
                self.timer?.invalidate()
                self.timer = nil
                DispatchQueue.main.async {
                    self.timeLabel.text = "0:00"
                }
            }
        }
    }
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始录制")
    }
}
