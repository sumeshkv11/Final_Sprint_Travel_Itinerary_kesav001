//
//  ContentView.swift
//  TravelItenerary
//
//  Created by Sumesh Kesavamoorthy Vijayalakshmi on 4/27/23.
//

import SwiftUI

struct ContentView: View {
    @State var destination: String = ""
    @State var date: Date = Date()
    @State var notes: String = ""
    @State var savedItineraries: [Itinerary] = []
    @State var showingSavedItems: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Destination")) {
                    TextField("Enter destination", text: $destination)
                }
                
                Section(header: Text("Date")) {
                    DatePicker(selection: $date, in: Date()..., displayedComponents: .date) {
                        Text("Select a date")
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                }
                
                Section {
                    Button("Save") {
                        let itinerary = Itinerary(destination: destination, date: date, notes: notes)
                        let index = savedItineraries.firstIndex { $0.date > itinerary.date } ?? savedItineraries.endIndex
                        savedItineraries.insert(itinerary, at: index)
                        destination = ""
                        date = Date()
                        notes = ""
                    }
                }
            }
            .navigationBarTitle("Travel Itinerary")
            .navigationBarItems(trailing: Button("Saved Items") {
                showingSavedItems = true
            })
            .sheet(isPresented: $showingSavedItems) {
                NavigationView {
                    SavedItemsView(itineraries: $savedItineraries) // Use a binding to allow the list to be updated
                        .navigationBarTitle("Saved Itineraries")
                }
            }

        }
    }
}

struct SavedItemsView: View {
    @Binding var itineraries: [Itinerary] // Use a binding to allow the parent view to update the list
    let itemsPerPage = 3
    
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<numPages()) { page in
                let startIndex = page * itemsPerPage
                let endIndex = min(startIndex + itemsPerPage, itineraries.count)
                let pageItineraries = itineraries[startIndex..<endIndex]
                List {
                    ForEach(pageItineraries) { itinerary in
                        VStack(alignment: .leading) {
                            Text(itinerary.destination)
                                .font(.headline)
                            Text(itinerary.date, style: .date)
                            Text(itinerary.notes)
                                .foregroundColor(.secondary)
                        }
                        .contextMenu { // Add a context menu with a delete button
                            Button("Delete") {
                                if let index = itineraries.firstIndex(where: { $0.id == itinerary.id }) {
                                    itineraries.remove(at: index)
                                }
                            }
                        }
                        .onDrag { // Add a drag action to enable drag and drop
                            return NSItemProvider(item: String(itinerary.id.uuidString) as NSString, typeIdentifier: "public.plain-text")
                        }
                    }
                    .onMove { indices, newOffset in // Add a move action to update the list when an item is moved
                        itineraries.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .navigationBarItems(leading: Button("Back") {
                    dismiss()
                })
                .tag(page)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
        }
        .handlesExternalEvents(preferring: Set(arrayLiteral: "MoveEvent"), allowing: Set(arrayLiteral: "MoveEvent"))
    }
    
    func dismiss() {
        #if os(iOS)
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        #endif
    }
    
    func numPages() -> Int {
        return (itineraries.count + itemsPerPage - 1) / itemsPerPage
    }
}


struct Itinerary: Identifiable {
    let id = UUID()
    let destination: String
    let date: Date
    let notes: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
