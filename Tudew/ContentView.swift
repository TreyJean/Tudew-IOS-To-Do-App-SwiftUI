//
//  ContentView.swift
//  Tudew
//
//  Created by Trey Jean-Baptiste on 6/24/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.created_at, ascending: true)], predicate: NSPredicate(format: "priority == %@", "low")) var low_pri_items: FetchedResults<Item>
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.created_at, ascending: true)], predicate: NSPredicate(format: "priority == %@", "normal")) var norm_pri_items: FetchedResults<Item>
    
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.created_at, ascending: true)], predicate: NSPredicate(format: "priority == %@", "high")) var high_pri_items: FetchedResults<Item>
    
    
    let dateFormatter = DateFormatter()
    
    func setup() {
        dateFormatter.dateStyle = .medium
        
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
    }
    
    func removeLowItem(at offsets: IndexSet) {
        for index in offsets {
            let item = low_pri_items[index]
            PersistenceController.shared.delete(item)
        }
    }
    
    func removeNormItem(at offsets: IndexSet) {
        for index in offsets {
            let item = norm_pri_items[index]
            PersistenceController.shared.delete(item)
        }
    }
    
    func removeHighItem(at offsets: IndexSet) {
        for index in offsets {
            let item = high_pri_items[index]
            PersistenceController.shared.delete(item)
        }
    }
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List {
                        Section(header: Text("High Priority")) {
                            if high_pri_items.isEmpty {
                                Text("No High Priority Items.")
                                    .foregroundColor(.secondary)
                            }
                            
                            ForEach(high_pri_items, id: \.self) { item in
                                VStack(alignment: .leading) {
                                    Text("\(item.title ?? "Unknown")")
                                    Text(dateFormatter.string(from: item.created_at!))
                                        .font(.subheadline)
                                        .fontWeight(.light)
                                }
                            }.onDelete(perform: removeHighItem)
                        }
                        
                        Section(header: Text("Normal Priority")) {
                            if norm_pri_items.isEmpty {
                                Text("No Normal Priority Items.")
                                    .foregroundColor(.secondary)
                            }
                            
                            ForEach(norm_pri_items, id: \.self) { item in
                                VStack(alignment: .leading) {
                                    Text("\(item.title ?? "Unknown")")
                                    Text(dateFormatter.string(from: item.created_at!))
                                        .font(.subheadline)
                                        .fontWeight(.light)
                                }
                            }.onDelete(perform: removeNormItem)
                        }
                        
                        Section(header: Text("Low Priority")) {
                            if low_pri_items.isEmpty {
                                Text("No Low Priority Items.")
                                    .foregroundColor(.secondary)
                            }
                            
                            ForEach(low_pri_items, id: \.self) { item in
                                VStack(alignment: .leading) {
                                    Text("\(item.title ?? "Unknown")")
                                    Text(dateFormatter.string(from: item.created_at!))
                                        .font(.subheadline)
                                        .fontWeight(.light)
                                }
                            }.onDelete(perform: removeLowItem)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                VStack{
                    Spacer()
                    
                    HStack{
                        Spacer()
                        
                        NavigationLink(destination: NewToDoView(), label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.custom("hugeButton", fixedSize: 50))
                            }
                        ).padding()
                    }
                }
            }
            .navigationTitle(Text("Your To-Do's"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setup()
            }
            
        }
    }
}

struct NewToDoView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var title: String = ""
    @State var selected: Int = 1
    
    @State var isAlertPresented = false
    @State var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("To-Do Title")) {
                TextField("Type your To-Do Here!", text: $title)
            }
            
            Section(header: Text("To-Do Priority")) {
                Picker(selection: $selected, label: Text("Priority"), content: {
                    Text("High").tag(2)
                    Text("Normal").tag(1)
                    Text("Low").tag(0)
                }).pickerStyle(DefaultPickerStyle())
            }
            
            Button(action: {
                let item = Item(context: managedObjectContext)
                
                item.title = title
                item.priority = (selected == 0 ? "low" : (selected == 2 ? "high" : "normal"))
                item.created_at = Date()
                
                PersistenceController.shared.save()
                
                title = ""
                selected = 1
                
                alertMessage = "Successfully Created To-Do!"
                isAlertPresented.toggle()
                
            }, label: {
                Text("Create New To-Do")
            }).alert(isPresented: $isAlertPresented, content: {
                Alert(title: Text("Success!"), message: Text("\(alertMessage)"), dismissButton: .cancel(Text("Ok")))
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
