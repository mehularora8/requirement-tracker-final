//
//  RequirementsView.swift
//  requirement-tracker
//
//  Created by Mehul Arora on 6/4/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import SwiftUI

struct RequirementsView: View {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: Requirement.entity(), sortDescriptors: [
        // Sort fetched requests according to name
        NSSortDescriptor(keyPath: \Requirement.name, ascending: true)
    ], predicate: nil) var fetchedReqs: FetchedResults<Requirement>
    
    var reqs: [Requirement] {
        Array(fetchedReqs)
    }
    
    @State private var editing: EditMode = .inactive
    
    var body: some View {
            NavigationView{
                List{
                    ForEach(reqs, id: \.self.name){ req in
                        // Make navigation link leading to notes for each requirement
                        NavigationLink(destination: ReqNotesView(req: req).environment(\.managedObjectContext, self.context), label: {
                            ReqView(reqForView: req)
                                .environment(\.managedObjectContext, self.context)
                                .padding(self.padding)
                        })
                    }
                        .onDelete{ indexSet in
                            // Delete requirement form context
                            let deleteItem = self.reqs[indexSet.first!]
                            self.moc.delete(deleteItem)
                            
                            try? self.moc.save()
                        }
                }
                    .navigationBarTitle("Requirements")
                    .navigationBarItems(
                        leading: Button( action:{
                            // Add new requirement. Let user edit according to preferences
                            let newReq = Requirement(context: self.moc)
                            
                            newReq.name = "Requirement" + String(self.reqs.count + 1) // Name is the unique identifier, make sure to add an identifier
                            newReq.taken = 0
                            newReq.needed = 1
                            
                            try? self.moc.save()
                        }, label: {
                            Image(systemName: "plus").imageScale(.large)
                        }),
                        trailing: EditButton()
                    )
                    .environment(\.editMode, $editing)
            }
        }
        
        //MARK:- Drawing constants
        var padding: CGFloat = 10.0
        var animationDuration: Double = 0.5
}

// Structurally similar to NotesView(). Utilizes and saves notes for a Requirement rather than a TakenClass.
struct ReqNotesView: View{
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: Requirement.entity(), sortDescriptors: [
        // Sort according to name
        NSSortDescriptor(keyPath: \Requirement.name, ascending: true)
    ], predicate: nil) var fetchedReqs: FetchedResults<Requirement>
    
    var reqs: [Requirement] {
        Array(fetchedReqs)
    }
    
    @State var notes: String
    // Status to show user that the notes have been saved (changed below)
    @State var status: String = "Type any notes here!"
    
    var req: Requirement
    
    init(req: Requirement){
        self.req = req
        self._notes = State<String>.init(initialValue: req.reqNotes?.notes ?? "")
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
            // Save notes to context
            if let index = self.reqs.firstIndex(matching: self.req) {
                let reqNotes = Notes(context: self.moc)
                reqNotes.notes = self.notes
                
                self.reqs[index].reqNotes = reqNotes
                try? self.moc.save()
                withAnimation(.easeInOut){
                    self.status = "Notes saved"
                }
            }
        }, label: { Text("Save") }))
    }
}

// View for a singular requirement. Acts as a label for navigation link.
struct ReqView : View {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @ObservedObject var reqForView: Requirement
    
    @Environment(\.managedObjectContext) var moc

    @State var showEditor: Bool = false
    
    // Computer property to draw view based on whether or not requirement has been completed.
    // The "Automatic updating" backbone of the project
    private var reqComplete: Bool {
        ((reqForView.coursesFulfilling as? Set<TakenClass>) ?? []).count >= reqForView.needed
    }

    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .fill(
                    self.reqComplete ?  completed : incomplete
                )
            
            HStack{
                Group{
                    VStack{
                        Text("\(reqForView.name ?? "No code")")
                        Text("Completed: \(String(((reqForView.coursesFulfilling as? Set<TakenClass>) ?? []).count)) / \(String(reqForView.needed))")
                    }
                        .foregroundColor(Color.white)
                    
                    
                    Image(systemName: "keyboard")
                        .onTapGesture {
                            // Open editor
                            self.showEditor = true
                        }
                        .sheet(isPresented: $showEditor){
                            ReqEditor(showReqEditor: self.$showEditor, editingReq: self.reqForView)
                                .environment(\.managedObjectContext, self.context)
                        }
                    
                    // Add a Tick to the view if requirement is complete
                    if self.reqComplete {
                        Tick()
                            .foregroundColor(self.darkGreen)
                            .frame(width: self.fWidth, height: self.fHeight)
                    }
                }
                    .padding()
            }
        }
    }
    
    //MARK:- Drawing constants
    
    var fWidth: CGFloat            = 50 // Frame width
    var fHeight: CGFloat           = 40 // Frame height
    var cornerRadius: CGFloat      = 10.0
    var animationDuration: CGFloat = 0.5
    var completed: LinearGradient  = LinearGradient(gradient: Gradient(colors: [Color(red: 66/255, green: 237/255, blue: 152/255), .green]),
                                                    startPoint: .bottomTrailing, endPoint: .topLeading)
    var incomplete: LinearGradient = LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .bottomTrailing, endPoint: .topLeading)
    var darkGreen: Color           = Color(red: 20/255, green: 102/255, blue: 61/255)
}

// Structurally similar to CourseEditor(), with a Requirement instead of a Course.
struct ReqEditor: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: Requirement.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Requirement.name, ascending: true)
    ], predicate: nil) var fetchedReqs: FetchedResults<Requirement>
    
    var reqs: [Requirement] {
        Array(fetchedReqs)
    }
    
    var editing: Requirement // Needed to search for editing in fetch request
    
    @Binding var showEditor: Bool
    
    @State var editedName   : String
    @State var editedNeeded : Int
    
    let nums = ["0", "1", "2", "3", "4", "5", "6"]
    
    init(showReqEditor: Binding<Bool>, editingReq: Requirement){
        self.editing        = editingReq
        self._showEditor    = showReqEditor
        self._editedName    = State<String>.init(initialValue: editingReq.name ?? "")
        self._editedNeeded  = State<Int>.init(initialValue: Int(editingReq.needed))
    }
    
    var body: some View {
        VStack{
            ZStack {
                HStack {
                    Button(action: {
                        // Delete changes
                        self.showEditor = false
                    }, label:  { Text("Cancel") }).padding()
                    Spacer()
                }
                Text("Edit Requirement").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        // Save changes to context
                        if let index = self.reqs.firstIndex(matching: self.editing) {
                            self.reqs[index].name   = self.editedName
                            self.reqs[index].needed = Int32(self.editedNeeded)

                            try? self.moc.save()
                        }
                        self.showEditor = false
                    }, label: { Text("Done") }).padding()
                }
            }
            NavigationView{
                Form{
                    Section(header: Text("Name")) {
                        TextField("", text: $editedName)
                    }
                    Section {
                        // Picker to specify the number of classes needed for this requirement
                        Picker("Needed", selection: $editedNeeded){
                            ForEach(0..<nums.count){ num in
                                Text(self.nums[num]).tag(num)
                            }
                        }
                    }
                }
                    // Hide Navigation bar for compact UI
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }
        }
    }
}
