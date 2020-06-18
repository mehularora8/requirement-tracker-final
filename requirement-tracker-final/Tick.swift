//
//  SwiftUIView.swift
//  req-tracker
//
//  Created by Mehul Arora on 6/3/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI

struct Tick: Shape {
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = min(rect.width, rect.height) * 0.60 / 2
        
        p.move(to: center)
        // Proportions hard coded and adjusted according to slant of a check mark
        p.addLine(to: CGPoint(x: (center.x - width / 2), y: center.y - width / 4))
        p.addLine(to: CGPoint(x: center.x - 2 * width / 3, y : center.y))
        p.addLine(to: CGPoint(x: center.x + width / 10, y: center.y + 1.9 * width/5))
        p.addLine(to: CGPoint(x: center.x + width / 1.2 , y: center.y - width / 1.2))
        p.addLine(to: CGPoint(x: center.x + width / 1.6, y: center.y - width / 1.02))
        p.addLine(to: center)
        
        return p
    }
}

