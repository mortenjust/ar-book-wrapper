//
//  ViewController.swift
//  book-ar
//
//  Created by Morten Just Petersen on 8/13/18.
//  Copyright © 2018 Morten Just Petersen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit
import WebKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var lightNodes = [SCNNode]()
    
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
   
    override var prefersStatusBarHidden: Bool { return  true }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        setupCamera()
        setupLights()
        
//        sceneView.showsStatistics = true
    }
    func setupCamera(){
        let camera = self.sceneView.pointOfView?.camera!
//        camera?.wantsHDR = true
        camera?.motionBlurIntensity = 1
        camera?.wantsDepthOfField = true
    }
    
    func setupLights(){
        let lightScene = SCNScene(named: "art.scnassets/Light Scene.scn")!
        
        lightNodes.append(lightScene.rootNode.childNode(withName: "light1", recursively: true)!)
        lightNodes.append(lightScene.rootNode.childNode(withName: "light2", recursively: true)!)
        
        for light in self.lightNodes {
            let l = light.light
            l?.castsShadow = true
            l?.shadowSampleCount = 20
            l?.shadowRadius = 30
            light.light = l
            self.sceneView.scene.rootNode.addChildNode(light)
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages  = 25
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateLightNodesLightEstimation()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("Did remove node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
//        updateQueue.async {

            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            print("Looking for the book named \(referenceImage.name!)")
            let foundBook = bookStore.findBook(by: referenceImage.name!)
        self.addBookOverlay(to: planeNode, for: foundBook, with: referenceImage)
//        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: Book  helper
    
    func addBookOverlay(to node:SCNNode, for book:Book, with referenceImage:ARReferenceImage){
        DispatchQueue.main.async {
            let webPlaneNode = node
            
            webPlaneNode.opacity = 0
    //        let webPlaneNode = SCNNode()
            
            print("Setting sizes to reference image \(referenceImage.physicalSize)")
//            let bookWidth :  CGFloat = referenceImage.physicalSize.width
//            let bookHeight : CGFloat = referenceImage.physicalSize.height

            
            // weirdly crashes if there are too many decimal places
            let bookWidth :  CGFloat = self.round3(for: referenceImage.physicalSize.width + 0.02)
            let bookHeight : CGFloat = self.round3(for: referenceImage.physicalSize.height)
            let bookDepth : CGFloat  = 0.02
            
            print("width : \(bookWidth) height \(bookHeight)")
            
            // also crashes if ratio is too weird
            let ratio = self.round3(for: (bookWidth / bookHeight))
            
            print("Setting geometry for webplanenode")
//            webPlaneNode.geometry = SCNPlane(width: bookWidth, height: bookHeight)
            webPlaneNode.geometry = SCNBox(width: bookWidth, height: bookHeight, length: bookDepth, chamferRadius: 0.01)
            
            webPlaneNode.localTranslate(by: SCNVector3(0, 0, -(bookDepth/3))) // 3 to avoid clipping
            
            print("instantiating webview")
            DispatchQueue.main.async {

            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 320 * ratio, height: 320))
            webView.delegate = self
            print("rotating")
            webPlaneNode.eulerAngles.x = -.pi / 2
        
            print("adding webview as material")
            webPlaneNode.geometry?.firstMaterial?.diffuse.contents = webView
//              webPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
              webPlaneNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
              webPlaneNode.geometry?.firstMaterial?.metalness.contents = NSNumber(value: 0.5)
              webPlaneNode.geometry?.firstMaterial?.roughness.contents = NSNumber(value: 0.0)
       
                
//              webPlaneNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white

                
            let req  = URLRequest(url: book.url.url)
                print("loading webview")
                webView.loadRequest(req)
            }
            
            webPlaneNode.runAction(SCNAction.fadeIn(duration: 2))
        }
        
    }


    func inchToMeter(inch : CGFloat) -> CGFloat {
        let m = Measurement.init(value: Double(inch), unit: UnitLength.inches)
        let res = m.converted(to: .meters).value
        return CGFloat(res)
    }
    
    
    // MARK: Lightning
    
    func getLightNode() -> SCNNode {
        let light = SCNLight()
        light.type = .directional
        light.intensity = 1000
        light.temperature = 0
        light.castsShadow = true
        light.shadowRadius = 15.0
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(1, 1, 1)
        return lightNode
    }
    
    func addLightNodeTo(_ node: SCNNode) {
        let lightNode = getLightNode()
        node.addChildNode(lightNode)
        lightNodes.append(lightNode)
    }
    
    func updateLightNodesLightEstimation() {
        DispatchQueue.main.async {
            let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate
            let ambientIntensity = lightEstimate?.ambientIntensity
            let ambientColorTemperature = lightEstimate?.ambientColorTemperature
            
            for lightNode in self.lightNodes {
                guard let light = lightNode.light else { continue }
                
                if let am = ambientIntensity {
                    light.intensity = am
                }
                
                if let amtemp = ambientColorTemperature {
                    light.temperature = amtemp
                }
            }
        }
    }
    
    func round3(for d:CGFloat) -> CGFloat {
        return CGFloat(round(1000.0 * d)/1000.0)
    }
}


extension ViewController : UIWebViewDelegate {
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        print("webViewDidFinishLoad")
//    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        let js = "window.scrollBy(0,14)"
        
        DispatchQueue.main.async {
            webView.stringByEvaluatingJavaScript(from: js)
        }
    }
}


