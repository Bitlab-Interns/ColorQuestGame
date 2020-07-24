//
//  SignupLoginViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/19/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import PMSuperButton
import Firebase

class SignupLoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var enterButton: PMSuperButton!
    @IBOutlet weak var boxImage: UIImageView!
    
    var index : Int = 0
        var ref: DatabaseReference!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setAll()
            
            ref = Database.database().reference()

            
            enterButton.touchUpInside {
    //            self.enterButton.titleLabel!.text = " "
                self.enterButton.showLoader()
                self.enterButton.setTitle("", for: .normal)
                
                
                
                
                if (self.username.text?.isEmpty ?? true) {
                                print("jeff")
                //                self.switchButton(self.switchOutlet)
                                print("THERE IS AN ERROR")
                                let alert = UIAlertController(title: "Input Error", message: "Please make sure you have completed filled out every textfield", preferredStyle: .alert)
                                
                                let OK = UIAlertAction(title: "OK", style: .default) { (alert) in
                                    self.enterButton.hideLoader()
                                    self.enterButton.setTitle("Join", for: .normal)
                                    return
                                }
                                
                                alert.addAction(OK)
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                    self.performSegue(withIdentifier: "toHome", sender: self)
                    
                    self.ref.child("Players").child(String(self.username.text!)).updateChildValues(["username" : self.username.text!])
                        
                                }
                                
                            
                
                
                
                
                
            }
            // Do any additional setup after loading the view.
        }
        
        func setAll() {
            boxImage.layer.shadowColor = UIColor.black.cgColor
            boxImage.layer.shadowOffset = CGSize(width: 0, height: 0)
            boxImage.layer.shadowOpacity = 0.5
            boxImage.layer.shadowRadius = 5
            boxImage.clipsToBounds = false
            titleLabel.layer.shadowColor = UIColor.black.cgColor
            titleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
            titleLabel.layer.shadowOpacity = 0.5
            titleLabel.layer.shadowRadius = 5
            titleLabel.clipsToBounds = false
            enterButton.layer.shadowColor = UIColor.black.cgColor
            enterButton.layer.shadowOffset = CGSize(width: 0, height: 0)
            enterButton.layer.shadowOpacity = 0.5
            enterButton.layer.shadowRadius = 5
            enterButton.clipsToBounds = false
//            enterButton.layer.cornerRadius = 0
            
        }
         
    
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "toHome") {
                let secondVC = segue.destination as! HomeViewController
                secondVC.username = username.text!
                
            }
        }

        /*
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

    }
