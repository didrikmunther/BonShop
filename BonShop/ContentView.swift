//
//  ContentView.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-16.
//

import SwiftUI

struct ContentView: View {
    @StateObject var store = AppStore { state, action in
        var newState = state
        
        switch action {
        case let .toggleListItem(listid, itemid, toggled):
            print("toggle")
        case let .setListItemStatus(listid, itemid, toggled):
            var item = newState.lists.first(where: { list in
                list.id == listid
            }).map({ list in
                list.items.first(where: { item in
                    item.id == itemid
                })
            })
            
            item??.done.toggle()
        case let .setSelectedListIndex(index):
            newState.selectedList = index
            newState.activeList = newState.lists[index]
        case .addList:
            newState.lists.append(ListElement(items: [ListItemElement(newState.items[0])]))
            newState.selectedList = newState.lists.count - 1
        case let .deleteList(listid):
            if let index = newState.lists.firstIndex(where: { list in
                list.id == listid
            }) {
                if index == newState.lists.count - 1 {
                    newState.selectedList = index - 1;
                }

                newState.lists.remove(at: index)
            }
        }
        
        return newState
    }
    
    var body: some View {
        TabView {
            ListsView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Lists")
                }
            
//            ItemsView(items: $items)
//                .tabItem {
//                    Image(systemName: "circle.fill")
//                    Text("Items")
//                }
        }
        .environmentObject(store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
