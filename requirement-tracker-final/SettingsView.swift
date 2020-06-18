//
//  SettingsView.swift
//  requirement-tracker
//
//  Created by Mehul Arora on 6/6/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    // Shared data for settings
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack{
            Text("Settings").font(.system(size: 30, weight: .semibold)).padding()
            
            Form{
                // Bind to settings.username to automatically sink changes to UserDefaults
                Section(header: Text("Your Name")){
                    TextField("", text: $settings.username)
                }
                
                // Bind to settings.quarters to automatically sink changes to UserDefaults
                Toggle(isOn: $settings.quarters){
                    Text("Quarter system")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
