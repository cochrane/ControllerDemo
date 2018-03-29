//
//  Interfaces.swift
//  ControllerDemo
//
//  Created by Torsten Kammer on 28.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

import Foundation

@objc protocol InputType {
    @objc var name : String { get }
    
    @objc var elements : [InputElement] { get }
}

@objc protocol InputElement {
    var name : String { get }
    var min : Double { get }
    var max : Double { get }
    var value : Double { get }
    var nonNanValue : Double { get }
}
