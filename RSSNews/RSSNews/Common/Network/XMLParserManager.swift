//
//  XMLParserManager.swift
//  RSSNews
//
//  Created by Prometei on 12/2/19.
//  Copyright © 2019 Prometei. All rights reserved.
//

import Foundation

class XMLParserManager: NSObject {
    
    private var rssItems = [RSSItem]()
    private var currentElement = ""
    
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentPubDate: String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    func parseData(by url: String, completionHandler: @escaping (([RSSItem]) -> Void)) -> Void {
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            guard let data = data else {
                guard let error = error else { return }
                print(error)
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            completionHandler(self.rssItems)
            self.rssItems.removeAll()
        }
        
        task.resume()
    }
}

// MARK: - XMLParserDelegate
extension XMLParserManager: XMLParserDelegate {
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        guard currentElement == "item" else { return }
        currentTitle = ""
        currentDescription = ""
        currentPubDate = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string
        case "description":
            currentDescription += string
        case "pubDate":
            currentPubDate += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        guard elementName == "item" else { return }
        let rssItem = RSSItem(title: currentTitle, description: currentDescription, pubDate: currentPubDate)
        rssItems += [rssItem]
    }
}
