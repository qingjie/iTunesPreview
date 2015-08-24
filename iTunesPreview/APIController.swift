//
//  APIController.swift
//  iTunesPreview
//
//  Created by qingjie on 8/23/15.
//  Copyright (c) 2015 qingjie. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results : NSArray)
}

class APIController{
    var delegate : APIControllerProtocol
    
    init(delegate:APIControllerProtocol){
        self.delegate = delegate
    }
   
    func get(path: String) {
        let url = NSURL(string:path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: { data, response, error -> Void in
            println("Task completed")
            if (error != nil ) {
                //If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err:NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary{
                if(err != nil) {
                    //if there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                if let results:NSArray = jsonResult["results"] as? NSArray {
                    self.delegate.didReceiveAPIResults(results)
                }
            }
            
        })
        //The task is just an object with all these properties set
        //In order to actually make the web request, we need to "resume"
        task.resume()
    }
    
    func searchItunesFor(searchTerm:String){
        //The iTunes API wants multiple terms separated by + symbols, so replace space with + sings
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        //Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding){
            let urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&amp;media=music&amp;entity=album"
            get(urlPath)
        }
    }
    
    func lookupAlbum(collectionId: Int){
        get("https://itunes.apple.com/lookup?id=\(collectionId)&entity=song")
    }
}