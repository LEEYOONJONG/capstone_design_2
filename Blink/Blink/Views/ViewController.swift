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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(ARFaceTrackingConfiguration.isSupported)
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let resourceName = "robotHead"
        guard anchor is ARFaceAnchor,
              let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "Models.scnassets") else { return nil }
        let contentNode = SCNReferenceNode(url: url)
        contentNode?.load()
        return contentNode
    }
}

extension ViewController {
    private func resetTracking() {
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
