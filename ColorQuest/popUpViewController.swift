//
//  popUpViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/24/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase

class popUpViewController: UIViewController {

    var ref: DatabaseReference!
    
    var gameID : String = ""
    
    var username : String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    var playerList: [playerCell] = [playerCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = Database.database().reference()

        
        ref.child("Games/\(gameID)/Participants").observeSingleEvent(of: .value, with: { (snapshot) in
            for users in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = users.value as? NSDictionary else {
                    return
                }
                let name = value["username"] as! String
                let score = value["score"] as! String
//                self.leaderboard[name] = score
            
            }
        }) { (error) in
            print("error:(error.localizedDescription)")
        }
        
        
        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    

}

extension popUpViewController: UITableViewDelegate {
 
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("yote")
    }
}

extension popUpViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
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
