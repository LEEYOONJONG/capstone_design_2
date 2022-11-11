//
//  ViewController.swift
//  Blink
//
//  Created by YOONJONG on 2022/10/27.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var contentNode: SCNReferenceNode?
    lazy var eyeLeftNode = contentNode?.childNode(withName: "eyeLeft", recursively: true)
    lazy var eyeRightNode = contentNode?.childNode(withName: "eyeRight", recursively: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        debugPrint(ARFaceTrackingConfiguration.isSupported)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let resourceName = "robotHead"
        guard anchor is ARFaceAnchor,
              let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "Models.scnassets") else { return nil }
        contentNode = SCNReferenceNode(url: url)
        contentNode?.load()
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        let blendShapes = faceAnchor.blendShapes
        if let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
           let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float {
            eyeLeftNode?.scale.z = 1 - eyeBlinkLeft
            eyeRightNode?.scale.z = 1 - eyeBlinkRight
        }
    }
}

extension ViewController {
    
    private func setupSceneView() {
        sceneView.delegate = self
    }
    
    private func resetTracking() {
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
