//
//  popUpViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/24/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import PMSuperButton

class popUpViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    var gameID : String = ""
    
    var username : String = ""
    
    var isLeader : Bool = false
    
    var done : Bool = false
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var Roundbutton: PMSuperButton!
    
    var playerList: [playerCell] = [playerCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = Database.database().reference()
        
        
        tableView.register(UINib(nibName: "LeadCell", bundle: nil), forCellReuseIdentifier: "lcell" )
        
        
        retrieveData()
        
        if !(isLeader)  {
            if !done{
                Roundbutton.isHidden = true
            }
            else {
                Roundbutton.setTitle("Return", for: .normal)
            }
            
        }
        else {
            if done{
                Roundbutton.setTitle("Return", for: .normal)
            }
        }
        
        tableView.reloadData()
        
        
        
        
        
        ref.child("Games/\(gameID)/bChanged").observe(.childChanged) { (snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
            
            self.dismiss(animated: true, completion: nil)
            
                }
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func nextRoundPressed(_ sender: Any) {
        
        
        if done {
            self.performSegue(withIdentifier: "backSegue", sender: self)
        }
        else {
        self.ref.child("Games/\(self.gameID)/bChanged").observeSingleEvent(of: .value, with: { (snapshot2) in
            // Get user value
            
            let value2 = snapshot2.value as? NSDictionary
            let t = value2?["LeaderFinished"] as! Bool

            
            self.ref.child("Games/\(self.gameID)/bChanged").updateChildValues(["LeaderFinished": !t])
            
            
            
        }) { (error2) in
            print(error2.localizedDescription)
        }
        }
        
//        dismiss(animated: true, completion: nil)
        
        
        
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    
    func retrieveData() {
        ref.child("Games/\(gameID)/Participants").observeSingleEvent(of: .value, with: { (snapshot) in
            for users in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = users.value as? NSDictionary else {
                    return
                }
                let name = value["username"] as! String
                let score = value["score"] as! Double
                
                
                
                self.playerList.append(playerCell(user: name, score: score))
                
                
                
            }
            
            self.playerList = self.playerList.sorted() { $0.score > $1.score }
            self.tableView.reloadData()
        }) { (error) in
            print("error:(error.localizedDescription)")
        }
    }
}

extension popUpViewController: UITableViewDelegate {
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("yote")
    }
}

extension popUpViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lcell", for: indexPath) as! LeadCell
        
        cell.name.text = playerList[indexPath.row].user
        cell.score.text = String(playerList[indexPath.row].score)
        
        
        return cell
    }
    
    
    
}


//extension popUpViewController: UITableViewDelegate {
//func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
//
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        return 1
//    }
//}
