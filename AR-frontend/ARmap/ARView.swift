//
//  ARView.swift
//  ARmap
//
//  Created by Claire Blazewicz on 3/12/21.
//

import Foundation
import ARCL
import CoreLocation
import ARKit
import SceneKit
import MapKit

class ViewController: UIViewController {
  var sceneLocationView = SceneLocationView()

    
    override func viewDidLoad() {
      super.viewDidLoad()

      sceneLocationView.run()
      view.addSubview(sceneLocationView)
        let coordinate = CLLocationCoordinate2D(latitude: 51.504571, longitude: -0.019717)
        let location = CLLocation(coordinate: coordinate, altitude: 300)
        let layer = CALayer() // or a custom CALayer subclass

        let annotationNode = LocationAnnotationNode(location: location, layer: layer)

        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
    }

    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      sceneLocationView.frame = view.bounds
    }
    

}


