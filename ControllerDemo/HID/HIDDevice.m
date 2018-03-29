//
//  HIDDevice.m
//  ControllerDemo
//
//  Created by Torsten Kammer on 28.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import "HIDDevice.h"
#import "HIDInputElement.h"

@implementation HIDDevice

- (instancetype)initWithDevice:(IOHIDDeviceRef _Nonnull)aDevice {
    if (!(self = [super init]))
        return nil;
    
    _device = aDevice;
    CFRetain(_device);
    
    CFArrayRef elements = IOHIDDeviceCopyMatchingElements(_device, NULL, 0);
    
    NSMutableArray *wrappedElements = [[NSMutableArray alloc] initWithCapacity:CFArrayGetCount(elements)];
    for (CFIndex i = 0; i < CFArrayGetCount(elements); i++) {
        IOHIDElementRef element = (IOHIDElementRef) CFArrayGetValueAtIndex(elements, i);
        HIDInputElement *elementWrapper = [[HIDInputElement alloc] initWithElement:element];
        [wrappedElements addObject:elementWrapper];
    }
    
    _elements = wrappedElements;
    
    CFRelease(elements);
    
    return self;
}

- (NSUInteger)hash {
    return CFHash(_device);
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    
    HIDDevice *other = (HIDDevice *)object;
    return self.device == other.device;
}

- (NSString *)name {
    return (__bridge NSString *) IOHIDDeviceGetProperty(_device, CFSTR(kIOHIDProductKey));
}

- (void)dealloc {
    CFRelease(_device);
}

- (void)forceUpdate {
    [self.elements makeObjectsPerformSelector:_cmd];
}

@end
