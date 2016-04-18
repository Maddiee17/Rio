//
//  RioDatabaseManager.swift
//  Rio
//
//  Created by Madhur Mohta on 06/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class RioDatabaseManager {
    
    var databasePath : NSString = ""
    var database : FMDatabase
    var queue: FMDatabaseQueue?

    class var sharedInstance: RioDatabaseManager {
        struct Singleton {
            static let instance = RioDatabaseManager()
        }
        return Singleton.instance
    }
    
    init(){
        databasePath = ""
        database = FMDatabase(path: "" as String)
    }
    
    func initDatabase() {
        
        let fileManager = NSFileManager.defaultManager()
        var dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        databasePath = docsDir.stringByAppendingString("/Rio_DB.sqlite")
        
        let documentDirectoryPath = pathToDocsFolder()
        
        if fileManager.fileExistsAtPath(documentDirectoryPath) {
            print("Rio_DB File Found!")
        }
        else {
            
            // Copy the file from the Bundle and write it to the Device:
            let pathToBundledDB = NSBundle.mainBundle().pathForResource("Rio_DB", ofType: "sqlite")
            
            
            // If error then catch it:
            do{
                try fileManager.copyItemAtPath(pathToBundledDB!, toPath: documentDirectoryPath)
                print("Rio_DB.sqlite copied: \(pathToBundledDB)")
            }
            catch let error as NSError {
                print("Rio_DB.sqlite copy Error: \(error)")
            }
        }
        queue = FMDatabaseQueue(path: databasePath as String)
        queue?.inDatabase(){
            database in
            database.setMaxBusyRetryTimeInterval(5)
        }
    }
    
    func pathToDocsFolder() -> String {
        let pathToDocumentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        print("DOCUMENT DIRECTORY PATH: \(pathToDocumentsFolder)")
        return (pathToDocumentsFolder as NSString).stringByAppendingPathComponent("/Rio_DB.sqlite")
    }
    
    func openDatabase() -> Bool
    {
        return true;
    }
    
    func closeDatabase() -> Bool
    {
        /*database = FMDatabase(path: databasePath as String)
        if  database.close()
        {
        
        return true
        }
        
        return false
        */
        return true;
        
    }
    
    func fetchCategories(sqlStmt:String, completionBlock: ((FMResultSet) -> Void)!)
    {
        let querySQL = sqlStmt
        
        queue?.inDatabase(){
            database in
            
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsInArray: nil)
            if let result = results
            {
                completionBlock(result)
            }
        }
    }
    
    func fetchEventDetails(sqlStmt:String, eventSelected: String,completionBlock: ((FMResultSet) -> Void)!)
    {
        let querySQL = sqlStmt
        
        queue?.inDatabase(){
            database in
            
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsInArray: [eventSelected])
            if let result = results
            {
                completionBlock(result)
            }
            results!.close()
        }
    }

    
    func fetchSubCategoryForCategory(sqlStmt:String, category:String, completionBlock: ((FMResultSet) -> Void)!)
    {
        let querySQL = sqlStmt
        
        queue?.inDatabase(){
            database in
            
            let results:FMResultSet? = database.executeQuery(querySQL, withArgumentsInArray: [category])
            if let result = results
            {
                completionBlock(result)
            }
            results!.close()
        }
    }
    
    func fetchUserProfile(sqlStmt:String, completionBlock:((FMResultSet) -> Void))
    {
        queue?.inDatabase() { database in
            
            let results:FMResultSet? = database.executeQuery(sqlStmt, withArgumentsInArray: [])
            if let result = results
            {
                completionBlock(result)
            }
            results!.close()
        }
    }
    
    func insertUserProfileValues(sqlStmt:String, dataDict:NSDictionary)
    {
            queue?.inDatabase(){ database in

            let results = database.executeUpdate(sqlStmt, withArgumentsInArray: [dataDict
                .objectForKey("userId")!, dataDict.objectForKey("emailId")!, dataDict.objectForKey("photoUrl")!, dataDict.objectForKey("name")!, dataDict.objectForKey("googleId")!, dataDict.objectForKey("facebookId")!, dataDict.objectForKey("notificationId")!, dataDict.valueForKey("photoUrl")!,dataDict.valueForKey("createdDate")!, dataDict.valueForKey("modifiedDate")!])
            
            if (!results) {
                print("Error: insertUserProfileValues:  \(database.lastErrorMessage())")
            }
        }
    }
    
    func clearUserProfileTable(sqlStmt:String)
    {
        queue?.inDatabase(){ database in
            
            let result = database.executeUpdate(sqlStmt, withArgumentsInArray: [])
            if(!result)
            {
                print("Error: Deleting Record:  \(database.lastErrorMessage())")
            }
        }
    }
}
