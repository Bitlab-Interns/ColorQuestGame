//
//  WaitingRoomViewController.swift
//  ColorQuest
//
//  Created by Liang on 7/26/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class WaitingRoomViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    var ref: DatabaseReference!
    var isLeader = false
    var username : String = ""
    var gameID : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.isHidden = true
        
        ref = Database.database().reference()
        
        ref.child("Games/\(gameID)/Participants/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value as? NSDictionary
            self.isLeader = value?["isLeader"] as! Bool
            if self.isLeader {
                self.startButton.isHidden = false
            }

            }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        ref.child("Games/\(gameID)/gsChanged").observe(.childChanged) { (snapshot) in

            let value = snapshot.value as? NSDictionary
            
                self.performSegue(withIdentifier: "toGame", sender: self)

            // do segue to game view controller
            
            
        }
        
//        commentsRef.observe(.childAdded, with: { (snapshot) -> Void in
//          self.comments.append(snapshot)
//          self.tableView.insertRows(at: [IndexPath(row: self.comments.count-1, section: self.kSectionComments)], with: UITableView.RowAnimation.automatic)
//        })
        
        
    }
    
    @IBAction func startPressed(_ sender: UIButton) {
        
        ref.child("Games/\(gameID)/gsChanged").updateChildValues(["gameStarted": true])
        ref.child("Games/\(gameID)/lChanged").updateChildValues(["LeaderFinished": false])
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toGame") {
            print("TO GAME")
            let secondVC = segue.destination as! gameScreenViewController
            secondVC.username = username
            secondVC.gameID = gameID
            
        }
    }
    

}
