//
//  HomeViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/22/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import PMSuperButton
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var createButton: PMSuperButton!
    @IBOutlet weak var joinButton: PMSuperButton!
    //    @IBOutlet weak var play: PMSuperButton!
//    @IBOutlet weak var create: PMSuperButton!
//    @IBOutlet weak var join: PMSuperButton!
//    @IBOutlet weak var statistics: PMSuperButton!
    
    
    var textField = UITextField()
    
    var ref: DatabaseReference!
    
    var username : String = ""
    
    var gameID : String = ""
    
    var isLeader : Bool = false
    
    var rounds : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
//        print("username)")
        
        createButton.touchUpInside() {
                        let alert = UIAlertController(title: "Enter code to create class", message: "", preferredStyle: .alert)
                        let doneButton = UIAlertAction(title: "Done", style: .default) { (action) in
                            print(self.textField.text!)
                            self.ref.child("Games").observeSingleEvent(of: .value, with: { (snap) in
                                if (self.textField.text! == "") {
                                    let alert1 = UIAlertController(title: "Error with creating class", message: "", preferredStyle: .alert)
                                    let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
//                                         self.tableView.reloadData()
                                        //does nothing
                                    }
                                    let tryAgain = UIAlertAction(title: "Try again", style: .default) { (try) in
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    alert1.addAction(cancelButton)
                                    alert1.addAction(tryAgain)
                                    self.present(alert1, animated: true, completion: nil)
                                } else if (snap.hasChild(self.textField.text!)) {
                                    let alert1 = UIAlertController(title: "This code already exists", message: "", preferredStyle: .alert)
                                    let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
                                        //does nothing
                                    }
                                    let tryAgain = UIAlertAction(title: "Try again", style: .default) { (try) in
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    alert1.addAction(cancelButton)
                                    alert1.addAction(tryAgain)
                                    self.present(alert1, animated: true, completion: nil)
                                }
                                else {
                                    
                                     self.ref.child("Games/\(self.textField.text!)").updateChildValues(["Rounds": self.rounds])
                                    
//                                    self.ref.child("Games").
                                    self.ref.child("Players").child(self.username).updateChildValues(["CurrentGame" : self.textField.text!])
                                
                                    self.ref.child("Games").child(self.textField.text!).child("Participants").child(String(self.username)).updateChildValues(["username" : self.username, "isLeader" : true, "score": 0])
                                    
                                    
                                    
                                    self.ref.child("Games").child(self.textField.text!).updateChildValues(["ID" : self.textField.text!])
                                    
                                    self.ref.child("Games/\(self.textField.text!)/gsChanged").updateChildValues(["gameStarted": false])
                                    
                                    
                                    self.gameID = self.textField.text!
                                    self.isLeader = true
                                    
                                    self.performSegue(withIdentifier: "toWaiting", sender: self)
                                    
                                    
//                                    self.ref.child("Classrooms").child(self.textField.text!).child("Calendar").updateChildValues([ "monday" : 0, "tuesday" : 0, "wednesday" : 0, "thursday" : 0, "friday" : 0, "numVoted" : 0])
                                    
            //                        self.ref.child("Classrooms").child(self.textField.text!).child("Calendar").child("Friday").updateChildValues(["Friday" : 0])
            //                        self.ref.child("Classrooms").child(self.textField.text!).child("Calendar").child("Thursday").updateChildValues(["Thursday" : 0])
            //                        self.ref.child("Classrooms").child(self.textField.text!).child("Calendar").child("Wednesday").updateChildValues(["Wednesday" : 0])
            //                        self.ref.child("Classrooms").child(self.textField.text!).child("Calendar").child("Tuesday").updateChildValues(["Tuesday" : 0])
            //                        self.ref.child("Classrooms").child(self.textField.text!).child("Calendar").child("Monday").updateChildValues(["Monday" : 0])
                                    
//                             self.ref.child("Classrooms").child(self.textField.text!).child("Messages").updateChildValues(["last_commended id": -1])
                                //update
//                                    self.updateClasses()
                                
                                }
                            })
                            
                            
                            
                        }
                        
                        alert.addAction(doneButton)
                        alert.addTextField { (alertTextField) in
                            alertTextField.placeholder = "Class code"
                            self.textField = alertTextField
                            //                /Users/michaelpeng/Desktop/ClassroomConnections/Pods/PKRevealController/Source/PKRevealController/PKRevealController.m:1363:1: Conflicting return type in implementation of 'supportedInterfaceOrientations': 'UIInterfaceOrientationMask' (aka 'enum UIInterfaceOrientationMask') vs 'NSUInteger' (aka 'unsigned long')
                        }
            alert.addTextField{ (alertTextField1) in
                            alertTextField1.placeholder = "Rounds"
                            alertTextField1.keyboardType = .numberPad
                self.rounds = 	Int(alertTextField1.text!) ?? 10
                        }
                        
                        self.present(alert, animated: true, completion: nil)
        }
        
        joinButton.touchUpInside(){
            let alert = UIAlertController(title: "Enter code to join class", message: "", preferredStyle: .alert)
                             let doneButton = UIAlertAction(title: "Done", style: .default) { (action) in
                                 print(self.textField.text!)
                                 if (self.textField.text! == "") {
                                     let errorAlert = UIAlertController(title: "Invalid Code", message: "The code you entered does not exist", preferredStyle: .alert)
                                     let tryAgain = UIAlertAction(title: "Enter Another Code", style: .default) { (tryAgainAction) in
                                         self.present(alert, animated: true, completion: nil)
                                     }
                                     let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancelAction) in
                                         
                                     }
                                     errorAlert.addAction(tryAgain)
                                     errorAlert.addAction(cancel)
                                     
                                     self.present(errorAlert, animated: true, completion: nil)
                                     return
                                 }
                                 
                                 var index = 1
                                 
                                 self.ref.child("Games").observeSingleEvent(of: .value) { (Data) in
                                     
                                     print("retrieve data: " + String(Data.childrenCount))
                                     
                                     for children in Data.children.allObjects as! [DataSnapshot] {
                                         
                                         
                                         
                                         guard let classroom = children.value as? NSDictionary else {
                                             print("could not collect label data")
                                             return
                                         }
                                         
                                         let identification = classroom["ID"] as! String
                                         
                                         let isEqual = (identification == self.textField.text!)
                                         
                                         if (isEqual) {
                                          
                                          
                                          self.ref.child("Players").child(self.username).updateChildValues(["CurrentGame" : self.textField.text!])
              
                                            print("hello!!")
                                            
                                             
                                             
                                            self.ref.child("Games").child(self.textField.text!).child("Participants").child(String(self.username)).updateChildValues(["username" : self.username, "isLeader" : false, "score": 0])
                                            
                                            
                                            
                                            self.gameID = self.textField.text!
                                            
                                            self.isLeader = false
                                            self.performSegue(withIdentifier: "toWaiting", sender: self)
//                                          self.ref.child("Games").child(self.textField.textyay!).updateChildValues(["ID" : self.textField.text!])
                                             
                                             return
                                         }
                                         else {
                                             if (index == Data.childrenCount) {
                                                 let errorAlert = UIAlertController(title: "Invalid Code", message: "The code you entered does not exist", preferredStyle: .alert)
                                                 let tryAgain = UIAlertAction(title: "Enter Another Code", style: .default) { (tryAgainAction) in
                                                     self.present(alert, animated: true, completion: nil)
                                                 }
                                                 let cancel = UIAlertAction(title: "Cancel", style: .default) { (cancelAction) in
                                                     
                                                 }
                                                 errorAlert.addAction(tryAgain)
                                                 errorAlert.addAction(cancel)
                                                 
                                                 self.present(errorAlert, animated: true, completion: nil)
                                                 return
                                             }
                                             index = index + 1
                                             
                                             
                                         }
                                         

                                         
                                     }
                                     
                                 }
                                 //                sel.classes.append(Class(classTitle: "APCSA", teacher: "Fulk"))
                                 
                                 
                             }
                             
                             let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (action) in
                                 
                             }
                             alert.addAction(doneButton)
                             alert.addAction(cancelButton)
                             alert.addTextField { (alertTextField) in
                                 alertTextField.placeholder = "Class code"
                                 self.textField = alertTextField
                                 //                /Users/michaelpeng/Desktop/ClassroomConnections/Pods/PKRevealController/Source/PKRevealController/PKRevealController.m:1363:1: Conflicting return type in implementation of 'supportedInterfaceOrientations': 'UIInterfaceOrientationMask' (aka 'enum UIInterfaceOrientationMask') vs 'NSUInteger' (aka 'unsigned long')
                             }
                             
                             
                             self.present(alert, animated: true, completion: nil)
        }
        
        
        
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toWaiting") {
            let secondVC = segue.destination as! WaitingRoomViewController
            secondVC.username = username
            secondVC.gameID = gameID
            secondVC.isLeader = isLeader
            secondVC.rounds = rounds
        }
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
