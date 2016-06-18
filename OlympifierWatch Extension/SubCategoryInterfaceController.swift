//
//  SubCategoryInterfaceController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 18/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class SubCategoryInterfaceController: WKInterfaceController,WCSessionDelegate {

    @IBOutlet var headerLabel: WKInterfaceLabel!
    @IBOutlet var tableView: WKInterfaceTable!
    @IBOutlet var headerImage: WKInterfaceImage!
    
    var session : WCSession?
    var datesArray = [String](){
        
        didSet{
            self.tableView.setNumberOfRows(datesArray.count, withRowType: "subCategory")
            
            for index in 0..<tableView.numberOfRows {
                if let controller = tableView.rowControllerAtIndex(index) as? SubCategoryRowController {
                    controller.type = datesArray[index]
                }
            }
        }

    }

    var eventDetails : NSMutableArray?
    var splittedDict = NSMutableDictionary()
    var subCategoryType : String?
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        if let type = context as? String {
            self.subCategoryType = type
            print(subCategoryType)
            self.headerLabel.setText(type)
            self.headerImage.setImage(UIImage(named: type))
        }
        
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            
            if WCSession.defaultSession().reachable {
                
                session?.sendMessage(["model":"event", "categorySelected" : subCategoryType!], replyHandler: { (response) in
                    
                    print(response)
                    self.eventDetails = response["eventModel"] as? NSMutableArray
                    self.sortDataBasedOnDate()
                    print(self.eventDetails!)
                    }, errorHandler: { (error) in
                        print("error")
                })
            }
        }
        
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            
            if WCSession.defaultSession().reachable {
                
                session?.sendMessage(["model":"reminder"], replyHandler: { (response) in
                    
                    print(response)
                    
                    WatchRootModel.sharedInstance.remindersArray = response["remindersArray"] as? [String]
                    
                    }, errorHandler: { (error) in
                        print("error")
                })
                
            }
        }
    }
    
    func sortDataBasedOnDate()
    {
        for eventModel in self.eventDetails!
        {
            if self.datesArray.contains(eventModel.valueForKey("Date") as! String) == false {
                self.datesArray.append(eventModel.valueForKey("Date") as! String)
            }
        }
        print(self.datesArray)
        
        for date in self.datesArray {
            let predicate = NSPredicate(format: "Date = %@", date)
            let valuesArray = (self.eventDetails?.filteredArrayUsingPredicate(predicate))! as NSArray
            print(valuesArray)
            self.splittedDict.setValue(valuesArray, forKey: date)
        }
        print(self.splittedDict)
    }
    
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let selectedDate = datesArray[rowIndex]
        let values = splittedDict.valueForKey(selectedDate)
        presentControllerWithName("Event", context: values)
    }


    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
