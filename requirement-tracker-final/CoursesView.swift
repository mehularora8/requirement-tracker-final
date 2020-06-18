//
//  CoursesView.swift
//  requirement-tracker
//
//  Created by Mehul Arora on 6/3/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI

struct CoursesView: View {
    
    @EnvironmentObject var settings: Settings
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @Environment(\.managedObjectContext) var moc
    
    // Fetch Classes added by user
    @FetchRequest(entity: TakenClass.entity(), sortDescriptors: [
        // Sort by completed first, then by quarter
        NSSortDescriptor(keyPath: \TakenClass.completed, ascending: true),
        NSSortDescriptor(keyPath: \TakenClass.quarter, ascending: true)
    ], predicate: nil) var fetchedClasses: FetchedResults<TakenClass>
    
    var classes: [TakenClass] {
        Array(fetchedClasses)
    }
    
    // State variable for zoom animation
    @State private var scaleUnits: CGFloat  = 1.0
    
    // Editing Mode. Initially inactive
    @State private var editing   : EditMode = .inactive
    
    var body: some View {
        NavigationView{
            List{
                HStack{
                    Spacer()
                    VStack{
                        Text("Total Units taken: \(self.getUnits().0)")
                        Text("Active Units: \(self.getUnits().1)")
                    }
                        .emphasize()
                        .scaleEffect(self.scaleUnits)
                        .animation(
                                Animation.easeOut(duration: 0.4)
                                .repeatCount(3, autoreverses: true)
                        )
                    Spacer()
                }
                
                // For each of the fetched classes, make navigation link leading to Notes for that class.
                // Label is a summary of important information
                ForEach(classes, id: \.self.id){ course in
                    NavigationLink(destination: NotesView(course: course).environment(\.managedObjectContext, self.context), label: {
                        CourseView(courseForView: course)
                            .environment(\.managedObjectContext, self.context)
                            .environmentObject(self.settings)
                            .padding(self.padding)
                            .onLongPressGesture {
                                // Mark class as complete
                                if let tappedIndex = self.classes.firstIndex(of: course) {
                                    withAnimation(.linear(duration: self.animationDuration)){ //Explicit animation
                                        self.classes[tappedIndex].completed = !self.classes[tappedIndex].completed
                                        try? self.moc.save()
                                    }
                                }
                            }
                    })
                }
                .onDelete{ indexSet in
                    // Delete class from database
                    // Change state to animate
                    self.scaleUnits *= 1.01
                    let deleteItem = self.classes[indexSet.first!]
                    self.moc.delete(deleteItem)
                    try? self.moc.save()
                }
            }
                .navigationBarTitle(settings.username == "" ? "User's Courses" : "\(settings.username)'s Courses")
                .navigationBarItems(
                    leading: Button( action:{
                        //Change to animate
                        self.scaleUnits *= 1.01
                        // Add new default class that can be edited
                        let newClass = TakenClass(context: self.moc)

                        newClass.code      = "NC" + String(self.classes.count + 1)
                        newClass.name      = "New Class" + String(self.classes.count + 1)
                        newClass.quarter   = "Fall"
                        newClass.year      = "2020"
                        newClass.completed = false
                        newClass.units     = 3
                        newClass.id        = UUID()
                        
                        try? self.moc.save()
                    }, label: {
                        Image(systemName: "plus").imageScale(.large)
                    }),
                    trailing: EditButton()
                )
                .environment(\.editMode, $editing)
        }
    }
    
    // Function to get the total number of units from the classes in the database
    private func getUnits() -> (Int, Int) {
        // Total number of units
        var totalUnits = 0
        // Units in classes that are not complete yet
        var activeUnits = 0
        
        for index in (0 ..< self.classes.count) {
            totalUnits += Int(classes[index].units)
            
            if !classes[index].completed {
                activeUnits += Int(classes[index].units)
            }
        }
        
        return (totalUnits, activeUnits)
    }
    
    //MARK:- Drawing constants
    var padding          : CGFloat = 10.0
    var cornerRadius     : CGFloat = 2.0
    var animationDuration: Double = 0.5
}

// View for singular course. Acts as label for navigation link
struct CourseView : View {
    
    @EnvironmentObject var settings: Settings
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Course for which view is being drawn. @ObservedObject property wrapper to reflect changes in db.
    @ObservedObject var courseForView: TakenClass
    
    // Context
    @Environment(\.managedObjectContext) var moc
    
    // Show editor?
    @State var showEditor: Bool = false
    
    var body: some View {
        ZStack{
            // Denote as complete or incompelte
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .fill(
                    courseForView.completed ?  completed : incomplete
                )
            
            Group{
                HStack{
                    VStack{
                            Text("\(self.courseForView.code ?? "No code")")
                            Text("\(self.courseForView.name ?? "No name")")
                            Text("\(self.courseForView.units) units")
                            Text("Req: \(self.courseForView.reqFulfilled?.name ?? "None")")
                            Text("\(self.courseForView.quarter ?? "NQ"), \(self.courseForView.year ?? "2020")")
                        }
                            .foregroundColor(Color.white)
                            // Must always show
                            .layoutPriority(0.5)
                            .frame(maxWidth: self.minWidth)
                        
                    
                    Image(systemName: "keyboard")
                        .onTapGesture {
                            self.showEditor = true
                        }
                        .sheet(isPresented: $showEditor){
                            CourseEditor(showCourseEditor: self.$showEditor, editingClass: self.courseForView)
                                .environment(\.managedObjectContext, self.context)
                                .environmentObject(self.settings)
                        }
                    
                    // Add an image with animation if user marks class complete
                    if courseForView.completed {
                        GeometryReader{ geometry in
                            withAnimation(.linear){
                                Tick()
                                    .foregroundColor(self.darkGreen)
                                    .frame(width: self.fWidth, height: self.fHeight)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    //MARK:- Drawing constants
    var fWidth           : CGFloat = 40
    var fHeight          : CGFloat = 40
    var minWidth         : CGFloat = 160
    var cornerRadius     : CGFloat = 10.0
    var animationDuration: CGFloat = 0.5
    var completed : LinearGradient  = LinearGradient(gradient: Gradient(colors: [Color(red: 66/255, green: 237/255, blue: 152/255), .green]),
                                                    startPoint: .bottomTrailing, endPoint: .topLeading)
    var incomplete: LinearGradient = LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .bottomTrailing, endPoint: .topLeading)
    var darkGreen : Color           = Color(red: 20/255, green: 102/255, blue: 61/255)
}

// View for the notes of a class
struct NotesView: View{
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: TakenClass.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \TakenClass.completed, ascending: true)
    ], predicate: nil) var fetchedClasses: FetchedResults<TakenClass>
    
    var classes: [TakenClass] {
        Array(fetchedClasses)
    }
    
    @State var notes: String
    // State string to be updated to show that changes have been saved
    @State var status: String = "Type any notes here!"
    
    var course: TakenClass
    
    init(course: TakenClass){
        self.course = course
        self._notes = State<String>.init(initialValue: course.notes?.notes ?? "")
    }
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text(self.status)
                Spacer()
            }
                .padding()
            Form{
                Section() {
                    TextField("", text: $notes)
                }
            }
        }
            .navigationBarTitle("Notes 🎓")
            .navigationBarItems(trailing: Button(action: {
                // Save button to save notes to database
                if let index = self.classes.firstIndex(matching: self.course) {
                    let classNotes = Notes(context: self.moc)
                    classNotes.notes = self.notes
                    
                    self.classes[index].notes = classNotes
                    try? self.moc.save()
                    withAnimation(.easeInOut){
                        self.status = "Notes saved"
                    }
                }
            }, label: { Text("Save") }))
    }
}

struct CourseEditor: View {
    
    @EnvironmentObject var settings: Settings
    @Environment(\.managedObjectContext) var moc
    
    // Fetched classes
    @FetchRequest(entity: TakenClass.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \TakenClass.completed, ascending: true)
    ], predicate: nil) var fetchedClasses: FetchedResults<TakenClass>
    
    // Convert to array
    var classes: [TakenClass] {
        Array(fetchedClasses)
    }
    
    // Fetched requirements. Needed to choose requirement from picker
    @FetchRequest(entity: Requirement.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Requirement.name, ascending: true)
    ], predicate: nil) var fetchedReqs: FetchedResults<Requirement>
    
    // Convert to array
    var reqs: [Requirement] {
        Array(fetchedReqs)
    }
    
    // String array for view in picker
    let numberOfUnits = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
    
    var editing: TakenClass // Needed to search for editing in fetch request
    
    @Binding var showEditor: Bool
    
    @State var editedName   : String
    @State var editedCode   : String
    @State var editedQuarter: String
    @State var editedYear   : String
    @State var editedUnits  : Int
    @State var chosenReq    : Int
    
    init(showCourseEditor: Binding<Bool>, editingClass: TakenClass){
        self.editing        = editingClass
        self._showEditor    = showCourseEditor
        self._editedName    = State<String>.init(initialValue: editingClass.name ?? "")
        self._editedCode    = State<String>.init(initialValue: editingClass.code ?? "")
        self._editedQuarter = State<String>.init(initialValue: editingClass.quarter ?? "")
        self._editedYear    = State<String>.init(initialValue: editingClass.year ?? "")
        self._editedUnits   = State<Int>.init(initialValue: Int(editingClass.units))
        self._chosenReq     = State<Int>.init(initialValue: -1)
    }
    
    var body: some View {
        VStack{
            ZStack {
                HStack {
                    Button(action: {
                        // Cancel any made changes
                        self.showEditor = false
                    }, label: {
                        Text("Cancel")
                    }).padding()
                    Spacer()
                }
                Text("Edit Class")
                    .font(.headline)
                    .padding()
                HStack {
                    Spacer()
                    Button(action: {
                        // Save changes to context
                        if let index = self.classes.firstIndex(matching: self.editing) {
                            
                            self.classes[index].name    = self.editedName
                            self.classes[index].code    = self.editedCode
                            self.classes[index].quarter = self.editedQuarter
                            self.classes[index].year    = self.editedYear
                            self.classes[index].units   = Int32(self.editedUnits)
                            
                            if self.chosenReq >= 0 {
                                self.classes[index].reqFulfilled = self.reqs[self.chosenReq]
                            }
                            
                            try? self.moc.save()
                        }
                        self.showEditor = false
                    }, label: { Text("Done") }).padding()
                }
            }
            
            NavigationView{
                // Form to let user edit class with text fields and pickers
                Form{
                    Section(header: Text("Code")) {
                        TextField("", text: $editedCode)
                    }
                    
                    Section(header: Text("Name")) {
                        TextField("", text: $editedName)
                    }
                    
                    Section{
                        Picker("Units", selection: $editedUnits){
                            ForEach(0..<numberOfUnits.count, id: \.self){ num in
                                Text(self.numberOfUnits[num]).tag(num)
                            }
                        }
                    }
                    
                    Section{
                        Picker("Requirement Fulfilled", selection: $chosenReq){
                            ForEach(0..<self.reqs.count, id: \.self){ req in
                                Text("\(self.reqs[req].name ?? "None")").tag(req)
                            }
                        }
                    }
                    
                    Section(header: Text(self.settings.quarters ? "Quarter" : "Semester")) {
                        TextField("", text: $editedQuarter)
                    }
                    
                    Section(header: Text("Year")){
                        TextField("", text: $editedYear)
                    }
                }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }
        }
    }
}

struct CoursesView_Previews: PreviewProvider {
    static var previews: some View {
        CoursesView()
    }
}
