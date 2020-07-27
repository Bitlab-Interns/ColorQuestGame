//
//  gameScreenViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/14/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

//TODO disable submit button when no picture is taken
// disable submit button after submission and display confirmation msg("congrats you submitted, you earned x points, waiting for other players to finish"
// reset photo after submission
// score resets after round ends
// leaderboard storyboard
// display between each round and at the end of the game
// make a home page with two buttons, one for multiplayer and one for single player
// make lobby page that shows players with start button
// delete game lobby after game


import UIKit
import AVFoundation
import Firebase

class gameScreenViewController: UIViewController {
    
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
    
    
    var maxRounds = 3
    let scoreManager = ScoreManager()
    var guessColor: UIColor!
    var currRound = 1
    let totalTime = 10
    lazy var count = totalTime
    var submission: UIImage? = nil
    var totalScore = 0
    var currScore = 0 // score earned in a round
    var isLeader = false
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    var username : String = ""
    
    var gameID : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retakePressed(self)
        
        ref = Database.database().reference()
        
        print("INSTIDE GAME SCREEN")
        
        ref.child("Games/\(gameID)/Participants/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.isLeader = value?["isLeader"] as! Bool
            
            print("ISLEADER:\(self.isLeader)")
            
            if self.isLeader {
                let color = self.scoreManager.generatergb()
                let r = Float(Double(color.0) / 255.0)
                let g = Float(Double(color.1) / 255.0)
                let b = Float(Double(color.2) / 255.0)
                

                
                self.ref.child("Games/\(self.gameID)/rgb").updateChildValues([ "r" : r, "g": g, "b" : b ])
//
//
//                self.guessColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
//                print("GS: \(self.guessColor)" )
//                self.goalColorImageView.backgroundColor = self.guessColor
                
                
                var tempTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameScreenViewController.tempUpdate), userInfo: nil, repeats: true)
                
                
            }
            else {
                
                
//                self.ref.child("Games/\(self.gameID)/lChanged").updateChildValues(["LeaderFinished": true])
            }
            
            
            
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        
        
        
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
        
        
        ref.child("Games/\(gameID)/lChanged").observe(.childChanged) { (snapshot) in
            
            print("YOTE")
            self.ref.child("Games/\(self.gameID)/rgb").observeSingleEvent(of: .value, with: { (snapshot2) in
                // Get user value

                let value2 = snapshot2.value as? NSDictionary
                let r = value2?["r"] as! CGFloat
                let g = value2?["g"] as! CGFloat
                let b = value2?["b"] as! CGFloat
                self.guessColor = UIColor(red: r, green: g, blue: b, alpha: 1)
                print("GS: \(self.guessColor)" )
                self.goalColorImageView.backgroundColor = self.guessColor
                
            }) { (error2) in
                print(error2.localizedDescription)
            }
        }
        var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameScreenViewController.update), userInfo: nil, repeats: true)

    }
    
    @objc func update() {
        if(count > 0) {
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
            moveToNextRound()
            
        }
    }
    
    @objc func tempUpdate() {
        if(startCounter > 0) {
            startCounter = startCounter - 1
            startTimer.text = String(startCounter)
        } else if startCounter == 0 {
            //            if !imageIsNullOrNot(imageName: submission) {
            //                let color = submission.averageColor! // average color of user's submission
            //                let tempColor = guessColor.components
            //                var currScore = scoreManager.similarity(Float(color.0), Float(color.1), Float(color.2), Float(tempColor.0), Float(tempColor.1), Float(tempColor.2)) // calculate score of user's submission
            //                moveToNextRound(currScore)
            //            } else {
            //                moveToNextRound(0)
            //            }
            
                            self.ref.child("Games/\(self.gameID)/lChanged").updateChildValues(["LeaderFinished": true])
            
            
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
            let alert = UIAlertController(title: "Submission Successful", message: "Please wait until the end of the round", preferredStyle: UIAlertController.Style.alert)
            //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTimeInterval.seconds(count)
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
            currScore = currScore + 5 * (count)
        }
        
        // display confirmation msg, disable submit button
        totalScore = totalScore + currScore
        // upload totalScore
        //extract every other player score
        // send as parameters into moveToLeaderboard func
        ref.child("Games/\(gameID)/Participants/\(username)").updateChildValues(["score":totalScore])
        // might have to add delay here to wait for everyone to update score
        //        ref.child("Games/\(gameID)/Participants/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
        //            // Get user value
        //            let value = snapshot.value as? NSDictionary
        //            let score = value?["score"] as! String
        //
        //            // ...
        //            }) { (error) in
        //                print(error.localizedDessdfcription)
        //        }
        
        if currRound == maxRounds {
            
            // display leaderboard
            let alert = UIAlertController(title: "Game Over!", message: "Total Score: \(totalScore)", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            // move to leaderboard
            currScore = 0
            scoreLabel.text = String(totalScore)
            currRound += 1
            roundLabel.text = "Round: \(currRound)"
            count = totalTime
            if isLeader {
                let newColor = scoreManager.generatergb()
                let r = CGFloat(Double(newColor.0) / 255.0)
                let g = CGFloat(Double(newColor.1) / 255.0)
                let b = CGFloat(Double(newColor.2) / 255.0)
                ref.child("Games/\(gameID)").updateChildValues(["guessColor":(r, g, b)])
            }
            ref.child("Games/\(gameID)").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let tempTuple = value?["guessColor"] as! (CGFloat, CGFloat, CGFloat)
                self.guessColor = UIColor(red: tempTuple.0, green: tempTuple.1, blue: tempTuple.2, alpha: 1)
                
            }) { (error) in
                print(error.localizedDescription)
            }
            goalColorImageView.backgroundColor = guessColor
            submission = nil
        }
    }
    
    func moveToLeaderboard() {
        
        // extract all player scores from firebase
        // create dictionary and sort it by scores
        // return array
        // show scores
        // 5 second delay
        
        
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
extension gameScreenViewController: AVCapturePhotoCaptureDelegate {
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

extension UIImage {
    var averageColor: (CGFloat, CGFloat, CGFloat, CGFloat)? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return (CGFloat(bitmap[0]), CGFloat(bitmap[1]), CGFloat(bitmap[2]), CGFloat(bitmap[3]))
    }
    
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red * 255, coreImageColor.green * 255, coreImageColor.blue * 255, coreImageColor.alpha * 255)
    }
}

