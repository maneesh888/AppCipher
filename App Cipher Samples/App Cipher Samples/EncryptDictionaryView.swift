//
//  EncryptDictionaryView.swift
//  App Cipher Samples
//
//  Created by Maneesh on 29/07/2024.
//

import SwiftUI
import AppCipher

struct KeyValuePair: Identifiable {
    let id = UUID()
    var key: String = ""
    var value: String = ""
}

struct EncryptDictionaryView: View {
    @State private var keyValuePairs: [KeyValuePair] = []
    @State private var outputText: String = ""
    @State private var combinedData: Data?
    @State private var iv: Data?
    let appCipher = AppCipher()
    
    var body: some View {
        KeyboardDismissableView {
            ScrollView {
                VStack {
                    Text("Encrypt Dictionary")
                        .font(.largeTitle)
                        .padding()
                    
                    ForEach(keyValuePairs.indices, id: \.self) { index in
                        HStack {
                            TextField("Key", text: $keyValuePairs[index].key)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Value", text: $keyValuePairs[index].value)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                removeKeyValuePair(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: addKeyValuePair) {
                        Text("Add Key-Value Pair")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Button("Encrypt") {
                        encryptDictionary()
                    }
                    .padding()
                    
                    TextEditor(text: $outputText)
                        .frame(height: 200)
                        .border(Color.gray, width: 1)
                        .padding()
                    
                    Button("Copy Encrypted Text") {
                        if let combinedData = combinedData, let iv = iv {
                            let combined = combinedData + iv
                            UIPasteboard.general.string = combined.base64EncodedString()
                        }
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
    
    private func addKeyValuePair() {
        keyValuePairs.append(KeyValuePair())
    }
    
    private func removeKeyValuePair(at index: Int) {
        keyValuePairs.remove(at: index)
    }
    
    private func encryptDictionary() {
        let validPairs = keyValuePairs.filter { !$0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let dictionary = Dictionary(uniqueKeysWithValues: validPairs.map { ($0.key.trimmingCharacters(in: .whitespacesAndNewlines), $0.value) })
        
        guard !dictionary.isEmpty else {
            outputText = "Error: No valid key-value pairs to encrypt"
            return
        }
        
        guard let jsonString = dictionaryToJSONString(dictionary) else {
            outputText = "Error: Unable to convert dictionary to JSON"
            return
        }
        
        
        do {
            
            let key = try appCipher.retrieveKey()
            guard let key = key else {
                outputText = "Error: No encryption key found"
                return
            }
            let encryptedBase64: String = try appCipher.encrypt(algorithm: .AES256, key: key, input: jsonString)
            
            if let prettyJSON = prettyPrintJSON(jsonString) {
                outputText = "Encrypted JSON:\n\n\(prettyJSON)\n\nEncrypted Base64:\n\(encryptedBase64)"
            } else {
                outputText = "Encrypted successfully, but unable to format JSON\n\nEncrypted Base64:\n\(encryptedBase64)"
            }
            
            UIPasteboard.general.string = encryptedBase64
        } catch {
            outputText = "Encryption error: \(error.localizedDescription)"
        }
    }
    
    private func dictionaryToJSONString(_ dictionary: [String: String]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error converting dictionary to JSON: \(error)")
            return nil
        }
    }
    
    private func prettyPrintJSON(_ jsonString: String) -> String? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            return String(data: prettyJsonData, encoding: .utf8)
        } catch {
            print("Error pretty printing JSON: \(error)")
            return nil
        }
    }
}

#Preview {
    EncryptDictionaryView()
}
