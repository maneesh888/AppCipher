// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation
import Security
import CryptoKit

public struct AppCipher {
    
    private let keychainService = "com.appcipher.keychain"
    private let keychainAccount = "appcipherkey"
    
    public enum EncryptionAlgorithm {
        case AES256
        // Add more algorithms here in the future
    }
    
    public init () {
        
    }
    
    
    /// Encrypts the input string using the specified encryption algorithm and key.
    /// - Parameters:
    ///   - algorithm: The encryption algorithm to use (currently only AES256 is supported).
    ///   - key: The encryption key as a string. This will be used to derive the actual encryption key.
    ///   - input: The string to be encrypted.
    /// - Returns: A base64-encoded string containing the encrypted data, including nonce and authentication tag.
    /// - Throws: `CryptoError` if encryption fails.
    public func encrypt(algorithm: EncryptionAlgorithm, key: String, input: String) throws -> String {
        switch algorithm {
        case .AES256:
            return try encryptAES256(key: key, input: input)
        }
    }
    
    /// Decrypts the input base64-encoded string using the specified encryption algorithm and key.
    /// - Parameters:
    ///   - algorithm: The encryption algorithm used (currently only AES256 is supported).
    ///   - key: The decryption key as a string. This should be the same key used for encryption.
    ///   - encryptedBase64: The base64-encoded string containing the encrypted data, nonce, and authentication tag.
    /// - Returns: The decrypted string.
    /// - Throws: `CryptoError` if decryption fails or the input is invalid.
    public func decrypt(algorithm: EncryptionAlgorithm, key: String, encryptedBase64: String) throws -> String {
        switch algorithm {
        case .AES256:
            return try decryptAES256(key: key, encryptedBase64: encryptedBase64)
        }
    }
    
    /// Encrypts the input string using AES-256 in GCM mode.
    /// - Parameters:
    ///   - key: The encryption key as a string. This will be used to derive the actual encryption key.
    ///   - input: The string to be encrypted.
    /// - Returns: A base64-encoded string containing the encrypted data, including nonce and authentication tag.
    /// - Throws: `CryptoError` if encryption fails.
    private func encryptAES256(key: String, input: String) throws -> String {
        let key = deriveKey(from: key)
        let inputData = Data(input.utf8)
        
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(inputData, using: key, nonce: nonce)
        
        return sealedBox.combined!.base64EncodedString()
    }
    
    

    // MARK: - Public Methods
    
    /// Encrypts the input string using the specified encryption algorithm and key
    /// - Parameters:
    ///   - algorithm: The encryption algorithm to use
    ///   - key: The encryption key
    ///   - input: The string to be encrypted
    /// - Returns: A tuple containing the encrypted data and the initialization vector (IV)
    public func encrypt(algorithm: EncryptionAlgorithm, key: String, input: String) throws -> (combinedData: Data, iv: Data) {
        switch algorithm {
        case .AES256:
            return try encryptAES256(key: key, input: input)
        }
    }
    
    /// Decrypts the input data using the specified encryption algorithm, key, and IV
    /// - Parameters:
    ///   - algorithm: The encryption algorithm used
    ///   - key: The decryption key
    ///   - encryptedData: The data to be decrypted
    ///   - iv: The initialization vector used during encryption
    /// - Returns: The decrypted string
    public func decrypt(algorithm: EncryptionAlgorithm, key: String, combinedData: Data, iv: Data) throws -> String {
        switch algorithm {
        case .AES256:
            return try decryptAES256(key: key, combinedData: combinedData, iv: iv)
        }
    }
    
    /// Stores the encryption key securely in the iOS Keychain
    /// - Parameter key: The key to be stored
    public func storeKey(_ key: String) throws {
        guard let data = key.data(using: .utf8) else {
            print("Error converting key to data")
            throw CryptoError.keyChainError("Error converting key to data")
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        // First, try to delete any existing key
        SecItemDelete(query as CFDictionary)
        
        // Then, add the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("Key successfully stored in Keychain")
        } else {
            print("Error storing key in Keychain: \(status)")
            throw CryptoError.keyChainError("Key Store fail with status \(status)")
        }
    }
    
    /// Retrieves the stored encryption key from the iOS Keychain
    /// - Returns: The stored key, if available
    public func retrieveKey() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            print("Error retrieving key from Keychain: \(status)")
            if status == errSecItemNotFound {
                return nil
            }
            throw CryptoError.keyChainError("Error retrieving key from Keychain: \(status)")
        }
        
        guard let keyData = item as? Data,
              let key = String(data: keyData, encoding: .utf8) else {
            print("Error converting retrieved data to string")
            throw CryptoError.keyChainError("Error converting retrieved data to string")
        }
        
        return key
    }
    
    
    /// Removes the stored encryption key from the iOS Keychain
    public func removeKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            print("Key successfully removed from Keychain")
        } else {
            print("Error removing key from Keychain: \(status)")
        }
    }
    
    
    // MARK: - Private Methods
    /// Decrypts the input base64-encoded string that was encrypted using AES-256 in GCM mode.
    /// - Parameters:
    ///   - key: The decryption key as a string. This should be the same key used for encryption.
    ///   - encryptedBase64: The base64-encoded string containing the encrypted data, nonce, and authentication tag.
    /// - Returns: The decrypted string.
    /// - Throws: `CryptoError.invalidInput` if the input cannot be base64 decoded.
    ///           `CryptoError.decryptionFailed` if the decryption process fails or the result cannot be converted to a string.
    private func decryptAES256(key: String, encryptedBase64: String) throws -> String {
        guard let combinedData = Data(base64Encoded: encryptedBase64) else {
            throw CryptoError.invalidInput
        }
        
        let key = deriveKey(from: key)
        
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw CryptoError.decryptionFailed
        }
        
        return decryptedString
    }
    
    /// Encrypts the input string using AES-256 in GCM mode.
    /// - Parameters:
    ///   - key: The encryption key as a string. This will be used to derive the actual encryption key.
    ///   - input: The string to be encrypted.
    /// - Returns: A tuple containing:
    ///   - combinedData: The encrypted data combined with the authentication tag.
    ///   - iv: The initialization vector (nonce) used for encryption.
    /// - Throws: `CryptoError` if encryption fails.
    private func encryptAES256(key: String, input: String) throws -> (combinedData: Data, iv: Data) {
        let key = deriveKey(from: key)
        let inputData = Data(input.utf8)
        
        let iv = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(inputData, using: key, nonce: iv)
        
        // Combine ciphertext and tag
        let combinedData = sealedBox.ciphertext + sealedBox.tag
        
        return (combinedData, iv.withUnsafeBytes { Data($0) })
    }

    /// Decrypts the input data that was encrypted using AES-256 in GCM mode.
    /// - Parameters:
    ///   - key: The decryption key as a string. This should be the same key used for encryption.
    ///   - combinedData: The encrypted data combined with the authentication tag.
    ///   - iv: The initialization vector (nonce) used during encryption.
    /// - Returns: The decrypted string.
    /// - Throws:
    ///   - `CryptoError.decryptionFailed` if the decryption process fails or the result cannot be converted to a string.
    ///   - Other `CryptoKit` related errors if the nonce or sealed box creation fails.
    private func decryptAES256(key: String, combinedData: Data, iv: Data) throws -> String {
        let key = deriveKey(from: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        // Split combined data into ciphertext and tag
        let ciphertext = combinedData.dropLast(16)
        let tag = combinedData.suffix(16)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw CryptoError.decryptionFailed
        }
        
        return decryptedString
    }

    /// Derives a symmetric key from a password string using HKDF.
    /// - Parameter password: The password string to derive the key from.
    /// - Returns: A `SymmetricKey` suitable for use with AES-256 encryption.
    /// - Note: This function uses a fixed salt. For production use, consider using a unique salt for each key derivation.
    private func deriveKey(from password: String) -> SymmetricKey {
        let salt = "AppCipherSalt".data(using: .utf8)!
        let passwordData = Data(password.utf8)
        let key = HKDF<SHA256>.deriveKey(inputKeyMaterial: SymmetricKey(data: passwordData),
                                         salt: salt,
                                         outputByteCount: 32)
        return key
    }
    
    
    
}


enum CryptoError: Error {
    case invalidKey
    case encryptionFailed
    case decryptionFailed
    case invalidInput
    case keyChainError(String)
}
