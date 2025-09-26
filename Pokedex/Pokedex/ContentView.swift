//
//  ContentView.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/26/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Pokedex!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
