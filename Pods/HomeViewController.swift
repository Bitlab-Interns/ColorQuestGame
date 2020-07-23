//
//  HomeViewController.swift
//  abseil
//
//  Created by Michael Peng on 7/22/20.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var playButton: PMSuperButton!
    @IBOutlet weak var create: PMSuperButton!
    @IBOutlet weak var join: PMSuperButton!
    @IBOutlet weak var stats: PMSuperButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        playButton = ActualGradientButton
        
        // Do any additional setup after loading the view.
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


class ActualGradientButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor.systemYellow.cgColor, UIColor.systemPink.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 16
        layer.insertSublayer(l, at: 0)
        return l
    }()
}
