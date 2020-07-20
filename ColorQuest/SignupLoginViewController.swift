//
//  SignupLoginViewController.swift
//  ColorQuest
//
//  Created by Michael Peng on 7/19/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import PMSuperButton

class SignupLoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchLoginReg: UISegmentedControl!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var enterButton: PMSuperButton!
    @IBOutlet weak var boxImage: UIImageView!
    
    var index : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAll()

        
        enterButton.touchUpInside {
            self.enterButton.showLoader()
            self.enterButton.titleLabel?.text = " "
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
        
//        if switchLoginReg.selectedSegmentIndex == 0 {
//             enterButton.titleLabel?.text = " "
//        }
//        else {
//            enterButton.titleLabel?.text = "Login"
//        }
    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
