//
//  Settings.swift
//  requirement-tracker
//
//  Created by Mehul Arora on 6/6/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI
import Combine

class Settings: ObservableObject {
    
    // Publish properties to redraw other views
    @Published var username: String
    @Published var quarters: Bool
    
    // User default for name
    var nameAutosave   : AnyCancellable?
    // User default for quarter system
    var quarterAutosave: AnyCancellable?
    
    init(){
        // Key to store name
        let defaultConfigKey = "username"
        
        // Key to store quarter system
        let defaultSystem    = "collegeSystem"
        
        // Load settings
        username = UserDefaults.standard.object(forKey: defaultConfigKey) as? String ?? "User"
        quarters = UserDefaults.standard.object(forKey: defaultSystem) as? Bool ?? true
        
        // Publisher to sink changes to username
        nameAutosave = $username.sink{ name in
            UserDefaults.standard.set(name, forKey: defaultConfigKey)
        }
        
        quarterAutosave = $quarters.sink{ q in
            UserDefaults.standard.set(q, forKey: defaultSystem)
        }
    }
}
