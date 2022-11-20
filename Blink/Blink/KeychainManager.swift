//
//  KeychainManager.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/19.
//

import Foundation

enum KeychainError: Error {
    case unknowned
}

final class KeychainManager {
    
    static let shared = KeychainManager()
    
    func createToken(key: Any, token: Any, completion: @escaping (Bool) -> Void) {
        let token = (token as AnyObject).data(using: String.Encoding.utf8.rawValue)!
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: token
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status == errSecSuccess {
            debugPrint("Keychain 저장 성공")
            completion(true)
        }
        else if status == errSecDuplicateItem {
            let state = updateToken(key: key, token: token)
            completion(state)
        }
        else {
            debugPrint("Keychian 저장 Error")
            completion(false)
        }
    }
    
    func getToken(key: Any) -> Any? {
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let result = SecItemCopyMatching(getQuery as CFDictionary, &item)
        if result == errSecSuccess {
            if let existingItem = item as? [String: Any],
               let data = existingItem[kSecValueData as String] as? Data,
               let token = String(data: data, encoding: .utf8) {
                return token
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func updateToken(key: Any, token: Any) -> Bool {
        let prevQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
      
        let updateQuery: [String: Any] = [
            kSecValueData as String: token as Any
        ]
        
        let status = SecItemUpdate(prevQuery as CFDictionary, updateQuery as CFDictionary)
        if status == errSecSuccess {
            debugPrint("Keychain Update Success")
            return true
        } else {
            debugPrint("Keychain Update Failed")
            return false
        }
    }
    
    func deleteToken(key: Any) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            debugPrint("Keychain Delete Success")
        } else {
            debugPrint("Keychain Delete Failed")
        }
    }
}
