//
//  HIDDevice.h
//  ControllerDemo
//
//  Created by Torsten Kammer on 28.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>

#import "ControllerDemo-Swift.h"

@interface HIDDevice<InputDevice> : NSObject

- (instancetype _Nonnull )initWithDevice:(_Nonnull IOHIDDeviceRef)device;

@property (nonatomic, readonly, copy) NSArray<id <InputElement>> * _Nonnull elements;
@property (nonatomic, copy) NSString * _Nonnull name;

@property (nonatomic, readonly, assign) IOHIDDeviceRef _Nonnull device;

@end
