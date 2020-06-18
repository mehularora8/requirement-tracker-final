//
//  View+Emphasize.swift
//  requirement-tracker
//
//  Created by Mehul Arora on 6/6/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI

// Custom view modifier. Enhances the look of the view and makes text noticeable.
struct Emphasize: AnimatableModifier {

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(self.pink)
            .padding(5)
    }
    
    var pink = Color(red: 250/255, green: 77/255, blue: 158/255)
}

extension View {
    func emphasize() -> some View {
        self.modifier(Emphasize())
    }
}
