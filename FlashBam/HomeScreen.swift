//
//  HomeScreen.swift
//  QRCodeReader
//
//  Created by MacBook Air on 04/11/2020.
//  Copyright © 2020 Darren Leak. All rights reserved.
//

import UIKit
import AVFoundation

import FirebaseUI
import FirebaseFirestore

class HomeScreen: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate, ScannerDelegate {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var scanQR: UIButton!
    
    let AllowIdReplacement = true
    
    var scanner: Scanner?
    
    var myID : String = "1"
    var myPseudo : String = ""
    
    let collection = Firestore.firestore().collection("Players")
    
    @IBOutlet weak var identifier: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        identifier.delegate = self
        playButton.isEnabled = false
        // Do any additional setup after loading the view.
        scanQR.setTitleColor(UIColor.red, for: .normal)
    }
    
    //MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //updateSaveButtonState()
        navigationItem.title = textField.text
        myPseudo = textField.text!
        updatePlayButton()
        //print("fini d'écrire !")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        //saveButton.isEnabled = false
        //print("save button disabeled")
    }
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ShootController else {
            fatalError("pb prepare")
        }
        destination.myPseudo = self.myPseudo
        destination.myID = self.myID
    }
    
    @IBAction func unwindToHomeScreen(sender : UIStoryboardSegue){
        print("unwindToHomeScreen")
        
    }
    
    private func showResults(game : Game){
        
    }
    
    // MARK: - Alerts
    
    func alertView(alertController: UIAlertController!) {
        print("alertView")
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
    
    // Mark - Scanner delegate methods
    
    func cameraView() -> UIView
    {
        return self.view
    }
    
    func delegateViewController() -> UIViewController
    {
        return self
    }
    
    @IBAction func scan(_ sender: UIButton) {
        self.scanner = Scanner(withDelegate: self)
        
        guard let scanner = self.scanner else {
            print("pas de scanner")
            return
        }
        print("scan")
        scanner.requestCaptureSessionStartRunning()
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
        if code != ""{
            self.scanner!.previewLayer!.removeFromSuperlayer()
        }
        
        if !AllowIdReplacement {
            let docRef = collection.document(code)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    print("id not available")
                    
                    let alert = UIAlertController(title: "message :", message: "id not available", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.myID = ""
                    self.scanQR.setTitleColor(UIColor.red, for: .normal)
                    }
            }
        }
        else {
            self.scanQR.setTitleColor(UIColor.green, for: .normal)
            self.scanQR.isEnabled = false
            self.myID = code
        }
        
        self.updatePlayButton()
        self.scanner!.previewLayer!.removeFromSuperlayer()
        
        //PlayersScore.text = "Score : \(self.player!.score)"
        
        
        //performSegue(withIdentifier: "GameFinished", sender: nil)
    }
    
    func updatePlayButton(){
        self.playButton.isEnabled = self.myID != "" && self.myPseudo != ""
    }
}
