//
//  User.swift
//  Souvenify
//
//  Created by Dhiraj Das on 9/2/16.
//  Copyright © 2016 Dhiraj Das. All rights reserved.
//

import Foundation
import GoogleMaps

struct Annotation {
    let location: CLLocationCoordinate2D
    let key: String
    let marker: GMSMarker
}
