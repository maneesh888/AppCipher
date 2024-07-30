//
//  EncryptTextView.swift
//  App Cipher Samples
//
//  Created by Maneesh on 29/07/2024.
//

import SwiftUI
import AppCipher

struct EncryptTextView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var encryptedBase64: String = ""
    let appCipher = AppCipher()
    
    var body: some View {
        KeyboardDismissableView {
            VStack {
                Text("Encrypt Text")
                    .font(.largeTitle)
                    .padding()
                
                
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Button("Encrypt/Decrypt") {
                    encryptAndDecrypt()
                }
                .padding()
                
                TextEditor(text: $outputText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Button("Copy Encrypted Text") {
                    UIPasteboard.general.string = encryptedBase64
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func encryptAndDecrypt() {
       
        do {
            
            let key = try appCipher.retrieveKey()
            guard let key = key else {
                outputText = "Error: No encryption key found"
                return
            }
            
            // Encrypt
            encryptedBase64 = try appCipher.encrypt(algorithm: .AES256, key: key, input: inputText)
            
            // Decrypt (to verify)
            let decryptedText = try appCipher.decrypt(algorithm: .AES256, key: key, encryptedBase64: encryptedBase64)
            
            outputText = decryptedText
        } catch {
            outputText = "Encryption/Decryption error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    EncryptTextView()
}
