//
//  Items.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-19.
//

import SwiftUI

typealias ItemID = UUID

struct ItemElement: Equatable, Identifiable, Hashable {
    var baseName: String
    let id: ItemID
    var deleted: Bool = false
    
    var name: String {
        if !deleted {
            return baseName
        } else {
            return "\(baseName) (Deleted)"
        }
    }
    
    init(_ name: String, id: ItemID = ItemID()) {
        self.baseName = name
        self.id = id
    }
    
    static var empty: ItemElement {
        ItemElement("")
    }
}

struct ItemEdit: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var state: AppState
    
    @State var item: ItemElement
    var onSubmit: (ItemElement) async -> Void = {item in}
    var onDelete: (ItemElement) async -> Void = {item in}
    var onRestore: (ItemElement) async -> Void = {item in}
    
    var body: some View {
        Form {
            Section(header: Text("Item")) {
                TextField("Name of item", text: $item.baseName)
                
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
        
        if item.deleted {
            Button("Restore") {
                Task {
                    item.deleted = false
                    await onRestore(item)
                    dismiss()
                }
            }
        }
        else {
//            Button("Delete", role: .destructive) {
//                Task {
//                    item.deleted = true
//                    await onDelete(item)
//                    dismiss()
//                }
//            }
        }
    }
}

struct ItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var state: AppState
    
    @Binding var item: ItemElement
    @State var isEditing: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Item")) {
                Text(item.baseName)
            }
            
            if item.deleted {
                Section(header: Text("Status")) {
                    Text("Item is deleted")
                        .foregroundColor(.red)
                }
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
                ItemEdit(item: item,
                         onSubmit: state.updateItem,
                         onDelete: state.updateItem,
                         onRestore: state.updateItem)
                .navigationTitle("Edit item")
            }
        }
    }
}

struct ItemsView: View {
    @EnvironmentObject private var state: AppState
    
    @State private var isCreating: Bool = false
    
    var body: some View {
        NavigationStack {
            TabView {
                List {
                    let items = $state.items.filter({ $item in
                        !item.deleted
                    })
                    
                    ForEach(items) { $item in
                        NavigationLink(destination: ItemView(item: $item)) {
                            Text(item.name)
                        }
                    }
                    .onMove { fromOffsets, toOffset in
                        state.moveItems(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { indexSet in
                        state.deleteItems(atOffsets: indexSet)
                    }
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
                    ItemEdit(item: .empty, onSubmit: state.addItem)
                    .navigationTitle("Create new item")
                }
            }
        }
    }
}
