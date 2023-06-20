//
//  Store.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-20.
//

import SwiftUI

let _items = [
    ItemElement("Bananas"),
    ItemElement("Apples"),
]

struct AppState: StateFul {
    var items: [ItemElement]
    var lists: [ListElement]
    
    var selectedList: Int = 0
    var activeList: ListElement
    
    init() {
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
        self.activeList = self.lists[0]
    }
}

enum AppActions {
    case toggleListItem(list: UUID, item: UUID, toggled: Bool)      // Should the item be in the list?
    case setListItemStatus(list: UUID, item: UUID, toggled: Bool)   // Is the item checked (done)?
    case setSelectedListIndex(index: Int)
    case addList
    case deleteList(list: UUID)
}

typealias AppStore = Store<AppState, AppActions>

protocol StateFul {
    init()
}

actor Store<S: StateFul, Action>: ObservableObject {
    typealias Reducer = (S, Action) -> S
    
    @MainActor @Published private(set) var state: S = .init()
    private let reducer: Reducer
    
    init(reducer: @escaping Reducer) {
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) async {
        await MainActor.run {
            let currentState = state
            let newState = reducer(currentState, action)
            state = newState
        }
    }
}
