//
//  UserDefaultsManager.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/19.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    func setUserDefaults(_ value: Any, forKey defaultsKey: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: defaultsKey)
    }
    
    func getUserDefaultsObject(forKey defaultsKey: String) -> Any? {
        let defaults = UserDefaults.standard
        if let object = defaults.object(forKey: defaultsKey) {
            return object
        } else {
            return nil
        }
    }
    
    func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
    
}
