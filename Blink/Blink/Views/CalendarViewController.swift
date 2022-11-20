//
//  CalendarViewController.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/20.
//

import UIKit

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        setTitleLabel()
    }
    
}

extension CalendarViewController {
    private func setTitleLabel() {
        print("진입")
        guard let userName = UserDefaultsManager.shared.getUserDefaultsObject(forKey: "userName") as? String else { return }
        titleLabel.text = "\(userName)님의 기록"
        print(userName)
    }
}
