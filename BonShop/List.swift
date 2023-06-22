//
//  List.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-19.
//

import SwiftUI

typealias ListItemID = UUID

struct ListItemElement: Identifiable {
    let id: ListItemID = UUID()
    var item: ItemID
    var done = false
    
    init(_ item: ItemID) {
        self.item = item
    }
}

struct ListElement: Identifiable {
    var items: [ListItemElement]
    let id = UUID()
    
    init(items: [ListItemElement]) {
        self.items = items
    }
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
                configuration.label
            }
        })
    }
}

struct ListView: View {
    @EnvironmentObject private var state: AppState
    
    var list: ListElement
    @State private var multiSelection = Set<UUID>()
    
    var body: some View {
        List(list.items, selection: $multiSelection) { item in
            Toggle(isOn: Binding<Bool>(
                get: {
                    item.done
                }, set: { isActive in
                    var newItem = item
                    newItem.done = isActive
                    state.updateListItem(list, newItem)
                }
            )) {
                Text(state.items.first(where: { $0.id == item.item }).flatMap({ item in
                    item.name
                }) ?? "N/A")
            }
            .toggleStyle(iOSCheckboxToggleStyle())
        }
    }
}

struct ListEditRow: View {
    @EnvironmentObject private var state: AppState
    
    @Binding var list: ListElement
    @Binding var item: ItemElement
    
    var body: some View {
        Toggle(isOn: Binding<Bool>(
            get: {
                list.items.contains { listElement in
                    listElement.item == item.id
                }
            }, set: {isActive in
                if isActive {
                    state.addListItem(list, ListItemElement(item.id))
                } else {
                    if let listElement = list.items.first(where: { listElement in
                        listElement.item == item.id
                    }) {
                        state.deleteListItem(list, listElement)
                    }
                }
            }
        )) {
            NavigationLink(destination: ItemView(item: $item)) {
                HStack {
                    Text(item.name)
                }
            }
            .navigationTitle("Edit List")
        }
    }
}

struct ListEdit: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var state: AppState
    
    @Binding var list: ListElement
    var onDelete: () async -> Void = {}
    
    var body: some View {
        NavigationStack {
            List {
                let items = $state.items.filter({ $item in
                    !item.deleted || list.items.contains(where: { $0.item == item.id })
                })
                
                ForEach(items) { $item in
                    ListEditRow(list: $list, item: $item)
                }
            }
            Button("Delete", role: .destructive) {
                Task {
                    state.deleteList(list.id)
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ListsView: View {
    @EnvironmentObject private var state: AppState
    
    @State private var selectedList = 0
    @State private var isAddingItems = false
    
#if os(iOS)
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = .black.withAlphaComponent(0.2)
    }
#endif
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedList) {
                ForEach(Array(zip(state.lists.indices, state.lists)), id: \.0) { (index, list) in
                    ListView(list: list).tag(index)
                }
            }
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isAddingItems = true
                    }) {
                        Text("Edit")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        state.createList()
                        selectedList = state.lists.count - 1
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingItems) {
                let list = $state.lists[selectedList]
                let onDelete = {
                    if let index = state.lists.firstIndex(where: { element in
                        element.id == list.id
                    }) {
                        if index == state.lists.count - 1 {
                            selectedList = index - 1;
                        }

                        state.deleteList(list.id)
                    }
                }
                
                ListEdit(list: list, onDelete: onDelete)
            }
            .iOS({
                $0
                    .tabViewStyle(.page)
                    .onAppear {
                        setupAppearance()
                    }
            })
        }
    }
}
