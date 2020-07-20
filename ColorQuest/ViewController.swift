
//
//  ViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/12/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var croppedImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cropImage(UIImage(named: "sample")!, 0.5)
    }

    @IBAction func imagePickerPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Pick One", message: "Pick an Option", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else{
                print("hi")
            }
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imagePicked.image = image
        cropImage(image, 0.5)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // cropping
    func cropImage(_ image: UIImage, _ portionOfImage: Double) {
        
        let cgimage: CGImage = image.cgImage!
        var dimensions = 0
        if cgimage.height > cgimage.width {
            dimensions = (Int)(Double(cgimage.width) * portionOfImage)
        } else {
            dimensions = (Int)(Double(cgimage.height) * portionOfImage)
        }
        let croppedImage = cgimage.cropping(to: CGRect(x: cgimage.width / 2 - dimensions / 2, y: cgimage.height / 2 - dimensions / 2, width: dimensions, height: dimensions))
        croppedImageView.image = UIImage(cgImage: croppedImage!)
        
    }
    
}


