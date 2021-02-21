//
//  Model.swift
//  QRCodeReader
//
//  Created by MacBook Air on 04/11/2020.
//  Copyright © 2020 Darren Leak. All rights reserved.
//

import Foundation

class Game {
    //var numberOfPlayers : Int
    var players : [String : Player]
    //var score : [Int]
    
    let scoreKill = 10
    let scoreDeath = -5
    
    var dictionary: [String: Any] {
      return [
        //"numberOfPlayers": numberOfPlayers,
        "players": players,
        //"score": score
      ]
    }
    
    init(){
        //self.numberOfPlayers = nbPlayers
        self.players = [String : Player]()
        //self.score = Array(repeating: 0, count: players.count)
    }
    
    func addPlayer(player : Player, id : String){
        self.players[id] = player
    }
    
    func getPlayer(player : Player, id : String){
        self.players[id] = player
    }
    
    
    /*
    func winner() -> Int {
        if let highscore = self.score.max() {

            print("player \(self.Score.firstIndex(of: highscore) ?? -1) win !")
            
            return self.Score.firstIndex(of: highscore) ?? -1
        }
        return -1
    }
    
    func scores() -> [String] {
        
        var Scores = [String]()
        
        for i in 0...(self.numberOfPlayers-1) {
            Scores.append("player \(i), score : \(self.Score[i])")
            print("player \(i), score : \(self.Score[i])")
        }
        
        return Scores
    }
    */
}
