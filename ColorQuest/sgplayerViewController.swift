//
//  sgplayerViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 8/7/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class sgplayerViewController: UIViewController {

        var ref: DatabaseReference!
        //    var username: String!
        var leaderboard: [String: String] = [:]
        
        var startCounter = 5
        
        @IBOutlet weak var startTimer: UILabel!
        @IBOutlet weak var gameImage: UIImageView!
        @IBOutlet weak var cameraButton: UIButton!
        @IBOutlet weak var croppedImage: UIImageView!
        @IBOutlet weak var retakeButton: UIButton!
        @IBOutlet weak var boxImage: UIImageView!
        var captureSession = AVCaptureSession()
    
    var rounds : Int = 0
    @IBOutlet weak var goHome: UIButton!

    @IBAction func homePressed(_ sender: Any) {
        print("---------------------------------")
    }
    
    @IBOutlet weak var submitButton: UIButton!
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
        
        
        var maxRounds = 10
        let scoreManager = ScoreManager()
        var guessColor: UIColor!
        var currRound = 1
        let totalTime = 10
        var count = 10
        var submission: UIImage? = nil
        var totalScore = 0
        var currScore = 0 // score earned in a round
        var isLeader = false
        var rCount = 0
        
        @IBOutlet weak var roundLabel: UILabel!
        @IBOutlet weak var timeLabel: UILabel!
        @IBOutlet weak var scoreLabel: UILabel!
        
        
        var username : String = ""
        
        var gameID : String = ""
        
        var tempTimer : Timer? = nil
        
        var timer : Timer? = nil
        
        var refreshTimer : Timer? = nil
        override func viewDidLoad() {
            super.viewDidLoad()
            goHome.isHidden = true

            
            
            let color = self.scoreManager.generatergb()
            let r = CGFloat(Double(color.0) / 255.0)
            let g = CGFloat(Double(color.1) / 255.0)
            let b = CGFloat(Double(color.2) / 255.0)

            
                            guessColor = UIColor(red: r, green: g, blue: b, alpha: 1)
                            print("GS: \(self.guessColor)" )
                            goalColorImageView.backgroundColor = self.guessColor
            
            retakePressed(self)
            
            ref = Database.database().reference()
            
            print("INSTIDE GAME SCREEN")
            
            //        ref.child("Games/\(gameID)/Participants/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            //            let value = snapshot.value as? NSDictionary
            //            self.isLeader = value?["isLeader"] as! Bool
            
            //            print("ISLEADER:\(self.isLeader)")
            
            
                          timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sgplayerViewController.update), userInfo: nil, repeats: true)
            
            
            
            
            
            //        }) { (error) in
            //            print(error.localizedDescription)
            //        }
            
            
            
            
            
            
            
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
            
            
            
            
    }///////*
        
        @objc func update() {
            if(count > 0) {
                
                print("BET")
                count = count - 1
                timeLabel.text = String(count)
            } else if count == 0 {
                //            if !imageIsNullOrNot(imageName: submission) {
                //                let color = submission.averageColor! // average color of user's submission
                //                let tempColor = guessColor.components
                //                var currScore = scoreManager.similarity(Float(color.0), Float(color.1), Float(color.2), Float(tempColor.0), Float(tempColor.1), Float(tempColor.2)) // calculate score of user's submission
                //                moveToNextRound(currScore)
                //            } else {
                //                moveToNextRound(0)
                //            }
                
                timer!.invalidate()
                
                self.moveToNextRound()
                
                
                
            }
        }
        
        
        
        func imageIsNullOrNot(imageName : UIImage)-> Bool {
            let size = CGSize(width: 0, height: 0)
            if (imageName.size.width > 0) {
                return false
            } else {
                return true
            }
        }
        
        
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
            submitButton.isHidden = true
            
        }
        
        func switchMode2(){
            retakeButton.isHidden = false
            gameImage.isHidden = false
            croppedImage.isHidden = false
            boxImage.isHidden = true
            cameraButton.isHidden = true
            submitButton.isHidden = false
        }
        
        @IBAction func submitPhoto(_ sender: UIButton) {
            
            if (submission == nil) { // if image null
                
                // alert
                let alert = UIAlertController(title: "Submission Unsuccessful", message: "Please take a picture", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                let submissionColor = submission!.averageColor! // average color of user's submission
                let tempColor = guessColor.components
                currScore = scoreManager.similarity(Float(submissionColor.0), Float(submissionColor.1), Float(submissionColor.2), Float(tempColor.0), Float(tempColor.1), Float(tempColor.2)) // calculate score of user's submission
                
                let header = "Submission Successful. You earned "
                let header2 = String(currScore)
                let header3 = " points"
                let header4 = header + header2 + header3
                let alert = UIAlertController(title: header4, message: "Please wait until the end of the round", preferredStyle: UIAlertController.Style.alert)
                //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTimeInterval.seconds(count-1)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + when){
                    // your code with delay
                    alert.dismiss(animated: true, completion: nil)
                }
                
                retakePressed(self)
            }
        }
        
        // update ui
        func moveToNextRound() { // lastScore = score earned in previous round
            
            if (submission == nil) {
                currScore = 0
            } else {
                let submissionColor = submission!.averageColor! // average color of user's submission
                let tempColor = guessColor.components
                currScore = scoreManager.similarity(Float(submissionColor.0), Float(submissionColor.1), Float(submissionColor.2), Float(tempColor.0), Float(tempColor.1), Float(tempColor.2)) // calculate score of user's submission
                
                print("average rgb submission")
                print(Float(submissionColor.0))
                print(Float(submissionColor.1))
                print(Float(submissionColor.2))

                print("score:")
                print(currScore)
                //currScore = currScore + 5 * (count)
            }
            
            // display confirmation msg, disable submit button
            totalScore = totalScore + currScore
            if currRound == maxRounds {
                retakeButton.isHidden = true
                cameraButton.isHidden = true
                submitButton.isHidden = true
                
                retakeButton.isEnabled = false
                cameraButton.isEnabled = false
                submitButton.isEnabled = false
                
                
                // display leaderboard
//                goHome.layer.cornerRadius =  min(cameraButton.frame.width, cameraButton.frame.height)/4
                goHome.isHidden = false
                

                let alert = UIAlertController(title: "Game Over!", message: "Total Score: \(totalScore)", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                
                
                //self.performSegue(withIdentifier: "toHome", sender: self)
                
                
            } else {
                
                // move to leaderboard
                currScore = 0
                scoreLabel.text = String(totalScore)
                currRound += 1
                roundLabel.text = "Round: \(currRound)"
                count = totalTime

                    let color = self.scoreManager.generatergb()
                    let r = CGFloat(Double(color.0) / 255.0)
                    let g = CGFloat(Double(color.1) / 255.0)
                    let b = CGFloat(Double(color.2) / 255.0)

                    
                                    guessColor = UIColor(red: r, green: g, blue: b, alpha: 1)
                                    print("GS: \(self.guessColor)" )
                                    goalColorImageView.backgroundColor = self.guessColor
                                    
                                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sgplayerViewController.update), userInfo: nil, repeats: true)
                                    
                                    
                    
                    
                        
                    
            }
            submission = nil
            retakePressed(self)
        }
        
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
    extension sgplayerViewController: AVCapturePhotoCaptureDelegate {
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let imageData = photo.fileDataRepresentation() {
                self.image = UIImage(data: imageData)
                submission = UIImage(data: imageData)!
                //            performSegue(withIdentifier: "Preview_Segue", sender: nil)
                cropImage(image!, 0.5)
                croppedImage.image = croppedImage.image?.rotate(radians: 1.57)
                switchMode2()
            }
        }
    }
    /*func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toHome") {
            segue.destination as! HomeViewController
            
        }
    }
 */

