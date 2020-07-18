//
//  scoreManager.swift
//  ColorQuest
//
//  Created by Liang on 7/18/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import Foundation

class scoreManager {
    
    func gen_rgb() -> (Int, Int, Int) {
        let r = round(Int.random(in: 1..<256))
        let g = round(Int.random(in: 1..<256))
        let b = round(Int.random(in: 1..<256))
        return (r, g, b)
    }
    
    func round(_ x: Int) -> Int {
        return Int(ceil(Double(x) / 10.0)) * 10
    }
    
    func similarity(_ r1: Int, _ g1: Int, b1: Int, r2: Int, g2: Int, b2: Int) -> Int {
        var d = sqrt(pow(Double(r2 - r1), 2) + pow(Double(g2 - g1), 2) + pow(Double(b2 - b1), 2))
        
        if (d < 130) {
            d = d * 0.3
        } else if (d < 150) {
            d = d * 0.5
        } else if (d < 170) {
            d = d * 0.7
        } else if (d < 200) {
            d = d * 1.1
        }
        
        let p = d/sqrt(3 * pow(255, 2))
        
        if (1-p < 0) {
            return 0
        } else {
            return Int(1000*ceil((1-p) * 100) / 100)
        }
    }
    
    
}
