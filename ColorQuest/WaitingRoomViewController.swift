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
    @IBOutlet weak var playersLabel: UILabel!
    var ref: DatabaseReference!
    var isLeader = false
    var username : String = ""
    var gameID : String = ""
    var numOfPlayers : Int = 0
    var rounds : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        playersLabel.text = "Number of Players: 0"
        
        startButton.isHidden = true
        
        ref = Database.database().reference()
        
        ref.child("Games/\(gameID)/Participants").observe(.childAdded) { (snapshot) in

            let value = snapshot.value as? NSDictionary
            
            self.numOfPlayers += 1
            self.playersLabel.text = "Players Joined: \(self.numOfPlayers)"

            // do segue to game view controller
            
            
        }
        
//        ref.child("Games/\(gameID)/Participants/\(username)").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
//            let value = snapshot.value as? NSDictionary
//            self.isLeader = value?["isLeader"] as! Bool
            if isLeader {
                startButton.isHidden = false
            }

//            }) { (error) in
//            print(error.localizedDescription)
//        }
        
        
        
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
        ref.child("Games/\(gameID)/fChanged").updateChildValues(["LeaderFinished": false])
        ref.child("Games/\(gameID)/bChanged").updateChildValues(["LeaderFinished": false])
//        self.ref.child("Games/\(self.gameID)/sChanged").updateChildValues(["change": false])
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toGame") {
            print("TO GAME")
            let secondVC = segue.destination as! gameScreenViewController
            secondVC.username = username
            secondVC.gameID = gameID
            secondVC.isLeader = isLeader
            secondVC.rounds = rounds
            
        }
    }
    

}
