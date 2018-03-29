//
//  HIDInputElement.m
//  ControllerDemo
//
//  Created by Torsten Kammer on 28.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import "HIDInputElement.h"
#import "HIDInputManagement.h"

@interface HIDInputElement() {
    double lastValue;
    BOOL didReadValue;
}
@end

@implementation HIDInputElement

+ (NSSet<NSString *> *)keyPathsForValuesAffectingNonNanValue {
    return [NSSet setWithObject:@"value"];
}

- (id)initWithElement:(IOHIDElementRef)anElement {
    if (!(self = [super init]))
        return nil;
    
    _element = anElement;
    CFRetain(_element);
    
    didReadValue = NO;
    
    return self;
}

- (void)dealloc {
    CFRelease(_element);
}

- (NSString *)name {
    uint32_t page = IOHIDElementGetUsagePage(_element);
    uint32_t usage = IOHIDElementGetUsage(_element);
    
    return [HIDInputManagement nameForElementPage:page usage:usage];
}

- (double)min {
    return IOHIDElementGetPhysicalMin(_element);
}

- (double)max {
    return IOHIDElementGetPhysicalMax(_element);
}

- (double) value {
    if (!didReadValue) {
        didReadValue = YES;
        
        IOHIDDeviceRef device = IOHIDElementGetDevice(_element);
        IOHIDValueRef value;
        IOReturn result = IOHIDDeviceGetValue(device, _element, &value);
        if (result != kIOReturnSuccess)
            lastValue = NAN;
        else
            lastValue = IOHIDValueGetIntegerValue(value);
    }
    return lastValue;
}

- (double) nonNanValue {
    double value = [self value];
    if (isnan(value))
        return 0.0;
    return value;
}

- (void)forceUpdate; {
    [self willChangeValueForKey:@"value"];
    IOHIDDeviceRef device = IOHIDElementGetDevice(_element);
    IOHIDValueRef value;
    IOReturn result = IOHIDDeviceGetValue(device, _element, &value);
    if (result != kIOReturnSuccess)
        lastValue = NAN;
    else
        lastValue = IOHIDValueGetIntegerValue(value);
    [self didChangeValueForKey:@"value"];
}

@end
