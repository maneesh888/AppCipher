//
//  DecryptTextView.swift
//  App Cipher Samples
//
//  Created by Maneesh on 29/07/2024.
//

import SwiftUI
import AppCipher

struct DecryptTextView: View {
    @State private var inputCipherText: String = ""
    @State private var outputText: String = ""
    let appCipher = AppCipher()
    
    var body: some View {
        KeyboardDismissableView {
            VStack {
                Text("Decrypt Text")
                    .font(.largeTitle)
                    .padding()
                
                TextEditor(text: $inputCipherText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Button("Decrypt") {
                    decryptText()
                }
                .padding()
                
                TextEditor(text: $outputText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func decryptText() {
        
        
        do {
            let key = try appCipher.retrieveKey()
            guard let key = key else {
                print("No key found")
                return
            }
            let decryptedText = try appCipher.decrypt(algorithm: .AES256, key: key, encryptedBase64: inputCipherText)
            outputText = decryptedText
        } catch {
            print("Decryption error: \(error)")
            outputText = "Error: \(error.localizedDescription)"
        }
    }
}
#Preview {
    DecryptTextView()
}
