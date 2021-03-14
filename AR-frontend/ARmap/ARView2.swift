//
//  File.swift
//  ARmap
//
//  Created by Claire Blazewicz on 3/13/21.
//

import Foundation
import ARCL
import CoreLocation

class ARView2: UIViewController {
    var sceneLocationView = SceneLocationView()
    var lat: Float?
    var lon: Float?
    
    
    override func viewDidLoad() {
      super.viewDidLoad()
      let coordinate = CLLocationCoordinate2D(latitude: 51.504571, longitude: -0.019717)
      let location = CLLocation(coordinate: coordinate, altitude: 300)
      let image = UIImage(named: "pin")!

      let annotationNode = LocationAnnotationNode(location: location, image: image)
      sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
      sceneLocationView.run()
      view.addSubview(sceneLocationView)
    }

    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      sceneLocationView.frame = view.bounds
    }

}

