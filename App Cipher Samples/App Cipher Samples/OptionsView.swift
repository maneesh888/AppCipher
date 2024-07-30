//
//  HomeSwiftUIView.swift
//  App Cipher Samples
//
//  Created by Maneesh on 29/07/2024.
//

import SwiftUI
import AppCipher

struct OptionsView: View {
    @EnvironmentObject var appState: AppState
    let appCipher = AppCipher()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Options")
                    .font(.largeTitle)
                    .padding()
                
                VStack(spacing: 20) {
                    NavigationLink(destination: EncryptTextView()) {
                        Text("Encrypt Text")
                            .frame(minWidth: 200)
                    }
                    .buttonStyle(.bordered)
                    
                    NavigationLink(destination: EncryptDictionaryView()) {
                                        Text("Encrypt Dictionary")
                                            .frame(minWidth: 200)
                                    }
                                    .buttonStyle(.bordered)
            
                   
                    Spacer()
                    
                    NavigationLink(destination: DecryptTextView()) {
                                       Text("Decrypt Text")
                                           .frame(minWidth: 200)
                                   }
                                   .buttonStyle(.bordered)
                }
                .padding()
                
                Spacer()
                
                Button("Remove Key") {
                    appCipher.removeKey()
                    appState.hasKey = false
                }
                .foregroundColor(.red)
                .padding()
            }
        }
    }
}

#Preview {
    OptionsView()
}
