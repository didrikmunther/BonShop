//
//  ContentView.swift
//  BonShop
//
//  Created by Didrik Munther on 2023-06-16.
//

import SwiftUI

struct ContentView: View {
    @StateObject var state = AppState()
    
    var body: some View {
        #if os(iOS)
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
        .environmentObject(state)
        #else
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Hejsan")
                        .font(.title)
                }
                
                HStack {
                    Text("Park")
                    Spacer()
                    Text("State")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text("About \("Hejsan")")
                    .font(.title2)
                Text("Description")
            }
            .padding()
            .frame(maxWidth: 400)
        }
        .navigationTitle("Hejsan")
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
