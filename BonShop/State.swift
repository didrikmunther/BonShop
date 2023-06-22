//
//  State.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-21.
//

import SwiftUI

let defaultItems = [
    ItemElement("Bananas"),
    ItemElement("Apples"),
    ItemElement("Pear"),
    ItemElement("Egg"),
    ItemElement("Milk"),
]

let defaultLists = [
    ListElement(items: [
        ListItemElement(defaultItems[0].id),
        ListItemElement(defaultItems[1].id),
        ListItemElement(defaultItems[2].id),
        ListItemElement(defaultItems[3].id),
        ListItemElement(defaultItems[4].id)
    ]),
    ListElement(items: [
        ListItemElement(defaultItems[1].id),
        ListItemElement(defaultItems[3].id),
        ListItemElement(defaultItems[4].id)
    ])
]

@MainActor
class AppState: ObservableObject {
    @Published var items: [ItemElement] = [ItemElement]()
    @Published var lists: [ListElement] = [ListElement]()
    
    init() {
        self.items = defaultItems
        self.lists = defaultLists
    }
    
    func updateList(_ list: ListElement) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
        }
    }
    
    func updateListItem(_ list: ListElement, _ item: ListItemElement) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else {
            return;
        }
        
        guard let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) else {
            return;
        }
        
        lists[listIndex].items[itemIndex] = item
    }
    
    func deleteListItem(_ list: ListElement, _ item: ListItemElement) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else {
            return;
        }
        
        guard let itemIndex = lists[listIndex].items.firstIndex(where: { $0.id == item.id }) else {
            return;
        }
        
        lists[listIndex].items.remove(at: itemIndex)
    }
    
    func addListItem(_ list: ListElement, _ item: ListItemElement) {
        guard let listIndex = lists.firstIndex(where: { $0.id == list.id }) else {
            return;
        }
        
        lists[listIndex].items.append(item)
    }
    
    func createList() {
        lists.append(ListElement(items: [ListItemElement(items[0].id)]))
    }
    
    func deleteList(_ list: ListItemID) {
        lists.removeAll(where: { $0.id == list })
    }
    
    func updateItem(_ item: ItemElement) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func addItem(_ item: ItemElement) {
        items.append(item)
    }
    
    func deleteItems(atOffsets: IndexSet) {
        let indices = items.indices.filter({ !items[$0].deleted })
        
        atOffsets.forEach { i in
            items[indices[i]].deleted = true
        }
    }
    
    func moveItems(fromOffsets: IndexSet, toOffset: Int) {
        items.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
