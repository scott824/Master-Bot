//
//  ContentsController.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 4. 28..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import UIKit
import CoreData


/// *Contents Controller*
///
/// Table view which display contents

class ContentsController: UITableViewController, InputTextDelegate, RequestControllerDelegate, UpdateContent {
    
    var datacontroller: DataController?
    
    @IBOutlet var ContentsTableView: UITableView!
    
    
    private var _inputText: String?
    
    /// Input text which set by `RootViewController`
    var inputText: String? {
        get {
            return self._inputText
        }
        set(input) {
            self._inputText = input
            if input != "" {
                makeContent()
            }
        }
    }
    
    /// contents in table
    var contents: [ContentInfo] = []

    
    
//* Override functions *//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for cell height
        self.ContentsTableView.rowHeight = UITableViewAutomaticDimension
        self.ContentsTableView.estimatedRowHeight = 50.0
        
        // remove cell separator style
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get DataController instance
        self.datacontroller = DataController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /// return the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// return the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    /// configure the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Content
        
        // set cell by it's content
        setCell(cell, index: indexPath.row)

        return cell
    }
    
    
    
//* make/add content | set cell *//
    
    /// set cell by contents[index]
    func setCell(_ cell: Content, index: Int) {
        let content = self.contents[index]
        cell.setContent(contentInfo: content)
        cell.tableviewcontroller = self
    }
    
    /// add content row to table (Update table)
    func addContent(contentInfo: ContentInfo) {
        
        self.contents.append(contentInfo)
        NSLog("Begin Update")
        
        // Add row
        ContentsTableView?.beginUpdates()
        ContentsTableView?.insertRows(at: [IndexPath(row: contents.endIndex-1, section: 0)], with: .bottom)
        ContentsTableView?.endUpdates()
        
        NSLog("End Update")
        
        // scroll down
        if contents.count > 0 {
            let indexPath = IndexPath(row: contents.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    /// Make content row
    func makeContent() {
        guard let inputText = inputText else {
            return
        }
        
        // make send message row
        if let contentinfo = datacontroller?.getContentData(input: "sendMessage") {
            contentinfo.subviews?[0].subviews?[0].text = inputText  // TODO: regularity 하게 수정 요망
            addContent(contentInfo: contentinfo)
        }
        
        NSLog("Make Content : " + inputText)
        
        // make information row by input
        if inputText.contains("날씨") {
            if let contentinfo = datacontroller?.getContentData(input: "날씨") {
                let request = RequestController()
                request.delegate = self
                request.request(contentInfo: contentinfo)
                
                // make notification
                if NotificationController.weatherNotification == false {
                    let notification = NotificationController()
                    notification.initNotificationSetupCheck()
                    notification.contentsController = self
                    notification.setNotification()
                }
            }
        }
    }
    
    
    
//* UpdateContent protocol functions *//
    
    /// reload(refresh) specific cell
    func reload(_ cell: Content) {
        let indexPath = self.tableView.indexPath(for: cell)
        self.tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
    }
    
    /// return index of specific cell
    func index(_ cell: Content) -> Int? {
        if let index = self.tableView.indexPath(for: cell)?.row {
            return index
        }
        return nil
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


