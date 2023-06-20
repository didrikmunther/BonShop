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

struct ListItemView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var list: ListElement
    @Binding var item: ListItemElement
    @State var isToggled: Bool = false
    
    init(list: Binding<ListElement>, item: Binding<ListItemElement>) {
        self._list = list
        self._item = item
        self.isToggled = item.wrappedValue.done
    }
    
    var body: some View {
        Toggle(isOn: $isToggled) {
            Text(item.item.name)
        }
        .toggleStyle(iOSCheckboxToggleStyle())
        .onChange(of: isToggled) { toggled in
            Task {
                await store.dispatch(.setListItemStatus(list: list.id, item: item.id, toggled: toggled))
            }
        }
    }
}

struct ListView: View {
    @Binding var list: ListElement
    @State private var multiSelection = Set<UUID>()
    
    var body: some View {
        List($list.items, selection: $multiSelection) { $item in
            ListItemView(list: $list, item: $item)
        }
    }
}

struct ListEditItem: View {
    @Binding var list: ListElement
    @Binding var item: ItemElement
    
    @EnvironmentObject private var store: AppStore
    
    private var isOn: Binding<Bool> { Binding(
        get: {
            if let _ = store.state.lists.first(where: { el in
                el.id == list.id
            }) {
                return true
            } else {
                return false
            }
        },
        set: { toggled in
            Task {
                await store.dispatch(.toggleListItem(list: list.id, item: item.id, toggled: toggled))
            }
        }
    )}
    
    var body: some View {
        Toggle(isOn: isOn) {
            Text(item.name)
        }
        
//        Toggle(isOn: Binding<Bool>(
//            get: {
//                $list.items.contains { listElement in
//                    listElement.item.id == item.id
//                }
//            }, set: {isActive in
//                if isActive {
//                    list.items.append(ListItemElement(item))
//                } else {
//                    if let index = list.items.firstIndex(where: {element in
//                        element.item.id == item.id
//                    }) {
//                        list.items.remove(at: index)
//                    }
//                }
//            }
//        )) {
//            Text(item.name)
//        }
    }
}

struct ListEdit: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var store: AppStore
    
    @Binding var list: ListElement
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.state.items) { item in
                    ListEditItem(list: $list, item: .constant(item))
                }
            }
            Button("Delete", role: .destructive) {
                Task {
                    await store.dispatch(.deleteList(list: list.id))
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
    @EnvironmentObject private var store: AppStore
    
    @State private var isAddingItems = false
    
    private var selectedList: Binding<Int> { Binding(
        get: {
            store.state.selectedList
        },
        set: { index in
            Task {
                await store.dispatch(.setSelectedListIndex(index: index))
            }
        }
    )}
    
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = .black.withAlphaComponent(0.2)
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: selectedList) {
                ForEach(Array(zip(store.state.lists.indices, store.state.lists)), id: \.0) { (index, list) in
                    ListView(list: .constant(list)).tag(index)
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
                        Task {
                            await store.dispatch(.addList)
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingItems) {
                ListEdit(list: .constant(store.state.activeList))
            }
        }
    }
}
