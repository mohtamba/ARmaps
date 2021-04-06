//
//  Waypoints.swift
//  ARmap
//
//  Created by Claire Blazewicz on 3/26/21.
//

import Foundation

struct Waypoint {
    var lat : Float
    var lon: Float
}


struct Waypoints {
    var data = [
        Waypoint
    ].self
    var url: String?
    var time_estimate: String?
    static let nFields = 3
}


