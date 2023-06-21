//
//  ContentView.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-16.
//

import SwiftUI

enum AppActions {
    case toggleListItem(list: UUID, item: UUID, toggled: Bool)      // Should the item be in the list?
    case setListItemStatus(list: UUID, item: UUID, toggled: Bool)   // Is the item checked (done)?
    case setSelectedListIndex(index: Int)
    case addList
    case deleteList(list: UUID)
}

typealias AppStore = Store<AppState, AppActions>

struct ContentView: View {
    @StateObject var store = AppStore { state, action, dispatch in
        var newState = state
        
        switch action {
        case let .toggleListItem(listid, itemid, toggled):
            if var index = newState.lists.firstIndex(where: { $0.id == listid }) {
                if toggled {
                    if let item = newState.items.first(where: { $0.id == itemid }) {
                        newState.lists[index].items.append(ListItemElement(item))
                    }
                } else {
                    if let itemIndex = newState.lists[index].items.firstIndex(where: { $0.item.id == itemid }) {
                        newState.lists[index].items.remove(at: itemIndex)
                    }
                }
            }
                
        case let .setListItemStatus(listid, itemid, toggled):
            var item = newState.lists.first(where: { list in
                list.id == listid
            }).flatMap({ list in
                list.items.first(where: { item in
                    item.id == itemid
                })
            })
            
            item?.done.toggle()
        case let .setSelectedListIndex(index):
            newState.selectedList = index
            newState.activeList = newState.lists[index]
        case .addList:
            newState.lists.append(ListElement(items: [ListItemElement(newState.items[0])]))
            
            Task {
                // Navigate to the new list after 300ms
                try? await Task.sleep(nanoseconds: 300_000_000)
                await dispatch(.setSelectedListIndex(index: newState.lists.count - 1))
            }
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
            
            ItemsView()
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("Items")
                }
        }
        .environmentObject(store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
