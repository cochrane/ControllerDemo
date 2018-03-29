//
//  GameController.swift
//  ControllerDemo
//
//  Created by Torsten Kammer on 29.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

import Foundation
import GameController

func createElements(for button: GCControllerButtonInput, name: String) -> [InputElement] {
    return [
        GameControllerButtonBinaryElement(input: button, name: name + " (binary)"),
        GameControllerButtonElement(input: button, name: name + " (pressure)")
    ]
}

func createElements(for dpad: GCControllerDirectionPad, name: String) -> [InputElement] {
    var result : [InputElement] = []
    result.append(contentsOf: createElements(for: dpad.up, name: name + " Up"))
    result.append(contentsOf: createElements(for: dpad.left, name: name + " Left"))
    result.append(contentsOf: createElements(for: dpad.right, name: name + " Right"))
    result.append(contentsOf: createElements(for: dpad.down, name: name + " Down"))
    result.append(GameControllerAxisElement(input: dpad.xAxis, name: name + " x-Axis"))
    result.append(GameControllerAxisElement(input: dpad.yAxis, name: name + " y-Axis"))
    return result
}

@objc class GameControllerManager : NSObject {
    // TODO: Discovery, removal, addition
    // Need superclass that handles it for both HID and game controller
    @objc dynamic var controllers : [GameControllerDevice]
    
    override init() {
        self.controllers = []
        for controller in GCController.controllers() {
            self.controllers.append(GameControllerDevice(controller: controller))
        }
        super.init()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil, using: {notification in
            self.willChangeValue(forKey: "controllers")
            self.controllers.append(GameControllerDevice(controller: notification.object as! GCController))
            self.didChangeValue(forKey: "controllers")
        })
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: nil, using: {notification in
            self.willChangeValue(forKey: "controllers")
            if let index = self.controllers.index(where: { $0.controller == notification.object as! GCController }) {
                self.controllers.remove(at: index)
            }
            self.didChangeValue(forKey: "controllers")
        })
    }
}

@objc class GameControllerDevice : NSObject, InputType {
    let controller: GCController
    let elements: [InputElement]
    
    init(controller: GCController) {
        self.controller = controller
        var elements: [InputElement] = []
        if let microProfile = controller.microGamepad {
            elements.append(contentsOf: createElements(for: microProfile.buttonA, name: "Micro: A"))
            elements.append(contentsOf: createElements(for: microProfile.buttonX, name: "Micro: X"))
            elements.append(contentsOf: createElements(for: microProfile.dpad, name: "Micro: DPad"))
        }
        if let normalProfile = controller.gamepad {
            elements.append(contentsOf: createElements(for: normalProfile.buttonA, name: "Normal: A"))
            elements.append(contentsOf: createElements(for: normalProfile.buttonB, name: "Normal: B"))
            elements.append(contentsOf: createElements(for: normalProfile.buttonX, name: "Normal: X"))
            elements.append(contentsOf: createElements(for: normalProfile.buttonY, name: "Normal: Y"))
            elements.append(contentsOf: createElements(for: normalProfile.leftShoulder, name: "Normal: Left shoulder"))
            elements.append(contentsOf: createElements(for: normalProfile.rightShoulder, name: "Normal: Right shoulder"))
            elements.append(contentsOf: createElements(for: normalProfile.dpad, name: "Normal: DPad"))
        }
        if let extendedProfile = controller.extendedGamepad {
            elements.append(contentsOf: createElements(for: extendedProfile.buttonA, name: "Extended: A"))
            elements.append(contentsOf: createElements(for: extendedProfile.buttonB, name: "Extended: B"))
            elements.append(contentsOf: createElements(for: extendedProfile.buttonX, name: "Normal: X"))
            elements.append(contentsOf: createElements(for: extendedProfile.buttonY, name: "Extended: Y"))
            elements.append(contentsOf: createElements(for: extendedProfile.leftShoulder, name: "Extended: Left shoulder"))
            elements.append(contentsOf: createElements(for: extendedProfile.leftTrigger, name: "Extended: Left trigger"))
            elements.append(contentsOf: createElements(for: extendedProfile.rightShoulder, name: "Extended: Right shoulder"))
            elements.append(contentsOf: createElements(for: extendedProfile.rightTrigger, name: "Extended: Right trigger"))
            elements.append(contentsOf: createElements(for: extendedProfile.dpad, name: "Extended: DPad"))
            elements.append(contentsOf: createElements(for: extendedProfile.leftThumbstick, name: "Extended: Left stick"))
            elements.append(contentsOf: createElements(for: extendedProfile.rightThumbstick, name: "Extended: Right stick"))
        }
        self.elements = elements
        
        super.init()
        
        if let microProfile = controller.microGamepad {
            microProfile.valueChangedHandler = { (pad, element) in
                self.update()
            }
        }
        if let normalProfile = controller.gamepad {
            normalProfile.valueChangedHandler = { (pad, element) in
                self.update()
            }
        }
        if let extendedProfile = controller.extendedGamepad {
            extendedProfile.valueChangedHandler = { (pad, element) in
                self.update()
            }
        }
    }
    
    func setupValueChangedHandlers() {
        
    }
    
    var name: String {
        return controller.vendorName!
    }
    
    func update() {
        for element in elements {
            let gameControllerElement = element as! GameControllerElement
            gameControllerElement.update()
        }
    }
}

@objc class GameControllerElement : NSObject, InputElement {
    
    let name : String
    
    init(name: String) {
        self.name = name;
    }
    
    var min: Double {
        return 0
    }
    
    var max: Double {
        return 1
    }
    
    dynamic var value: Double {
        return 0
    }
    
    dynamic var nonNanValue : Double {
        let current = self.value
        if (current != current) {
            return 0
        }
        return current
    }
    
    func update() {
        self.willChangeValue(forKey: "nonNanValue")
        self.willChangeValue(forKey: "value")
        self.didChangeValue(forKey: "value")
        self.didChangeValue(forKey: "nonNanValue")
    }
}

@objc class GameControllerButtonBinaryElement : GameControllerElement {
    let input : GCControllerButtonInput
    
    init(input: GCControllerButtonInput, name: String) {
        self.input = input;
        super.init(name: name)
    }
    
    override var value: Double {
        return input.isPressed ? 1 : 0
    }
}

@objc class GameControllerButtonElement : GameControllerElement {
    let input : GCControllerButtonInput
    
    init(input: GCControllerButtonInput, name: String) {
        self.input = input;
        super.init(name: name)
    }
    
    dynamic override var value: Double {
        return Double(input.value)
    }
}

@objc class GameControllerAxisElement : GameControllerElement {
    let input : GCControllerAxisInput
    
    init(input: GCControllerAxisInput, name: String) {
        self.input = input;
        super.init(name: name)
    }
    
    override var min: Double {
        return -1;
    }
    
    dynamic override var value: Double {
        return Double(input.value)
    }
}
