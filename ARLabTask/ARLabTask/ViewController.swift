//
//  ViewController.swift
//  ARLabTask
//
//  Created by Yaroslav Spirin on 3/23/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Firebase

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!
    
    // Text Recognition
    var vision: Vision!
    var textRecognizer: VisionTextRecognizer!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        
        vision = Vision.vision()
        textRecognizer = vision.onDeviceTextRecognizer()
        
        timer = Timer.scheduledTimer(timeInterval: 0.7,
                                     target: self,
                                     selector: #selector(self.runOCR),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Enable plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    // MARK: - Status Bar: Hide
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Interaction
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        
        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint])
        
        if let closestResult = arHitTestResults.first {
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            
            let node : SCNNode = createPopUp(text: self.debugTextView.text)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = worldCoord
        }
    }
    
    func createPopUp(text: String) -> SCNNode {
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        
        path.addLine(to: CGPoint(x: -0.01, y: 0.01))
        path.addLine(to: CGPoint(x: -0.03, y: 0.01))
        path.addLine(to: CGPoint(x: -0.03, y: 0.05))
        path.addLine(to: CGPoint(x: 0.03, y: 0.05))
        path.addLine(to: CGPoint(x: 0.03, y: 0.01))
        path.addLine(to: CGPoint(x: 0.01, y: 0.01))
        
        path.close()
        
        let shape = SCNShape(path: path, extrusionDepth: 0.001)
        let color = UIColor.white
        shape.firstMaterial?.diffuse.contents = color
        shape.chamferRadius = 0.0005
        
        let popUpNode = SCNNode(geometry: shape)
        popUpNode.constraints = [billboardConstraint]
        
        let textShape = SCNText(string: text, extrusionDepth: CGFloat(0.01))
        let font = UIFont.systemFont(ofSize: 0.15, weight: .bold)
        textShape.font = font
        textShape.firstMaterial?.diffuse.contents = UIColor.black
        let (minBound, maxBound) = textShape.boundingBox
        let bubbleNode = SCNNode(geometry: textShape)
        bubbleNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x) / 2, minBound.y, 0.01 / 2)
        bubbleNode.scale = SCNVector3Make(0.03, 0.03, 0.03)
        bubbleNode.position = SCNVector3Make(0.0, 0.03, 0.0011)
        
        popUpNode.addChildNode(bubbleNode)
        
        return popUpNode
    }
    
    // MARK: - OCR

    @objc func runOCR() {
        guard let pixbuff = (sceneView.session.currentFrame?.capturedImage),
            let uiImage = UIImage(pixelBuffer: pixbuff),
            let imageData = uiImage.jpegData(compressionQuality: 0.8),
            let compressedImage = UIImage(data: imageData),
            let rotatedImage = compressedImage.rotated(byDegrees: 90) else {
            return
        }
    
        let image = VisionImage(image: rotatedImage)
        
        textRecognizer.process(image) { result, error in
            guard error == nil, let result = result else {
                return
            }
            
            let resultText = result.blocks[0].text
            self.debugTextView.text = resultText
        }
    }
}
