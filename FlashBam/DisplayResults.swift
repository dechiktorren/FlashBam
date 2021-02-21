//
//  DisplayResults.swift
//  QRCodeReader
//
//  Created by MacBook Air on 05/11/2020.
//  Copyright © 2020 Darren Leak. All rights reserved.
//

import UIKit

class DisplayResults: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var printWinner: UILabel!
    @IBOutlet weak var tableScores: UITableView!
    
    //var game : Game?
    var scores : [String] = []
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableScores.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableScores.delegate = self
        tableScores.dataSource = self
        
        
        
        // self.printWinner.text = "player \(game?.winner() ?? -1) win !"
        
        // self.scores = currentGame.scores()
        // Do any additional setup after loading the view.
    }
    
    // MARK: UITableViewDelegate
    // number of rows in table view
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.scores.count
        }
        
        // create a cell for each table view row
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            // create a new cell if needed or reuse an old one
            let cell:UITableViewCell = (self.tableScores.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
            
            // set the text from the data model
            cell.textLabel?.text = self.scores[indexPath.row]
            
            return cell
        }
        
        // method to run when table view cell is tapped
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("You tapped cell number \(indexPath.row).")
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
