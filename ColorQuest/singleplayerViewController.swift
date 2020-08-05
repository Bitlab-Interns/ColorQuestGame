


import UIKit
import AVFoundation

class singleplayerViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    

    @IBOutlet weak var startTimer: UILabel!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var croppedImage: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var boxImage: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var goalColorImageView: UIImageView!
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
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
    var maxRounds = 5
    let scoreManager = ScoreManager()
    var guessColor: UIColor!
    var currRound = 1
    let totalTime = 10
    lazy var count = totalTime
    var submission: UIImage!
    var totalScore = 0
    var currScore = 0 // score earned in a round
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchMode1()
        
        var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameScreenViewController.update), userInfo: nil, repeats: true)
        
        let color = scoreManager.generatergb()
        let r = CGFloat(Double(color.0) / 255.0)
        let g = CGFloat(Double(color.1) / 255.0)
        let b = CGFloat(Double(color.2) / 255.0)
        guessColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        goalColorImageView.backgroundColor = guessColor
        
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
                moveToNextRound(currScore)

            }
        }
        
        func imageIsNullOrNot(imageName : UIImage)-> Bool {
            let size = CGSize(width: 0, height: 0)
            if (imageName.size.width == size.width) {
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
        }

        @IBAction func submitPhoto(_ sender: UIButton) {

            let color = submission.averageColor! // average color of user's submission
            let tempColor = guessColor.components
            currScore = scoreManager.similarity(Float(color.0), Float(color.1), Float(color.2), Float(tempColor.0), Float(tempColor.1), Float(tempColor.2)) // calculate score of user's submission
            currScore = currScore + 5 * (count)
            // display confirmation msg, disable submit button
            maxRounds = maxRounds - 1
            if maxRounds == 0 {
                // display leaderboard
            } else {
                moveToNextRound(currScore)
            }
        }

        // update ui
        func moveToNextRound(_ lastScore: Int) { // lastScore = score earned in previous round
            totalScore = totalScore + lastScore
            currScore = 0
            scoreLabel.text = String(totalScore)
            currRound += 1
            roundLabel.text = "Round \(currRound)"
            count = totalTime
            let color = scoreManager.generatergb()
            let r = CGFloat(Double(color.0) / 255.0)
            let g = CGFloat(Double(color.1) / 255.0)
            let b = CGFloat(Double(color.2) / 255.0)
            guessColor = UIColor(red: r, green: g, blue: b, alpha: 1)
            goalColorImageView.backgroundColor = guessColor
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
/*
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

    
}
*/
