//
//  App_Cipher_SamplesTests.swift
//  App Cipher SamplesTests
//
//  Created by Maneesh on 29/07/2024.
//

import XCTest
@testable import App_Cipher_Samples
@testable import AppCipher
import CryptoKit

final class App_Cipher_SamplesTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    var appCipher: AppCipher!
    
    override func setUp() {
        super.setUp()
        appCipher = AppCipher()
    }
    
    override func tearDown() {
        appCipher = nil
        super.tearDown()
    }
    
    func testEncryptDecrypt() {
        let key = "testKey123"
        let input = "Hello, World!"
        
        do {
            let encrypted: String = try appCipher.encrypt(algorithm: .AES256, key: key, input: input)
            XCTAssertNotEqual(encrypted, input, "Encrypted text should not be equal to input")
            
            let decrypted = try appCipher.decrypt(algorithm: .AES256, key: key, encryptedBase64: encrypted)
            XCTAssertEqual(decrypted, input, "Decrypted text should match original input")
        } catch {
            XCTFail("Encryption/Decryption failed with error: \(error)")
        }
    }
    
    func testEncryptDecryptLongText() {
        let key = "longTestKey12345"
        let input = String(repeating: "Lorem ipsum dolor sit amet. ", count: 100)
        
        do {
            let encrypted: String = try appCipher.encrypt(algorithm: .AES256, key: key, input: input)
            XCTAssertNotEqual(encrypted, input, "Encrypted text should not be equal to input")
            
            let decrypted = try appCipher.decrypt(algorithm: .AES256, key: key, encryptedBase64: encrypted)
            XCTAssertEqual(decrypted, input, "Decrypted text should match original input")
        } catch {
            XCTFail("Encryption/Decryption of long text failed with error: \(error)")
        }
    }
    
    func testEncryptDecryptWithSpecialCharacters() {
        let key = "special!@#$%^&*()_+"
        let input = "Hello, World! 123 !@#$%^&*()_+"
        
        do {
            let encrypted: String = try appCipher.encrypt(algorithm: .AES256, key: key, input: input)
            XCTAssertNotEqual(encrypted, input, "Encrypted text should not be equal to input")
            
            let decrypted = try appCipher.decrypt(algorithm: .AES256, key: key, encryptedBase64: encrypted)
            XCTAssertEqual(decrypted, input, "Decrypted text should match original input")
        } catch {
            XCTFail("Encryption/Decryption with special characters failed with error: \(error)")
        }
    }
    
    func testDecryptWithWrongKey() {
        let correctKey = "correctKey123"
        let wrongKey = "wrongKey456"
        let input = "Secret message"
        
        do {
            let encrypted: String = try appCipher.encrypt(algorithm: .AES256, key: correctKey, input: input)
            XCTAssertThrowsError(try appCipher.decrypt(algorithm: .AES256, key: wrongKey, encryptedBase64: encrypted)) { error in
                XCTAssertEqual(error._domain, CryptoKitError.authenticationFailure._domain, "Error domain mismatch")
                
            }
        } catch {
            XCTFail("Encryption failed with error: \(error)")
        }
    }
    
    func testDecryptWithInvalidInput() {
        let key = "testKey123"
        let invalidInput = "This is not a valid base64 encoded string!"
        
        XCTAssertThrowsError(try appCipher.decrypt(algorithm: .AES256, key: key, encryptedBase64: invalidInput)) { error in
            XCTAssertTrue(error is CryptoError, "Error should be of type CryptoError")
        }
    }
    
    
    func testStoreAndRetrieveKey() {
        
        let key = "secretKey123"
        
        XCTAssertNoThrow(try appCipher.storeKey(key))
        do {
            let retrievedKey = try appCipher.retrieveKey()
            XCTAssertEqual(retrievedKey, key, "Retrieved key should match stored key")
        }catch {
            XCTFail("Key retieval failed")
        }

    }
    
    func testRemoveKey() {
        let key = "temporaryKey456"
        
        XCTAssertNoThrow(try appCipher.storeKey(key))
        
        appCipher.removeKey()
        do {
            let retrievedKey = try appCipher.retrieveKey()
            XCTAssertNil(retrievedKey, "Key should be removed")
        }catch {
            XCTFail("Key retieval failed")
        }
        
    }
}

