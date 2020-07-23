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
    @IBOutlet weak var switchLoginReg: UISegmentedControl!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
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
                
                
                
                if (self.switchLoginReg.selectedSegmentIndex == 0) {
                if (self.password.text?.isEmpty ?? true || self.username.text?.isEmpty ?? true) {
                                print("jeff")
                //                self.switchButton(self.switchOutlet)
                                print("THERE IS AN ERROR")
                                let alert = UIAlertController(title: "Registration Error", message: "Please make sure you have completed filled out every textfield", preferredStyle: .alert)
                                
                                let OK = UIAlertAction(title: "OK", style: .default) { (alert) in
                                    self.enterButton.hideLoader()
                                    self.enterButton.setTitle("Join", for: .normal)
                                    return
                                }
                                
                                alert.addAction(OK)
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                    
                                Auth.auth().createUser(withEmail: self.username.text!, password: self.password.text!) { (user, error) in
                                    if (error == nil) {
                                        self.ref.child("Players").child(Auth.auth().currentUser!.uid).setValue(["username" : self.username.text])
                                        
                                        
    //                                    self.performSegue(withIdentifier: "toUserHome", sender: self)
                                        
                                        //                                                self.performSegue(withIdentifier: "UserToLogin", sender: self)
                                                            self.performSegue(withIdentifier: "toHome", sender: self)
                                    } else {
                                        //                    SVProgressHUD.dismiss()
                                        let alert = UIAlertController(title: "Registration Error", message: error?.localizedDescription as! String, preferredStyle: .alert)
                                        
                                        let OK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                                            self.password.text = ""
                                            self.enterButton.hideLoader()
                                            self.enterButton.setTitle("Join", for: .normal)
                                        })
                                        
                                        alert.addAction(OK)
                                        self.present(alert, animated: true, completion: nil)
                                        print("--------------------------------")
                                        print("Error: \(error?.localizedDescription)")
                                        print("--------------------------------")
                                    }
                                }
                                
                                
                            }
                }
                else {
                    Auth.auth().signIn(withEmail: self.username.text!, password: self.password.text!) { (user, error) in
                        if (error == nil) {
                            
    //                        self.ref.child("UserInfo").child(Auth.auth().currentUser!.uid).child("Information").observeSingleEvent(of: .value, with: { (snapshot) in
    //
    //                            guard let value = snapshot.value as? NSDictionary else {
    //                                print("No Data!!!")
    //                                return
    //                            }
    //                            let status = value["Status"] as! String
    //
    //
    //                            print (status)
    //                            if (status == "User") {
                                    self.performSegue(withIdentifier: "toHome", sender: self)
    //                            }
    //                            else {
    //                                self.performSegue(withIdentifier: "toCompanyHome", sender: self)
    //                            }
    //
    //
    //                        }) { (error) in
    //                            print("error:\(error.localizedDescription)")
    //                        }
                            //
                            
                        } else {
                            
                            
                            let alert = UIAlertController(title: "Login Error", message: "Incorrect username or password", preferredStyle: .alert)
                            let forgotPassword = UIAlertAction(title: "Forgot Password?", style: .default, handler: { (UIAlertAction) in
                                //do the forgot password shit
                            })
                            
                            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
                                //do nothing
                                self.enterButton.hideLoader()
                                //            var state: UIControl.State = UIControl.State()
                                self.enterButton.setTitle("Login", for: .normal)
                            })
                            
                            alert.addAction(forgotPassword)
                            alert.addAction(cancel)
                            self.present(alert, animated: true, completion: nil)
                            print("error with logging in: ", error!)
                            self.enterButton.hideLoader()
                            self.enterButton.hideLoader()
                            self.enterButton.setTitle("Join", for: .normal)
                        }
                        self.enterButton.hideLoader()
                        //            var state: UIControl.State = UIControl.State()
                        self.enterButton.setTitle("Join", for: .normal)
                    }
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
            enterButton.layer.cornerRadius = 8
        }
         
        @IBAction func switchOther(_ sender: Any) {
        }

        /*
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

    }
