//
//  ICadeWindow.swift
//  ControllerDemo
//
//  Created by Torsten Kammer on 29.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

import Cocoa

class ICadeWindow: NSWindow {
    
    override func sendEvent(_ event: NSEvent) {
        if (event.type == .keyDown) {
            ICadeInputType.sharedInput.process(keyDownEvent: event)
        } else if (event.type == .keyUp) {
            // Swallowed, because we don't allow key-down events either
        }
        
        super.sendEvent(event)
    }

}
