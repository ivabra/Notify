//
//  Notify.swift
//  GuessPointApp
//
//  Created by Ivan Brazhnikov on 25/09/15.
//  Copyright © 2015 Ivan Brazhnikov. All rights reserved.
//

import Foundation


func notify(who: NSObject) -> Notifier {
    return Notifier(object: who)
}

func postAbout(something: String..., and andData: [NSObject : AnyObject]? = nil, fromObject object: AnyObject? = nil) {
    let center = NSNotificationCenter.defaultCenter()
    something.forEach { center.postNotificationName($0, object: object, userInfo: andData) }
}

func postNotification(about something: String..., and andData : [NSObject : AnyObject]? = nil, fromObject object: AnyObject? = nil) {
    let center = NSNotificationCenter.defaultCenter()
    something.forEach { center.postNotificationName($0, object: object, userInfo: andData) }
}

class Notifier {
    
    private var intents = [Intent]()
    private weak var object: NSObject!
    private init(object: NSObject) {
        self.object = object
    }
    
    func about(something: String...) -> Intent {
        return Intent(parent: self, notificationNames: something)
    }
    
    func about(something: String..., fromObject object: NSObject) -> Intent {
        return Intent(parent: self, notificationNames: something, fromObject: object)
    }
    
    
    class Intent{
        private var selector: Selector!
        private var tokens: [NSObjectProtocol]!
        private let notificationNames: [String]
        private let parent: Notifier
        private weak var fromObject: NSObject?
        
        private init(parent: Notifier, notificationNames: [String], fromObject: NSObject? = nil) {
            self.parent = parent
            self.notificationNames = notificationNames
            self.fromObject = fromObject
        }
        
        func to(selector: Selector) -> Notifier {
            notificationNames.forEach {NSNotificationCenter.defaultCenter().addObserver(parent.object, selector: selector, name: $0, object: fromObject) }
            
            return parent
        }
        
        func to(block: (NSNotification) -> Void) -> Notifier {
            return self.to(NSOperationQueue.mainQueue(), block: block)
        }
        
        func to(queue: NSOperationQueue, block: (NSNotification) -> Void) -> Notifier {
            tokens = notificationNames.map{NSNotificationCenter.defaultCenter().addObserverForName($0, object: fromObject, queue: queue, usingBlock: block)}
          
            return parent
        }
        
        
    }
    
    func destroy(){
        let center = NSNotificationCenter.defaultCenter()
        if let o = object {
            center.removeObserver(o)
        }
        intents.forEach {
            if let tokens = $0.tokens {
                tokens.forEach {
                    center.removeObserver($0)
                }
            }
        }
        
    }
}