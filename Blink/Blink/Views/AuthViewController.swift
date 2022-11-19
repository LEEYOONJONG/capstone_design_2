//
//  AuthViewController.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/19.
//

import UIKit
import AuthenticationServices

final class AuthViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppleSignInButton()
    }
}

extension AuthViewController {
    private func setAppleSignInButton() {
        let appleSignInButton = UIButton()
        appleSignInButton.backgroundColor = .white
        appleSignInButton.setTitle(" Apple로 로그인", for: .normal)
        appleSignInButton.setTitleColor(.black, for: .normal)
        appleSignInButton.layer.cornerRadius = 25
        
        
        appleSignInButton.addTarget(self, action: #selector(appleSignInButtonTapped), for: .touchUpInside)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appleSignInButton)
        NSLayoutConstraint.activate([
            appleSignInButton.widthAnchor.constraint(equalToConstant: 240),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        ])
    }
    
    @objc func appleSignInButtonTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate {
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            // Apple ID
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // 계정 정보 가져오기
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User ID : \(userIdentifier)")
            print("User Email : \(email ?? "")")
            print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
            
            // Keychain에 저장
            KeychainManager.shared.createToken(key: "loginToken", token: userIdentifier) { result in
                if result {
                    if let fullName = fullName,
                       let familyName = fullName.familyName,
                       let givenName = fullName.givenName
                    {
                        UserDefaultsManager.shared.setUserDefaults(familyName+givenName, forKey: "userName")
                    }
                    guard let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return }
                    self.navigationController?.pushViewController(mainViewController, animated: true)
                } else {
                    self.presentAlert(title: "토큰 저장 오류", message: "토큰을 저장할 수 없습니다.")
                }
            }
            
        default:
            break
        }
    }
    
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        self.presentAlert(title: "로그인 오류", message: "애플 로그인을 진행할 수 없습니다. 네트워크 환경을 확인해주세요.")
    }
}
