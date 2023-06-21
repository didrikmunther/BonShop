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

protocol StateFul {
    init()
}

actor Store<S: StateFul, Action>: ObservableObject {
    typealias Reducer = (S, Action, @escaping (Action) async -> Void) -> S
    
    @MainActor @Published private(set) var state: S = .init()
    private let reducer: Reducer
    
    init(reducer: @escaping Reducer) {
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) async {
        await MainActor.run {
            let currentState = state
            let newState = reducer(currentState, action, self.dispatch)
            state = newState
        }
    }
}
