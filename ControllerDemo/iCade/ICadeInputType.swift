//
//  ICadeInputType.swift
//  ControllerDemo
//
//  Created by Torsten Kammer on 29.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

import Cocoa

@objc class ICadeInputType : NSObject, InputType {
    var name: String {
        return "iCade"
    }
    
    @objc static let sharedInput = ICadeInputType()
    
    var elements: [InputElement]
    
    override init() {
        elements = []
        elements.append(ICadeInputElement(name:"Up", keyDownForActive:"w", keyDownForInactive:"e"))
        elements.append(ICadeInputElement(name:"Left", keyDownForActive:"a", keyDownForInactive:"q"))
        elements.append(ICadeInputElement(name:"Right", keyDownForActive:"d", keyDownForInactive:"c"))
        elements.append(ICadeInputElement(name:"Down", keyDownForActive:"x", keyDownForInactive:"z"))
        elements.append(ICadeInputElement(name:"Button 1", keyDownForActive:"u", keyDownForInactive:"f"))
        elements.append(ICadeInputElement(name:"Button 2", keyDownForActive:"h", keyDownForInactive:"r"))
        elements.append(ICadeInputElement(name:"Button 3", keyDownForActive:"y", keyDownForInactive:"t"))
        elements.append(ICadeInputElement(name:"Button 4", keyDownForActive:"j", keyDownForInactive:"n"))
        elements.append(ICadeInputElement(name:"Button 5", keyDownForActive:"l", keyDownForInactive:"v"))
        elements.append(ICadeInputElement(name:"Button 6", keyDownForActive:"o", keyDownForInactive:"g"))
    }
    
    func process(keyDownEvent: NSEvent) {
        if let characters = keyDownEvent.characters {
            for element in elements {
                let icadeElement = element as! ICadeInputElement
                if characters == icadeElement.keyDownForActive {
                    icadeElement.value = 1
                } else if characters == icadeElement.keyDownForInactive {
                    icadeElement.value = 0
                }
            }
        }
    }
}

@objc class ICadeInputElement : NSObject, InputElement {
    init(name: String, keyDownForActive: String, keyDownForInactive: String) {
        self.name = name
        self.keyDownForActive = keyDownForActive
        self.keyDownForInactive = keyDownForInactive
        self.value = 0
    }
    
    let keyDownForActive : String
    let keyDownForInactive : String
    let name: String
    
    var min: Double {
        return 0
    }
    
    var max: Double {
        return 1
    }
    
    @objc dynamic var value: Double {
        willSet {
            willChangeValue(forKey:"value")
            willChangeValue(forKey:"nonNanValue")
        }
        didSet {
            didChangeValue(forKey:"value")
            didChangeValue(forKey:"nonNanValue")
        }
    }
    
    @objc dynamic var nonNanValue: Double {
        return value;
    }
    
    
}
