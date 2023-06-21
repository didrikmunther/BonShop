//
//  Items.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-19.
//

import SwiftUI

struct ItemElement: Identifiable {
    var name: String
    let id: UUID
    
    init(_ name: String, id: UUID = UUID()) {
        self.name = name
        self.id = id
    }
    
    static var empty: Self {
        ItemElement("")
    }
}

struct ItemEdit: View {
    typealias SubmitCallback = (ItemElement) async -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var store: AppStore

    @State var item: ItemElement = .empty
    var onSubmit: SubmitCallback = { _ in }

    var body: some View {
        Form {
            Section(header: Text("Item")) {
                TextField("Name of item", text: $item.name)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    Task {
                        await onSubmit(item)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ItemView: View {
    let item: ItemElement

    @State var isEditing: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Item")) {
                Text(item.name)
            }
        }
        .navigationTitle("View item")
        .toolbar {
            Button("Edit") {
                isEditing = true
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                ItemEdit(item: item, onSubmit: { newItem in
                    print("new item", newItem)
//                    item.name = newItem.name
                })
                .navigationTitle("Edit item")
            }
        }
    }
}

struct ItemsView: View {
    @EnvironmentObject private var store: AppStore
    
    @State private var isCreating: Bool = false
    
    var body: some View {
        NavigationStack {
            TabView {
                List {
                    ForEach(store.state.items) { item in
                        NavigationLink(destination: ItemView(item: item)) {
                            HStack {
                                Text(item.name)
                            }
                        }
                    }
//                    .onMove { indexSet, offset in
//                        store.state.items.move(fromOffsets: indexSet, toOffset: offset)
//                    }
//                    .onDelete { indexSet in
//                        store.state.items.remove(atOffsets: indexSet)
//                    }
                }
            }
            .navigationTitle("Items")
            .tabViewStyle(.page)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isCreating = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreating) {
                NavigationStack {
//                    ItemEdit(item: .empty, onSubmit: { newItem in
////                        items.append(newItem)
//                    })
//                    .navigationTitle("Create new item")
                }
            }
        }
    }
}
