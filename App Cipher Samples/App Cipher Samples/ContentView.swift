//
//  ContentView.swift
//  App Cipher Samples
//
//  Created by Maneesh on 29/07/2024.
//

import SwiftUI
import AppCipher

class AppState: ObservableObject {
    @Published var hasKey: Bool
    
    init() {
        do {
            self.hasKey = try AppCipher().retrieveKey() != nil
        }catch {
            self.hasKey = false
        }
    }
}

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var key: String = ""
    @State private var statusMessage: String = ""
    let appCipher = AppCipher()
    
    var body: some View {
        NavigationView {
            if appState.hasKey {
                OptionsView()
                    .environmentObject(appState)
            } else {
                VStack {
                    TextField("Enter encryption key", text: $key)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Save Key") {
                        do {
                            try appCipher.storeKey(key)
                            appState.hasKey = true
                        }catch {
                            statusMessage = error.localizedDescription
                        }
                    }
                    .padding()
                    
                    Text(statusMessage)
                    .foregroundColor(.red)
                    
                }
                .navigationTitle("App Cipher")
            }
        }
    }
}

#Preview {
    ContentView()
}
