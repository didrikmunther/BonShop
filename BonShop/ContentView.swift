//
//  ContentView.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-16.
//

import SwiftUI

let defaultItems = [
    ItemElement("Bananas"),
    ItemElement("Apples"),
]

let defaultLists = [
    ListElement(items: [
        ListItemElement(defaultItems[0]),
        ListItemElement(defaultItems[1])
    ]),
    ListElement(items: [
        ListItemElement(defaultItems[1])
    ])
]

class AppState: ObservableObject {
    @Published var items: [ItemElement]
    @Published var lists: [ListElement]
    
    init() {
        self.items = defaultItems
        self.lists = defaultLists
    }
}

struct ContentView: View {
    @StateObject var state = AppState()
    
    var body: some View {
        #if os(iOS)
        TabView {
            ListsView(lists: $state.lists, items: $state.items)
                .tabItem {
                    Image(systemName: "star")
                    Text("Lists")
                }

            ItemsView(items: $state.items)
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("Items")
                }
        }
        #else
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Hejsan")
                        .font(.title)
                }
                
                HStack {
                    Text("Park")
                    Spacer()
                    Text("State")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text("About \("Hejsan")")
                    .font(.title2)
                Text("Description")
            }
            .padding()
            .frame(maxWidth: 400)
        }
        .navigationTitle("Hejsan")
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
