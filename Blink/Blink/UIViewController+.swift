//
//  UIViewController+.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/19.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message,
                                                    preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        self.present(alertViewController, animated: true, completion: nil)
    }
}
