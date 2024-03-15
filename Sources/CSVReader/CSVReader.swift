//
//  CSVReader.swift
//  
//
//  Created by Merch Visoiu on 2024-03-14.
//

import Foundation

public enum CSVReaderError: Error {
    case fileNotFound
    case notAString
    case noFirstLine
}


public struct CSVReader {
    
    /// A range with quotes, or no comma, then no comma.
    private let PATTERN = "(?:\"(.*)\",)|(?:([^,]*),)|([^,]*)"
    
    /// The group with quotes.
    private let FIRST_RANGE = 1
    
    /// The typical group without quotes.
    private let SECOND_RANGE = 2
    
    /// The trailing value after the final comma.
    private let THIRD_RANGE = 3
    
    
    public init() {}
    
    
    /// read
    /// - Parameter url: The local file location.
    /// - Parameter keys: The header elements.
    /// - Returns: An array of dictionaries representing each line in the CSV file.
    public func read(from url: URL, keys: [String]) throws -> [[String: String]] {
        var res = [[String: String]]()
        guard FileManager.default.fileExists(atPath: url.path) else { throw CSVReaderError.fileNotFound }
        
        let data = try Data(contentsOf: url)
        guard let string = String(data: data, encoding: .utf8) else { throw CSVReaderError.notAString }
        var readFirstLine = false
        var keyToIndex = [String: Int]()
        let lines = string.components(separatedBy: "\r\n")
        for line in lines {
            
            /// Skip empty lines.
            guard line != "" else { continue }
            
            if readFirstLine == false {
                readFirstLine = true
                let lineComponents = line.components(separatedBy: ",")
                let trimmedLineComponents = lineComponents.compactMap({ $0.trimmingCharacters(in: .whitespacesAndNewlines ) })
                for keyString in keys {
                    let index = trimmedLineComponents.firstIndex(of: keyString)
                    keyToIndex[keyString] = index
                }
            } else {
                var newMap = [String: String]()
                let parsed = parse(line: line)
                
                for keyString in keys {
                    guard let index = keyToIndex[keyString] else { continue }
                    guard index < parsed.count else { continue }
                    let valueString = parsed[index]
                    newMap[keyString] = valueString
                }
            
                res.append(newMap)
            }
        }
        return res
    }
    
    private func parse(line: String) -> [String] {
        var res = [String]()
        let regex = try! NSRegularExpression(pattern: PATTERN)
        let matches = regex.matches(in: line, range: NSRange(location: 0, length: line.count))
        for match in matches {
            
            /// First check if it matches the quoted value, then check if it matches an unquoted value, then check if it matches the trailing value after the final comma.
            if let range = Range(match.range(at: FIRST_RANGE), in: line) ?? Range(match.range(at: SECOND_RANGE), in: line) ?? Range(match.range(at: THIRD_RANGE), in: line) {
                let value = line[range]
                res.append(String(value))
            }
        }
        return res
    }
}
