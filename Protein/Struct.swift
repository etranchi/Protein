//
//  Struct.swift
//  Protein
//
//  Created by Etienne Tranchier on 06/01/2019.
//  Copyright © 2019 Etienne Tranchier. All rights reserved.
//

import Foundation
import SceneKit

struct Ligand {
    var name : String
    var shapes : [Shape]
    var tubes : [Tube]
    
}

struct Shape {
    
    var id : Int
    var name : String
    var type : String
    var pos : SCNVector3
    var color : UIColor?
}

struct Tube {
    var from : Int
    var to : Int
    var times : Int
}
