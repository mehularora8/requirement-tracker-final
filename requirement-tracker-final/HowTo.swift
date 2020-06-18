//
//  HowTo.swift
//  requirement-tracker
//
//  Created by Mehul Arora on 6/8/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI

struct HowTo: View {
    
    // Array with strings to show
    let tips: [String] = [
        "Start off by adding your courses to the courses tab and your requirements to the requirements tab.",
        "Clicking the plus button in the top left will add a new default entry, which you can edit by pressing the keyboard button.",
        "Long pressing on a class to mark it as complete. This will update the status of your requirements automatically.",
        "Each class can be marked as completing one requirement.",
        "Customize your name and college system (semesters or quarters) by going into settings."
    ]
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .fill(self.bpGradient)
                .edgesIgnoringSafeArea(.top) // Ignore top edge, UI looks better
            
            GeometryReader { geo in // Size fonts and stack spacing according to the geometry, adapt to ipad or iphone screens
                VStack{
                    VStack{
                        HStack{
                            Text("How To Guide")
                                .font(Font.system(size: min(geo.size.width, geo.size.height) / 14, weight: .semibold))
                            Image(systemName: "lightbulb.fill").imageScale(.large).foregroundColor(Color.yellow)
                        }
                            .padding()
                        
                        Text("Maximizing your efficiency with this app \n \n")
                            .font(Font.system(size: min(geo.size.width, geo.size.height) / 25))
                    }
                    
                    VStack(alignment: .leading, spacing: min(geo.size.width, geo.size.height) / 18){
                        ForEach(self.tips, id: \.self){ tip in
                            HStack{
                                // Makes a bullet point
                                Text("\u{2022}")
                                    .font(Font.system(size: min(geo.size.width, geo.size.height) / 28))
                                // Text with the sentence
                                Text(tip)
                                    .font(Font.system(size: min(geo.size.width, geo.size.height) / 26))
                            }
                        }
                    }
                    Spacer()
                }
                    .scaleEffect(self.zooming)
                    .rotationEffect(self.rotation)
                    .padding(min(geo.size.width, geo.size.height) / 20)
                    .foregroundColor(Color.white)
            }
        }
            // Combined gesture to rotate and zoom the content
            .gesture(SimultaneousGesture(zoom(), rotate()))
    }
    
    // Initial gesture state with scaling
    @GestureState var scaling: CGFloat = 1.0
    // Initial zoom state
    @State var initial: CGFloat = 1.0
    
    // Computer content zoom value for scale effect
    var zooming: CGFloat {
        scaling * initial
    }
    
    // Function to specify magnification gesture with animation
    private func zoom() -> some Gesture {
        MagnificationGesture()
            .updating($scaling) { latestGestureScale, scaling, transaction in
                scaling = latestGestureScale
            }
            .onEnded { finalScale in
                self.initial *= finalScale
            }
    }
    
    // Initial content rotation state
    @State var rotation: Angle = Angle(degrees: 0.0)
    
    // Function to specify rotation gesture with animation
    private func rotate() -> some Gesture {
        RotationGesture()
            .onChanged { finalRotation in
                self.rotation = finalRotation
            }
    }
    
    // MARK:- Drawing constants
    private var cornerRadius: CGFloat        = 15.0
    private var bpGradient  : LinearGradient = LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .bottomTrailing, endPoint: .topLeading)
}

struct HowTo_Previews: PreviewProvider {
    static var previews: some View {
        HowTo()
    }
}
