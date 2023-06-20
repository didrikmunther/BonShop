//
//  List.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-19.
//

import SwiftUI

struct ListItemElement: Identifiable {
    let id = UUID()
    var item: ItemElement
    var done = false
    
    init(_ item: ItemElement) {
        self.item = item
    }
}

struct ListElement: Identifiable {
    var items: [ListItemElement]
    let id = UUID()
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
    @Binding var items: [ListItemElement]
    
    @State private var multiSelection = Set<UUID>()
    
    var body: some View {
        List($items, selection: $multiSelection) { $item in
            Toggle(isOn: $item.done) {
                Text(item.item.name)
            }
            .toggleStyle(iOSCheckboxToggleStyle())
        }
    }
}

struct ListEdit: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var lists: [ListElement]
    @Binding var list: ListElement
    @Binding var items: [ItemElement]
    
    @State var onDelete: () async -> Void = {}
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($items) { $item in
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            $list.items.contains { listElement in
                                listElement.item.id == item.id
                            }
                        }, set: {isActive in
                            if isActive {
                                list.items.append(ListItemElement(item))
                            } else {
                                if let index = list.items.firstIndex(where: {element in
                                    element.item.id == item.id
                                }) {
                                    list.items.remove(at: index)
                                }
                            }
                        }
                    )) {
                        Text(item.name)
                    }
                }
            }
            Button("Delete", role: .destructive) {
                //                if let index = lists.firstIndex(where: { element in
                //                    element.id == list.id
                //                }) {
                //                    lists.remove(at: index)
                //                }
                
                Task {
                    await onDelete()
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
    @Binding var lists: [ListElement]
    @Binding var items: [ItemElement]
    
    @State private var selectedList = 0
    @State private var isAddingItems = false
    
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = .black.withAlphaComponent(0.2)
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedList) {
                ForEach(Array(zip($lists.indices, $lists)), id: \.0) { (index, list) in
                    ListView(items: list.items).tag(index)
                }
            }
            .navigationTitle("Lists")
            .tabViewStyle(.page)
            .onAppear {
                setupAppearance()
            }
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
                        lists.append(ListElement(items: [ListItemElement(items[0])]))
                        selectedList = lists.count - 1
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingItems) {
                let list = $lists[selectedList]
                let onDelete = {
                    if let index = lists.firstIndex(where: { element in
                        element.id == list.id
                    }) {
                        if index == lists.count - 1 {
                            selectedList = index - 1;
                        }
                        
                        lists.remove(at: index)
                    }
                }
                
                ListEdit(lists: $lists,
                         list: list,
                         items: $items,
                         onDelete: onDelete)
            }
        }
    }
}
