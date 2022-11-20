//
//  CalendarViewController.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/20.
//

import UIKit
import FirebaseDatabase

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    private var ref: DatabaseReference!
    
    override func viewDidLoad() {
        setTitleLabel()
        ref = Database.database().reference()
        getData()
    }
    
}

extension CalendarViewController {
    private func setTitleLabel() {
        print("진입")
        guard let userName = UserDefaultsManager.shared.getUserDefaultsObject(forKey: "userName") as? String else { return }
        titleLabel.text = "\(userName)님의 기록"
        print(userName)
    }
    
    private func getData() {
        guard var userIdentifier = KeychainManager.shared.getToken(key: "loginToken") as? String else { return }
        userIdentifier = userIdentifier.components(separatedBy: [".", "#", "$", "[", "]"]).joined() // TODO: Keychain에 저장 시 특이 문자 제거
        
        // date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        let date = dateFormatter.string(from: Date())
        
        // ref.child("users").child("\(userIdentifier)").child(date).child(minute).setValue(["count": cnt])
        ref.child("users").child(userIdentifier).child(date).getData { error, snapshot in
            guard error == nil else { return }
            let val = snapshot?.value as! [String: [String: Any]]
            let sortedValue = val.sorted { $0.0 < $1.0 } // 시간 순(key)대로 정렬
            
            for (timeValue, countValue) in sortedValue {
                let cnt = countValue["count"] as! Int
                print("시각: \(timeValue), 카운트: \(cnt)")
            }
        }
        
    }
}
