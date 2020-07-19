//
//  gameScreenViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/14/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

//TODO disable submit button when no picture is taken

import UIKit
import AVFoundation

class gameScreenViewController: UIViewController {
    
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var croppedImage: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var boxImage: UIImageView!
    var captureSession = AVCaptureSession()
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    
    var image: UIImage?
    
    var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    
    var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
    
    @IBOutlet weak var goalColorImageView: UIImageView!
    
    let scoreManager = ScoreManager()
    var guessColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0);
    var currRound = 1
    let totalTime = 30
//    lazy var count = totalTime
//    var submission: UIImage
    var totalScore = 0
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchMode1()
        
//        var timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(gameScreenViewController.update), userInfo: nil, repeats: true)
        
        let color = scoreManager.generatergb()
        let r = CGFloat(Double(color.0) / 255.0)
        let g = CGFloat(Double(color.1) / 255.0)
        let b = CGFloat(Double(color.2) / 255.0)
        let tempColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        guessColor = tempColor
        goalColorImageView.backgroundColor = tempColor
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        
        toggleCameraGestureRecognizer.direction = .up
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(self.switchCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        // Zoom In recognizer
        zoomInGestureRecognizer.direction = .right
        zoomInGestureRecognizer.addTarget(self, action: #selector(zoomIn))
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // Zoom Out recognizer
        zoomOutGestureRecognizer.direction = .left
        zoomOutGestureRecognizer.addTarget(self, action: #selector(zoomOut))
        view.addGestureRecognizer(zoomOutGestureRecognizer)
        styleCaptureButton()
    }
//
//    @objc func update() {
//        if(count > 0) {
//            count = count - 1
//            timeLabel.text = String(count)
//        } else if count == 0 {
//            if submission != nil { // this always returns true
//                let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1) // average color
//                var currScore = scoreManager.similarity(r1, g1, b1, r2, g2, b2)
//                moveToNextRound(currScore)
//            } else {
//                moveToNextRound(0)
//            }
//
//        }
//    }
    
    
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentDevice = backCamera
    }
    
    func setupInputOutput() {
        do {
            
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
            
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = view.frame
        
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    
    @objc func switchCamera() {
        captureSession.beginConfiguration()
        
        // Change the device based on the current camera
        let newDevice = (currentDevice?.position == AVCaptureDevice.Position.back) ? frontCamera : backCamera
        
        // Remove all inputs from the session
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // Change to the new input
        let cameraInput:AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    @objc func zoomIn() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor < 5.0 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @objc func zoomOut() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor > 1.0 {
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.ramp(toVideoZoomFactor: newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Preview_Segue" {
            let previewViewController = segue.destination as! cameraViewController
            previewViewController.image = self.image
        }
    }
    
    func cropImage(_ image: UIImage, _ portionOfImage: Double) {
        
        let cgimage: CGImage = image.cgImage!
        var dimensions = 0
        if cgimage.height > cgimage.width {
            dimensions = (Int)(Double(cgimage.width) * portionOfImage)
        } else {
            dimensions = (Int)(Double(cgimage.height) * portionOfImage)
        }
        dimensions = 890
        let croppedImageVar = cgimage.cropping(to: CGRect(x: 2400, y: cgimage.height / 2 - dimensions / 2 - 100, width: dimensions, height: dimensions))
        croppedImage.image = UIImage(cgImage: croppedImageVar!)
        
    }
    @IBAction func retakePressed(_ sender: Any) {
        switchMode1()
    }
    
    func switchMode1() {
        retakeButton.isHidden = true
        gameImage.isHidden = true
        croppedImage.isHidden = true
        boxImage.isHidden = false
        cameraButton.isHidden = false
        
    }
    
    func switchMode2(){
        retakeButton.isHidden = false
        gameImage.isHidden = false
        croppedImage.isHidden = false
        boxImage.isHidden = true
        cameraButton.isHidden = true
    }
//
//    @IBAction func submitPhoto(_ sender: UIButton) {
//
//        let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1) // average color
//        var currScore = scoreManager.similarity(r1, g1, b1, r2, g2, b2)
//        currScore = currScore + 5 * (totalTime - count)
//        if (count == 0) { // display confirmation msg
//            moveToNextRound(currScore)
//        }
//    }
//
//    // update ui
//    func moveToNextRound(_ lastScore: Int) { // lastScore = score earned in previous round
//        totalScore = totalScore + lastScore
//        scoreLabel.text = String(totalScore)
//        currRound += 1
//        roundLabel.text = "Round \(currRound)"
//    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension gameScreenViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            self.image = UIImage(data: imageData)
//            submission = UIImage(data: imageData)!
//            performSegue(withIdentifier: "Preview_Segue", sender: nil)
            cropImage(image!, 0.5)
            croppedImage.image = croppedImage.image?.rotate(radians: 1.57)
            switchMode2()
        }
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
