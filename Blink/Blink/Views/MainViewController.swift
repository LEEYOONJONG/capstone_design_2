//
//  ViewController.swift
//  Blink
//
//  Created by YOONJONG on 2022/10/27.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import FirebaseDatabase

final class MainViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var blinkCountLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    private var contentNode: SCNReferenceNode?
    private var blinked: Bool = false
    private var cnt:Int = 0
    private var leftSeconds: Int = 60
    private var isLighted: Bool = true
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private var originalSource:Any?
    private var timer: Timer?
    
    private var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userIdentifier = KeychainManager.shared.getToken(key: "loginToken") as? String else { return }
        print(userIdentifier)
        setButtonState()
        setButtonLayout()
        setGradientView()
        requestAuthNotification()
        ref = Database.database().reference()
        debugPrint("지원 여부", ARFaceTrackingConfiguration.isSupported)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupSceneView()
        cnt = 0
        leftSeconds = 60
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerProcess), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        sceneView.session.pause()
        timer?.invalidate()
    }
    
    
    @IBAction func bultButtonTapped(_ sender: Any) {
        if isLighted { // 켜져 있다면 끄기
            lightButton.setImage(UIImage(systemName: "lightbulb.fill"), for: .normal)
            setSceneBackground(to: false)
            isLighted = false
        } else { // 꺼져 있다면 키기
            lightButton.setImage(UIImage(systemName: "lightbulb.slash"), for: .normal)
            setSceneBackground(to: true)
            isLighted = true
        }
        setButtonLayout()
    }
    
    @IBAction func calendarButtonTapped(_ sender: Any) {
        guard let calendarViewController = storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController else { return }
        self.present(calendarViewController, animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        KeychainManager.shared.deleteToken(key: "loginToken")
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            print("네비게이션이 없음")
            guard let authViewController = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
            changeRootViewController(authViewController)
        }
    }
}

extension MainViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: faceAnchor.geometry)
        let blendShapes = faceAnchor.blendShapes
        if let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
           let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float {
            blinkProcess(eyeBlinkLeft: eyeBlinkLeft, eyeBlinkRight: eyeBlinkRight)
        }
    }
    
    private func blinkProcess(eyeBlinkLeft: Float, eyeBlinkRight: Float) {
        if eyeBlinkLeft > 0.8 && eyeBlinkRight > 0.8 && !blinked {
            cnt += 1
            DispatchQueue.main.async {
                self.blinkCountLabel.text = "\(self.cnt)번 깜빡임"
                self.progressView.setProgress(Float(self.cnt)/Float(12), animated: true)
                if self.cnt < 12 && self.cnt > 6 {
                    self.progressView.progressTintColor = .systemYellow
                } else if self.cnt >= 12 {
                    self.progressView.progressTintColor = .systemMint
                } else {
                    self.progressView.progressTintColor = .systemRed
                }
            }
#if DEBUG
            debugPrint("\(cnt)번 감았음")
#endif
            blinked = true
            // 1초에 한번씩만 눈깜빡임 인식
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1) {
                self.blinked = false
            }
        }
    }
}

extension MainViewController {
    private func changeRootViewController(_ viewControllerToPresent: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UINavigationController(rootViewController: viewControllerToPresent)
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        } else {
            viewControllerToPresent.modalPresentationStyle = .overFullScreen
            self.present(viewControllerToPresent, animated: true, completion: nil)
        }
    }
    
    private func periodicCheck() {
#if DEBUG
        debugPrint("분 초기화")
#endif
        if 0 < cnt {
            sendToDatabase(cnt: cnt)
        }
        
        if 0 < cnt && cnt <= 6 {
            AudioServicesPlaySystemSound(1016)
            requestSendNotification(blinkCount: cnt, notifyString: "🚨 위험합니다!")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else if 6 < cnt && cnt < 12 {
            requestSendNotification(blinkCount: cnt, notifyString: "조심하세요!")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        cnt = 0
        progressView.setProgress(0, animated: false)
        progressView.progressTintColor = .systemRed
        blinkCountLabel.text = ""
    }
    
    @objc private func timerProcess() {
        leftSeconds -= 1
        if leftSeconds < 0 {
            leftSeconds = 60;
            periodicCheck()
        }
        
        self.timerLabel.text = "\(leftSeconds)"
    }
    
    private func setupSceneView() {
        sceneView.delegate = self
    }
    
    private func resetTracking() {
        let configuration = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setButtonState() {
        // 전구 버튼
        isLighted = true
        if isLighted {
            lightButton.setImage(UIImage(systemName: "lightbulb.slash"), for: .normal)
            isLighted = true
        } else {
            lightButton.setImage(UIImage(systemName: "lightbulb.fill"), for: .normal)
            isLighted = false
        }
    }
    
    private func setButtonLayout() {
        // 전구 버튼
        lightButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lightButton.widthAnchor.constraint(equalToConstant: 50),
            lightButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        lightButton.tintColor = .systemYellow
        lightButton.layer.cornerRadius = 25
        lightButton.clipsToBounds = true
        lightButton.backgroundColor = .black
        lightButton.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        // 달력 버튼
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarButton.widthAnchor.constraint(equalToConstant: 50),
            calendarButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        calendarButton.tintColor = .systemMint
        calendarButton.layer.cornerRadius = 25
        calendarButton.clipsToBounds = true
        calendarButton.backgroundColor = .black
        calendarButton.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        // 로그아웃 버튼
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 50),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        logoutButton.tintColor = .systemGray
        logoutButton.layer.cornerRadius = 25
        logoutButton.clipsToBounds = true
        logoutButton.backgroundColor = .black
        logoutButton.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        
        // 전구 켜짐 여부에 따라 테두리 변경
        if !isLighted {
            lightButton.layer.borderWidth = 2
            calendarButton.layer.borderWidth = 2
        } else {
            lightButton.layer.borderWidth = 0
            calendarButton.layer.borderWidth = 0
        }
    }
    
    private func setSceneBackground(to willBeOn: Bool) {
        if !willBeOn {
            originalSource = sceneView.scene.background.contents
            sceneView.scene.background.contents = UIColor.black
        } else {
            sceneView.scene.background.contents = originalSource
        }
    }
    
    private func setGradientView() {
        gradientView.setGradient(color1: .clear, color2: .black)
    }
    
    // 사용자에게 알림 권한 요청
    func requestAuthNotification() {
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .sound])
        userNotificationCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
            if let error = error {
                print(#function, error)
            }
        }
    }
    
    // 알림 전송
    func requestSendNotification(blinkCount: Int, notifyString: String) {
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "\(blinkCount)번 깜빡임"
        notiContent.body = notifyString
        
        let request = UNNotificationRequest(
            identifier: "BlinkNotification",
            content: notiContent,
            trigger: nil
        )
        
        userNotificationCenter.add(request)
    }
    
    func sendToDatabase(cnt: Int) {
        // date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        let date = dateFormatter.string(from: Date())
        
        // minute
        let minuteFormatter = DateFormatter()
        minuteFormatter.dateFormat = "HH:mm"
        let minute = minuteFormatter.string(from: Date())
        
        // user
        guard var userIdentifier = KeychainManager.shared.getToken(key: "loginToken") as? String else { return }
        userIdentifier = userIdentifier.components(separatedBy: [".", "#", "$", "[", "]"]).joined()
        
        // db
        ref.child("users").child("\(userIdentifier)").child(date).child(minute).setValue(["count": cnt])
    }
}
