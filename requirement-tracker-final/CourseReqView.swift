//
//  CourseReqView.swift
//  requirement-tracker
//
//  Created by Mehul Arora on 6/3/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI

struct CourseReqView: View {
    
    // Settings Viewmodel
    @EnvironmentObject var settings: Settings
    
    // Persistent container context to pass over to views for fetch requests
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var body: some View {
        TabView(){
            // View for courses
            CoursesView()
                .environmentObject(settings)
                .environment(\.managedObjectContext, context)
                .tabItem{
                    Image(systemName: "book").imageScale(.large)
                    Text("Courses")
                }
            
            // View for requirements
            RequirementsView()
                .environment(\.managedObjectContext, context)
                .tabItem{
                    Image(systemName: "square.and.pencil").imageScale(.large)
                    Text("Requirements")
                }
            
            // View for How-To guide
            HowTo()
                .tabItem{
                    Image(systemName: "slider.horizontal.3").imageScale(.large)
                    Text("How To")
                }
            
            // View for settings
            SettingsView()
                .environmentObject(settings)
                .tabItem{
                    Image(systemName: "gear").imageScale(.large)
                    Text("Settings")
                }
        }
    }
}
