//
//  ARView.swift
//  CLmini
//
//  Created by Claire Blazewicz on 3/13/21.
//

//import Foundation
//import ARCL
//import CoreLocation
//import ARKit
//import SceneKit
//import MapKit
//import UIKit
//import ARCoreLocation
//
//
////class ARView: UIViewController{
////    @IBOutlet weak var arview: ARSCNView!
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        let landmarker = ARLandmarker(view: ARSKView(), scene: InteractiveScene(), locationManager: CLLocationManager())
////        landmarker.view.frame = self.view.bounds
////        landmarker.scene.size = self.view.bounds.size
////        self.view.addSubview(landmarker.view)
////        let landmarkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 20))
////        landmarkLabel.text = "Statue of Liberty"
////        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 40.689234, longitude: -74.044524), altitude: 30, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
////        landmarker.addLandmark(view: landmarkLabel, at: location, completion: nil)
////    }
////}
//
//
//class ARView: UIViewController {
//  var sceneLocationView = SceneLocationView()
//   // @IBOutlet weak var sceneView: ARSCNView!
//    
//    @IBOutlet weak var sceneView: ARSCNView!
//    //@IBOutlet weak var sceneView: ARSKView!
//
//    private let configuration = ARWorldTrackingConfiguration()
//
//     override func viewDidLoad() {
//            super.viewDidLoad()
//            self.sceneView.showsStatistics = true
//            self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//            self.sceneView.session.run(ARWorldTrackingConfiguration())
//            let coordinate = CLLocationCoordinate2D(latitude: 37.334525, longitude: -122.008898)
//            let geoAnchor = ARGeoAnchor(name: "Apple Park", coordinate: coordinate)
//            sceneView.session.add(anchor: geoAnchor)
//        
//
//        
//
//            addBox()
//
//
//        }
//
//        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//            self.sceneView.session.run(configuration)
//        }
//
//        override func viewWillDisappear(_ animated: Bool) {
//            super.viewWillDisappear(animated)
//            self.sceneView.session.pause()
//        }
//
//    private var node: SCNNode!
//
//    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
//            // 1
//            let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//
//            // 2
//            let colors = [UIColor.green, // front
//                UIColor.red, // right
//                UIColor.blue, // back
//                UIColor.yellow, // left
//                UIColor.purple, // top
//                UIColor.gray] // bottom
//            let sideMaterials = colors.map { color -> SCNMaterial in
//                let material = SCNMaterial()
//                material.diffuse.contents = color
//                material.locksAmbientWithDiffuse = true
//                return material
//            }
//            box.materials = sideMaterials
//
//            // 3
//            self.node = SCNNode()
//            self.node.geometry = box
//            self.node.position = SCNVector3(x, y, z)
//
//            //4
//           sceneView.scene.rootNode.addChildNode(self.node)
//        }
//}
//
//
