//
//  HIDInputElement.h
//  ControllerDemo
//
//  Created by Torsten Kammer on 28.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>

#import "ControllerDemo-Swift.h"

@interface HIDInputElement : NSObject <InputElement>

- (id)initWithElement:(IOHIDElementRef)element;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, assign) double min;
@property (nonatomic, readonly, assign) double max;
@property (nonatomic, readonly, assign) double value;
@property (nonatomic, readonly, assign) double nonNanValue;

@property (nonatomic, readonly, assign) IOHIDElementRef element;

- (void)forceUpdate;

@end
