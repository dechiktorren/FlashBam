//
//  ViewController.swift
//  QRCodeReader
//
//  Created by ProgrammingWithSwift on 2018/08/31.
//  Copyright © 2018 ProgrammingWithSwift. All rights reserved.
//

import UIKit
import AVFoundation

import FirebaseUI
import FirebaseFirestore
//import SDWebImage

class ShootController: UIViewController ,UITableViewDelegate, UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate, ScannerDelegate {
    
    var myID : String = ""
    var myPseudo : String = ""
    
    var scanner: Scanner?
    //var game : Game?
    
    //var player : Player?
    //var opponent : Player?
    
    //var playerID : String = ""
    //var opponentID : String = ""
        
    
    let cellReuseIdentifier = "cell"
    
    //public var players: [Player] = []
    var players : [String : Player] = [:]
    var IDs : [String] = []
    
    public var documents: [DocumentSnapshot] = []
    
    /*
    var query: Query? {
      didSet {
        if let listener = listener {
          listener.remove()
          observeQuery()
        }
      }
    }
 */
    
    @IBOutlet weak var shootButton: UIButton!
    @IBOutlet weak var PlayersName: UILabel!
    @IBOutlet weak var PlayersScore: UILabel!
    @IBOutlet weak var displayPlayers: UITableView!
    
    let scoreKill = 10
    let scoreDeath = -5
    
    let collection = Firestore.firestore().collection("Players")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayPlayers.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        displayPlayers.delegate = self
        displayPlayers.dataSource = self
        
        
        //self.game = Game()
        
        //self.playerID = "1"
        //self.opponentID = "2"
        
        //let player = Player(name : "Player 1", canShoot : true, id: "1")
        
        if self.myID == "" {
            fatalError("no ID")
        }
        
        self.shootButton.setTitleColor(UIColor.green, for: .normal)
        //let opponent = Player(name : "Player 2", canShoot : true, id: "2")
        
        
        
        
        // Write Data to Firestore
        
        //let collection = Firestore.firestore().collection("Players")

        //collection.addDocument(data: self.player!.dictionary)
        //collection.addDocument(data: self.opponent!.dictionary)
        
        
        //collection.document("2").setData(opponent.dictionary)
        
        //query = baseQuery()
        
        // Create my player
        let player = Player(name : myPseudo, canShoot : true, id: self.myID)
        
        self.players[self.myID] = player
        self.IDs.append(self.myID)
        
        PlayersName.text = player.name
        PlayersScore.text = "Score : \(player.score )"
        
        // Get the other players
        self.collection.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let otherPlayer = self.createPlayerFromDictionary(dictionary: document.data())
                    self.players[otherPlayer.id] = otherPlayer
                    self.listenDocument(id: otherPlayer.id)
                    if !self.IDs.contains(otherPlayer.id){
                        self.IDs.append(otherPlayer.id)
                    } else {
                        print("ducplicated id : \(otherPlayer.id)")
                    }
                    
                }
            }
        }
        
        collection.document(myID).setData(player.dictionary)
        listenDocument(id: self.myID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark - AVFoundation delegate methods
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        guard let scanner = self.scanner else {
            print("pas de scanner")
            return
        }
        scanner.metadataOutput(output,
                               didOutput: metadataObjects,
                               from: connection)
    }
    
    // MARK: UITableViewDelegate
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.players.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (self.displayPlayers.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        // set the text from the data model
        let selectedPlayer = self.players[self.IDs[indexPath.row]]
        cell.textLabel?.text = selectedPlayer!.name + " : " + String(selectedPlayer!.score)
        
        //print(selectedPlayer.name + " : " + String(selectedPlayer.score))
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
 
    // Mark - Scanner delegate methods
    func cameraView() -> UIView
    {
        return self.view
    }
    
    func delegateViewController() -> UIViewController
    {
        return self
    }
    
    func scanCompleted(withCode code: String)
    {
        //print("opponentID : " + opponentID)
        print("code : " + code)
        /*
        let alert = UIAlertController(title: "message :", message: code, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        */
        /*
        guard let game = self.game else {
            print("pas de jeu")
            return
        }
        */
        
        if self.myID == code {
            print("sucide")
            self.scanner!.previewLayer!.removeFromSuperlayer()
            return
        }
        
        for k in 0...(self.players.count-1) {
            let P = self.players[self.IDs[k]]!
            if P.id == code {
                hit(attacker: players[self.myID]!, victim: P)
            }
        }

    
        self.scanner!.previewLayer!.removeFromSuperlayer()
        
        //PlayersScore.text = "Score : \(self.player!.score)"
        
        
        //performSegue(withIdentifier: "GameFinished", sender: nil)
    }
    
    func hit(attacker : Player, victim : Player){
        
        print(attacker.name + " shoot " + victim.name)
        
        let victimRef = self.collection.document(victim.id)
        
        print(victim.name + " unable to shoot")
        victim.canShoot = false
        
        victimRef.updateData([
            "canShoot": false
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
            print(victim.name + " now able to shoot")

            victimRef.updateData([
                "canShoot": true
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            victim.canShoot = true
        }
        
        victim.nbDeath += 1
        victim.score += self.scoreDeath
        
        attacker.nbKill += 1
        attacker.score += self.scoreKill
        
        collection.document(attacker.id).setData(attacker.dictionary)
        collection.document(victim.id).setData(victim.dictionary)
    }
    
    
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let destination = segue.destination as? DisplayResults else {
            return
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func shoot(_ sender: UIButton) {
        self.scanner = Scanner(withDelegate: self)
        
        guard let scanner = self.scanner else {
            print("pas de scanner")
            return
        }
        
        scanner.requestCaptureSessionStartRunning()
    }
    
    // MARK: - FireStore
    
    func listenDocument(id : String) {
         // [START listen_document]
        self.collection.document(id)
             .addSnapshotListener { documentSnapshot, error in
               guard let document = documentSnapshot else {
                 print("Error fetching document: \(error!)")
                 return
               }
               guard let data = document.data() else {
                 print("Document data was empty.")
                 return
               }
                
                self.updatePlayer(dictionary: data)
                //self.players[k].score = data["score"] as! Int

                self.displayPlayers.reloadData()
                
                if self.myID == data["id"] as! String {
                    self.PlayersName.text = self.players[self.myID]!.name
                    self.PlayersScore.text = "Score : \(self.players[self.myID]!.score )"
                    
                    if self.players[self.myID]!.canShoot{
                        self.shootButton.setTitleColor(UIColor.green, for: .normal)
                        self.shootButton.isEnabled = true
                    } else {
                        self.shootButton.setTitleColor(UIColor.red, for: .normal)
                        self.shootButton.isEnabled = false
                    }
                }
                
               //print("Current data: \(data)")
                //print("score : " + String(self.players[0].score))
                //print((data["score"]) ?? -1)
                
                
                /*
                let canShoot = data["canShoot"] as! Bool
                let nbKill = data["nbKill"] as! Int
                let nbDeath = data["nbDeath"] as! Int
                let score = data["score"] as! Int
          
                let model = Player(name: name, canShoot: canShoot, id: id, nbKill: nbKill, nbDeath: nbDeath, score: score)
                */
                
            }
         // [END listen_document]
     }

     func listenDocumentLocal() {
         // [START listen_document_local]
        self.collection.document("1")
             .addSnapshotListener { documentSnapshot, error in
                 guard let document = documentSnapshot else {
                     print("Error fetching document: \(error!)")
                     return
                 }
                 let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                 print("\(source) data: \(document.data() ?? [:])")
             }
         // [END listen_document_local]
     }
    
    func updatePlayer(dictionary: [String : Any]) {
        guard let name = dictionary["name"] as? String,
              let id = dictionary["id"] as? String,
          let canShoot = dictionary["canShoot"] as? Bool,
          let nbKill = dictionary["nbKill"] as? Int,
          let nbDeath = dictionary["nbDeath"] as? Int,
          let score = dictionary["score"] as? Int
        else { print("pb updatePlayer")
            return }
        
        
        self.players[id]!.name = name
        self.players[id]!.canShoot = canShoot
        self.players[id]!.nbKill = nbKill
        self.players[id]!.nbDeath = nbDeath
        self.players[id]!.score = score
    }
    
    func createPlayerFromDictionary(dictionary: [String : Any]) -> Player {
        guard let name = dictionary["name"] as? String,
              let id = dictionary["id"] as? String,
          let canShoot = dictionary["canShoot"] as? Bool,
          let nbKill = dictionary["nbKill"] as? Int,
          let nbDeath = dictionary["nbDeath"] as? Int,
          let score = dictionary["score"] as? Int
        else { //print("pb createPlayerFromDictionary")
            //return nil
            fatalError("pb createPlayerFromDictionary")
        }
        
        return Player(name: name, canShoot: canShoot, id: id, nbKill: nbKill, nbDeath: nbDeath, score: score)
    }
    
    //deinit {
    //  listener?.remove()
    //}
/*
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      //observeQuery()
    }
    
    var listener: ListenerRegistration?
    
    fileprivate func observeQuery() {
      guard let query = query else { return }
      stopObserving()
        print("un truc a changé")
      // Display data from Firestore, part one

      listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
        guard let snapshot = snapshot else {
          print("Error fetching snapshot results: \(error!)")
          return
        }
        let models = snapshot.documents.map { (document) -> Player in
            if let model = Player(dictionary: document.data()) {
              return model
            } else {
              // Don't use fatalError here in a real app.
              fatalError("Unable to initialize type \(Player.self) with dictionary \(document.data())")
            }

        }
        self.players = models
        self.documents = snapshot.documents
        
        self.displayPlayers.reloadData()
        print("score : " + String(self.players[0].score))
      }
    }
    */
    /*
    let dictionary = document.data() as Dictionary
        let name = dictionary["name"] as! String
    guard let id = dictionary["id"] as? String  else {
        print("pb")
        print(name)
        print(dictionary["id"]!)
        print("nb players : " + String(self.players.count))
        fatalError("pas un str")
    }
          let canShoot = dictionary["canShoot"] as! Bool
          let nbKill = dictionary["nbKill"] as! Int
          let nbDeath = dictionary["nbDeath"] as! Int
          let score = dictionary["score"] as! Int
    
    let model = Player(name: name, canShoot: canShoot, id: id, nbKill: nbKill, nbDeath: nbDeath, score: score)
    //else {fatalError("Unable to initialize type \(Player.self) with dictionary \(document.data())")}
  //if let model = Player(dictionary: document.data()) {
    return model
*/
    /*
    fileprivate func stopObserving() {
      listener?.remove()
    }

    fileprivate func baseQuery() -> Query {
      return Firestore.firestore().collection("Players").limit(to: 50)
    }
    
    func query(name: String?, id: String?, canShoot: Bool?, sortBy: String?) -> Query {
      var filtered = baseQuery()

      // Sorting and Filtering Data

      if let name = name, name != "" {
        filtered = filtered.whereField("name", isEqualTo: name)
      }

      if let id = id, id != "" {
        filtered = filtered.whereField("id", isEqualTo: id)
      }

      if let canShoot = canShoot {
        filtered = filtered.whereField("canShoot", isEqualTo: canShoot)
      }

      if let sortBy = sortBy, !sortBy.isEmpty {
        filtered = filtered.order(by: sortBy)
      }
      
      return filtered
    }
    */
    /*
    
    @IBAction func GestureZoom(_ sender: UIPinchGestureRecognizer) {
        
        //print("zoom")
        //var initialVideoZoomFactor: CGFloat = 0.0

        guard let scanner = scanner else {
            print("pas de scanner")
            return
        }
        
        if sender.scale <= 1.0 || sender.scale >= (scanner.device?.activeFormat.videoMaxZoomFactor)! {
            return
        }
        
        
        if (sender.state == UIGestureRecognizer.State.began) {
            //print(sender.scale)
            
            /*
            let scale = 2*sender.scale
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.01)
            scanner.previewLayer?.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
            CATransaction.commit()
            */
            do {
                try scanner.device?.lockForConfiguration()
                
                guard var zoomFactor = scanner.device?.videoZoomFactor else {
                    return
                }
                zoomFactor *= sender.scale
                zoomFactor = min((scanner.device?.activeFormat.videoMaxZoomFactor)!, zoomFactor)
                zoomFactor = max(1.0, zoomFactor)
                scanner.device?.videoZoomFactor = zoomFactor
                
                print(zoomFactor)
            } catch {print("fail")}

        }
        
        
    }
    */
    
    
}
