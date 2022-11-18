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

final class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var blinkCountLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    private var contentNode: SCNReferenceNode?
    private var blinked: Bool = false
    private var cnt:Int = 0
    private var isLighted: Bool = true
    private let userNotificationCenter = UNUserNotificationCenter.current()
    private var originalSource:Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setButtonState()
        setButtonLayout()
        setGradientView()
        debugPrint("지원 여부", ARFaceTrackingConfiguration.isSupported)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cnt = 0
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(periodicCheck), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
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
}

extension ViewController: ARSCNViewDelegate{
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

extension ViewController {
    
    @objc private func periodicCheck() {
#if DEBUG
        debugPrint("분 초기화")
#endif
        if cnt <= 6 {
            AudioServicesPlaySystemSound(1016)
        } else if cnt <= 12 {
        }
        cnt = 0
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
    
}
