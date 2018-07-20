//
//  CSV module.swift
//  GrokitRequest
//
//  Created by Student 3 on 13/7/18.
//  Copyright © 2018 Student 3. All rights reserved.
//

import Foundation

public class CSV{
    // column header
    public var headers = [String]()
    
    // Transformed each CSV rows into array of dictionaries. Each dictionary equvalent each column. Dictionary contains cell data
    public var rowsArray : [Dictionary<String, String>] = []
    
    // Transformed each CSV columns into arrays of strings, each string represent cell data
    public var colsJSON = Dictionary<String, [String]>()
    
    // Transformed each CSV rows into dictionaries of dictionaries, perfect for table with multiple repeated elements. Allows count same/repeated elements
    public var dictionaryJSON = Dictionary<String, Dictionary<String,String>>()
    
    // Transformed of the dictionaryJSON(dictionary of dictionaries) into array of dictionaries for sorting purposes.
    public var arrDictionaryJSON = [(key:String, value:Dictionary<String, String>)]()
    
    // CSV : comma separated vile(?) | TSV : tab separated vile(?)
    public var delimiter = CharacterSet(charactersIn: ",")
    
    public init(content : String?, delimiter: CharacterSet, encodingInt: UInt) throws{ // encoding = String.Encoding.utf8.rawValue
        let primaryColumnIndex = 0
        
        if let csvStringRaw = content {
            self.delimiter = delimiter
            let csvString = self.cleanCSVText(csvText: csvStringRaw)
            var lines = [String]()
            csvString.enumerateLines(invoking: { (line, stop) in
                lines.append(line)
            })
            self.headers = self.parseHeader(fromLines: lines[0])
            print(self.headers)
            self.rowsArray = self.parseRowsArray(fromLines: lines)
            self.colsJSON = self.parseColumnsJSON(fromLines: lines, groupBy: primaryColumnIndex)
            self.dictionaryJSON = self.parseRowsJSON(fromLines: lines)
        }
    }
    
    public convenience init(rawText csvStringRaw: String, delimiter: CharacterSet)throws{
        try self.init(content: csvStringRaw, delimiter: delimiter, encodingInt: String.Encoding.utf8.rawValue)
    }
    
    public convenience init(fileContentsOfURL url: String) throws {
        let delim = CharacterSet(charactersIn: ",")
        let encod = String.Encoding.utf8.rawValue
        let csvString : String?
        do {
            csvString = try String(contentsOfFile: url, encoding: String.Encoding.utf8)
        } catch _{
            csvString = nil
        };
        try self.init(content: csvString, delimiter: delim, encodingInt: encod)
    }
    
    func cleanCSVText(csvText: String)->String{
        // Clean Unwanted Character(s)
        var cleanText = csvText
        cleanText = cleanText.trimmingCharacters(in: CharacterSet.newlines)
            .replacingOccurrences(of: "\n\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "")
        return cleanText
    }
    
    // column header
    func parseHeader(fromLines line: String)->[String] {
        /// return customed Headers (array of headers)
        let headerString = self.customHeadersString(headerString: line)
        return headerString.components(separatedBy: self.delimiter)
    }
    
    // Transformed each CSV rows into array of dictionaries. Each dictionary equvalent each column. Dictionary contains cell data
    func parseRowsArray(fromLines lines: [String])->[Dictionary<String,String>] {
        var rows : [Dictionary<String, String>] = []
        
        for (lineNumber, line) in lines.enumerated() {
            if lineNumber == 0 { continue }
            
            var row = Dictionary<String, String>()
            let values = line.components(separatedBy: self.delimiter)
            for (index, header) in self.headers.enumerated() {
                if index < values.count {
                    row[header] = values[index]
                } else {
                    row[header] = ""
                }
            }
            rows.append(row)
        }
        return rows
    }
    
    // Transformed each CSV rows into dictionaries of dictionaries, perfect for table with multiple repeated elements. Allows count same/repeated elements
    func parseRowsJSON(fromLines lines: [String])-> Dictionary<String, Dictionary<String, String>>{
        var dictsJSON = Dictionary<String, Dictionary<String, String>>()
        
        for (lineNumber, line) in lines.enumerated() {
            if lineNumber == 0 { continue }
            
            var row = Dictionary<String, String>()
            let values = line.components(separatedBy: self.delimiter)
            let primeName = "partNumber"
            
            for (index, header) in self.headers.enumerated() {
                if index < values.count {
                    row[header] = values[index]
                } else {
                    row[header] = ""
                }
            }
            row["count"] = "1"
            
            // if we have partNumber Key-Value in row
            if let primeKey = row[primeName]{
                
                // Check if we already had the same item listed in our dictionaries
                if let x = dictsJSON[primeKey] {
                    if let countString = x["count"] {
                        // if do, we just add the "count" value in that dictionary
                        var count = Int(countString)!
                        count = count+1
                        dictsJSON[primeKey]!["count"] = "\(count)"
                        continue
                    }
                }
                // If turns out we never had that item before, just make new dictionary inside dicts
                dictsJSON[primeKey] = row
                continue
            }
        }
        return dictsJSON
    }
    
    // Transformed each CSV columns into arrays of strings, each string represent cell data
    func parseColumnsJSON(fromLines lines: [String], groupBy prime: Int)-> Dictionary<String, [String]>{
        var cols = Dictionary<String, [String]>()
        
        for (lineNumber, line) in lines.enumerated(){
            if lineNumber == 0 { continue }
            
            var col = [String]()
            let values = line.components(separatedBy: self.delimiter)
            let header = values[prime]
            for (index, value) in values.enumerated() {
                if index == prime { continue }
                col.append(value)
            }
            cols[header] = col
        }
        return cols
    }
}
