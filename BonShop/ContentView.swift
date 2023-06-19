//
//  ContentView.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-16.
//

import SwiftUI

struct ContentView: View {
    @State var items: [ItemElement]
    @State var lists: [ListElement]
    
    init() {
        let _items = [
            ItemElement("Bananas"),
            ItemElement("Apples"),
        ]
        
        self.lists = [
            ListElement(items: [
                ListItemElement(_items[0]),
                ListItemElement(_items[1])
            ]),
            ListElement(items: [
                ListItemElement(_items[1])
            ])
        ]
        
        self.items = _items
    }
    
    var body: some View {
        TabView {
            ListsView(lists: $lists, items: $items)
                .tabItem {
                    Image(systemName: "star")
                    Text("Lists")
                }
            
            ItemsView(items: $items)
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("Items")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
