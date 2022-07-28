//
//  ViewController.swift
//  ARKit Distance Demo
//
//  Created by Diego Craveiro Chaves on 28/7/2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 { resetDots() }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                let results = sceneView.session.raycast(query)
                
                if let firstResult = results.first {
                    addDot(at: firstResult)
                }
            }
        }
    }
    
    func addDot( at raycastResult: ARRaycastResult ) {
         // the size of the green circle
         let dotGeometry = SCNSphere(radius: 0.005)
         
         let material = SCNMaterial()
         material.diffuse.contents = UIColor.systemGreen
         
         dotGeometry.materials = [material]

         // the "dot" element
         let dotNode = SCNNode(geometry: dotGeometry)
         dotNode.position = SCNVector3(
             raycastResult.worldTransform.columns.3.x,
             raycastResult.worldTransform.columns.3.y,
             raycastResult.worldTransform.columns.3.z)
         
         sceneView.scene.rootNode.addChildNode(dotNode)
         
         dotNodes.append(dotNode)

         // we have 2 points on scree, try to calculate distance
         if dotNodes.count >= 2 {
             calculateDistance()
         }
     }
    
    func resetDots() {
         for dot in dotNodes {
             dot.removeFromParentNode()
         }
         dotNodes = [SCNNode]()
    }
    
    func calculateDistance() {
        let start = dotNodes.first!
        let end = dotNodes.last!
        
        var distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        // convert to cm
        distance *= 100
    
        let distanceFormatted = String(format: "%.2f cm", abs(distance))
        updateText(text: distanceFormatted, atPosition: end.position)
    }
    
    func updateText( text: String, atPosition: SCNVector3 ) {
         textNode.removeFromParentNode()
     
         let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
         textGeometry.firstMaterial?.diffuse.contents = UIColor.systemRed
         
         textNode = SCNNode(geometry: textGeometry)
         textNode.position = SCNVector3(
             atPosition.x,
             atPosition.y + 0.01,
             atPosition.z
         )
     
         textNode.scale = SCNVector3(0.01, 0.01, 0.01)
         sceneView.scene.rootNode.addChildNode(textNode)
     }
}
