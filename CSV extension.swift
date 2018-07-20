//
//  CSV extension.swift
//  GrokitRequest
//
//  Created by Student 3 on 19/7/18.
//  Copyright © 2018 Student 3. All rights reserved.
//

import Foundation

extension CSV{
    
    // Column header change and custom name
    func customHeadersString(headerString: String)->String{
        var customed = ""
        customed = headerString.replacingOccurrences(of: "name=Item Name;type=Text;default=6350432845207951318", with: "description")
        customed = customed.replacingOccurrences(of: "name=Part Number;type=Text;required=true", with: "partNumber")
        customed = customed.replacingOccurrences(of: "name=Category;type=List;choices=\"1000 days parts|Blade exchange|Critical parts\";default=1000 days parts", with: "category")
        customed = customed.replacingOccurrences(of: "name=Inventory record;type=List;choices=\"Fixed assets|Machine parts|Laser head\";default=Machine parts;description=Type of inventory;required=true", with: "record")
        customed = customed.replacingOccurrences(of: "name=Tag type;type=List;choices=\"Machine tag|Kanban tag\";required=true", with: "tag")
        customed = customed.replacingOccurrences(of: "name=Inspection Date;type=Text;description=Only for Laser", with: "inspection")
        customed = customed.replacingOccurrences(of: "name=Rack;type=Text;description=Which rack is this part from?;required=true", with: "rack")
        //        print("CSV object call: customHeaderString: \(customed)\n")
        return customed
    }
    
    // Transformed of the dictionaryJSON(dictionary of dictionaries) into array of dictionaries for sorting purposes.
    // @param attr: Sorting based on an attribute
    func sortedDictionaryJSONRows(fromJSONOfDictionary rawDictJSON: Dictionary<String, Dictionary<String,String>>, sortingBy attr: String) -> [(key: String, value: Dictionary<String, String>)]{
        let rawArrDictJSON = Array(rawDictJSON)
        
        // item is (key:String, value: Dictionary)
        var arrayZ = [(key:String, value:Dictionary<String, String>)]() // array of item with lastscan records
        var arrayW = [(key:String, value:Dictionary<String, String>)]() // array of item with incomplete/defected last scan records
        
        // clasify item : (key:String, value: Dictionary) by presence/absence of lastscan records
        for ydict in rawArrDictJSON {
            // check lastscan string
            if let lastscan = ydict.value[attr]{
                
                // lastscan must be a string of 10 characters like : "2017-01-24 06:30:48"
                if (lastscan.count>10){
                    let indexStartOfText = lastscan.index(lastscan.startIndex, offsetBy: 1)
                    let indexEndOfText = lastscan.index(lastscan.startIndex, offsetBy: 10)
                    
                    // date string : 2017-01-24
                    let datestring = String(lastscan[indexStartOfText...indexEndOfText])
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    // checkin if format of date is correct : 2017-01-23 16:00:00 +0000
                    if let _ = dateFormatter.date(from: datestring){
                        // seperate item with last scan records to new array
                        arrayZ.append(ydict)
                        continue
                    }
                }
            }
            // seperate item with incomplete lastscan records to another (new) array
            arrayW.append(ydict)
            
        } // end of for loop (classificating item)
        
        // sortings item in arrayZ in descending order (big to small) more recent
        arrayZ.sort(by: {$0.value["last scanned"]!>$1.value["last scanned"]!})
        
        // concatinate arrayZ with arrayW into arrayZ by append method
        arrayZ.append(contentsOf: arrayW)
        
        // return bloody result
        return arrayZ
    }
    
}
