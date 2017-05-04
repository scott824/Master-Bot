//
//  ContentsController.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 4. 28..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import UIKit
import CoreData

////////////////////////////////////////////////////////////////////////////////
//
//  Contents Controller (chatting table controller)
//
////////////////////////////////////////////////////////////////////////////////

class ContentsController: UITableViewController, RequestControllerDelegate {
    
    var datacontroller: DataController?
    
    @IBOutlet var ContentsTableView: UITableView!
    
    // Input text from main ViewController
    var inputText: String? {
        didSet {
            if inputText != "" {
                NSLog("didSet inputText in ContentsController")
                
                makeContent()
                
            }
        }
    }
    
    // contents in table
    var contents: [ContentInfo] = []

    
    
////////////////////////////////////////////////////////////////////////////////
//
//  Override functions
//
////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for cell height
        self.ContentsTableView.rowHeight = UITableViewAutomaticDimension
        self.ContentsTableView.estimatedRowHeight = 50.0
        
        // cell separator style
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        datacontroller = DataController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // return the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // return the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    // configure the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Content

        //cell.backgroundColor = UIColor.gray
        setCell(cell, index: indexPath.row)
        
        // for cell height
        self.ContentsTableView.rowHeight = UITableViewAutomaticDimension
        self.ContentsTableView.estimatedRowHeight = 50.0

        return cell
    }
    
    
    
////////////////////////////////////////////////////////////////////////////////
//
//  make set Content
//
////////////////////////////////////////////////////////////////////////////////
    
    // set cell by contents[index]
    func setCell(_ cell: Content, index: Int) {
        NSLog("Set Cell at row " + String(index))
        let content = self.contents[index]
        cell.setContent(contentInfo: content)
    }
    
    func addContent(contentInfo: ContentInfo) {
        self.contents.append(contentInfo)
        NSLog("Begin Update")
        
        // Add row
        ContentsTableView?.beginUpdates()
        ContentsTableView?.insertRows(at: [IndexPath(row: contents.endIndex-1, section: 0)], with: .automatic)
        ContentsTableView?.endUpdates()
        
        NSLog("End Update")
        
        // scroll down
        if contents.count > 0 {
            let indexPath = IndexPath(row: contents.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    // Make Content Card
    func makeContent() {
        guard let inputText = inputText else {
            return
        }
        
        NSLog("Make Content : " + inputText)
        
        var content = ContentInfo(name: "self", type: .content)
        
        if inputText.contains("날씨") {
            //var id = contentId[0].value(forKey: "id") as? Int
//            let image = #imageLiteral(resourceName: "todayweather")
//            let ratio = image.size.height / image.size.width
//            content.subviews = [ContentInfo(name: "imageView", type: .UIImageView, image: image)]
//            content.constraints = [Constraint("imageView", .centerX, "self", .centerX, multiplier: 1.0, constant: 0.0),
//                                   Constraint("imageView", .centerY, "self", .centerY, multiplier: 1.0, constant: 0.0),
//                                   Constraint("imageView", .width, "self", .width, multiplier: 1.0, constant: 0.0),
//                                   Constraint("imageView", .height, "self", .height, multiplier: Double(ratio), constant: 0.0)]
            
            if var contentinfo = datacontroller?.getContentData(input: "날씨") {
                let request = RequestController()
                request.delegate = self
                request.request(contentInfo: contentinfo)
                NSLog("append content to constents")
            }
            return
        }
        else if inputText.contains("id") {
            NSLog("input: id")
            var text = ""
            if let contentIds = datacontroller?.contentIds {
                NSLog("start loop")
                for i in contentIds {
                    NSLog("inside loop")
                    if let name = i.name {
                        text += String(i.id) + name
                    }
                }
            }
            NSLog("make text")
            content.subviews = [ContentInfo(name: "label", type: .UILabel, text: text)]
            content.constraints = [Constraint("label", .centerX, "self", .centerX, multiplier: 1.0, constant: 0.0),
                                   Constraint("label", .centerY, "self", .centerY, multiplier: 1.0, constant: 0.0),
                                   Constraint("label", .width, "self", .width, multiplier: 1.0, constant: -20.0),
                                   Constraint("label", .height, "self", .height, multiplier: 1.0, constant: -20.0)]
        }
        else if inputText.contains("delete") {
            datacontroller?.deleteAll()
        }
        else if inputText.contains("firstdata") {
            datacontroller?.firstData()
        }
        else {
            var str = inputText.components(separatedBy: " ")
            datacontroller?.save(id: Int(str[0])!, name: str[1])
        }
        
        self.contents.append(content)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


