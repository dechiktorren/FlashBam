//
//  Player.swift
//  QRCodeReader
//
//  Created by MacBook Air on 07/11/2020.
//  Copyright © 2020 Darren Leak. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

public class Player {
    
    var name : String
    var id : String
    //var currentGame : Game
    var canShoot : Bool
    var nbKill : Int = 0
    var nbDeath : Int = 0
    var score : Int = 0
    
    var dictionary: [String: Any] {
      return [
        "name": name,
        "id": id,
        "canShoot": canShoot,
        "nbKill": nbKill,
        "nbDeath": nbDeath,
        "score": score
      ]
    }
    
    init(name: String, canShoot: Bool, id : String){
        self.name = name
        self.canShoot = canShoot
        self.id = id
    }
    
    init(name: String, canShoot: Bool, id : String,
         nbKill: Int, nbDeath: Int, score: Int){
        self.name = name
        self.canShoot = canShoot
        self.id = id
    }
}
