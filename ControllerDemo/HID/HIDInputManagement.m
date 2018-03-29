//
//  HIDInputManagement.m
//  ControllerDemo
//
//  Created by Torsten Kammer on 28.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import "HIDInputManagement.h"
#import <IOKit/hid/IOHIDUsageTables.h>
#import "HIDDevice.h"
#import "HIDInputElement.h"

@interface HIDInputManagement() {
    IOHIDManagerRef hidManager;
}

- (void)deviceAdded:(IOHIDDeviceRef)device;
- (void)deviceRemoved:(IOHIDDeviceRef)device;

- (void)newHidValue:(IOHIDValueRef)value;

@end

void hidDeviceAddedCallback (void * _Nullable context, IOReturn result, void * _Nullable sender, IOHIDDeviceRef device) {
    if (result != kIOReturnSuccess)
        return;
    
    [(__bridge HIDInputManagement *) context deviceAdded:device];
}

void hidDeviceRemovedCallback (void * _Nullable context, IOReturn result, void * _Nullable sender, IOHIDDeviceRef device) {
    if (result != kIOReturnSuccess)
        return;
    
    [(__bridge HIDInputManagement *) context deviceRemoved:device];
}

/*
 * Callback called by the HID manager when an input value changes.
 */
void hidValueCallback (void *context, IOReturn result, void *sender, IOHIDValueRef value) {
    if (result != kIOReturnSuccess)
        return;
    
    [(__bridge HIDInputManagement *) context newHidValue:value];
}

static NSDictionary<NSNumber*, NSDictionary<NSNumber*, NSString*>*> *namesForPagesAndKeys;

@implementation HIDInputManagement

+ (NSDictionary<NSNumber*, NSString*> *)namesForUsagesStartingWith:(NSString *)prefix in:(NSString *)header {
    NSMutableDictionary<NSNumber*, NSString*> *dictionary = [[NSMutableDictionary alloc] init];
    
    NSScanner *scanner = [NSScanner scannerWithString:header];
    while ([scanner scanUpToString:prefix intoString:NULL]) {
        [scanner scanString:prefix intoString:NULL];
        
        NSString *name;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&name];
        
        [scanner scanUpToString:@"=" intoString:NULL];
        [scanner scanString:@"=" intoString:NULL];
        
        unsigned int value;
        [scanner scanHexInt:&value];
        
        dictionary[@(value)] = name;
    }
    return dictionary;
}

+ (NSString *)nameForElementPage:(uint32_t)page usage:(uint32_t)usage;
{
    if (page == kHIDPage_Button) {
        return [NSString stringWithFormat:@"Button %u", usage];
    }
    
    if (!namesForPagesAndKeys) {
        NSError *error = nil;
        NSString *fullHeaderFile = [NSString stringWithContentsOfFile:@"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/hid/IOHIDUsageTables.h" encoding:NSASCIIStringEncoding error:&error];
        if (!fullHeaderFile) {
            NSLog(@"Error loading header: %@", error);
            namesForPagesAndKeys = @{};
        } else {
            NSMutableDictionary *keyboardDict = [[NSMutableDictionary alloc] init];
            [keyboardDict addEntriesFromDictionary:[self namesForUsagesStartingWith:@"kHIDUsage_Keyboard" in:fullHeaderFile]];
            [keyboardDict addEntriesFromDictionary:[self namesForUsagesStartingWith:@"kHIDUsage_Keypad" in:fullHeaderFile]];
            namesForPagesAndKeys = @{
            @(kHIDPage_GenericDesktop):
                 [self namesForUsagesStartingWith:@"kHIDUsage_GD_" in:fullHeaderFile],
            @(kHIDPage_Simulation):
                [self namesForUsagesStartingWith:@"kHIDUsage_Sim_" in:fullHeaderFile],
            @(kHIDPage_VR):
                [self namesForUsagesStartingWith:@"kHIDUsage_VR_" in:fullHeaderFile],
            @(kHIDPage_Sport):
                [self namesForUsagesStartingWith:@"kHIDUsage_Sprt_" in:fullHeaderFile],
            @(kHIDPage_Game):
                [self namesForUsagesStartingWith:@"kHIDUsage_Game_" in:fullHeaderFile],
            @(kHIDPage_Consumer):
                [self namesForUsagesStartingWith:@"kHIDUsage_Csmr_" in:fullHeaderFile],
            @(kHIDPage_PowerDevice):
                [self namesForUsagesStartingWith:@"kHIDUsage_PD_" in:fullHeaderFile],
            @(kHIDPage_BatterySystem):
                [self namesForUsagesStartingWith:@"kHIDUsage_BS_" in:fullHeaderFile],
            @(kHIDPage_KeyboardOrKeypad):
                keyboardDict,
            };
        }
    }
    
    NSString *result = namesForPagesAndKeys[@(page)][@(usage)];
    if (!result)
        return [NSString stringWithFormat:@"Element Page %x/Usage %x", page, usage];
    return result;
}

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    _connectedDevices = [[NSMutableArray alloc] init];
    
    hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDManagerOptionNone);
    
    IOHIDManagerSetDeviceMatching(hidManager, NULL);
    
    IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    // TODO Leaks self
    IOHIDManagerRegisterDeviceMatchingCallback(hidManager, hidDeviceAddedCallback, (void *) CFBridgingRetain(self));
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, hidDeviceRemovedCallback, (void *) CFBridgingRetain(self));
    IOHIDManagerRegisterInputValueCallback(hidManager, hidValueCallback, (void *) CFBridgingRetain(self));
    
    IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
    
    return self;
}

- (void)deviceAdded:(IOHIDDeviceRef)device {
    [self willChangeValueForKey:@"connectedDevices"];
    [_connectedDevices addObject:[[HIDDevice alloc] initWithDevice:device]];
    [self didChangeValueForKey:@"connectedDevices"];
}

- (void)deviceRemoved:(IOHIDDeviceRef)device {
    [self willChangeValueForKey:@"connectedDevices"];
    [_connectedDevices removeObject:[[HIDDevice alloc] initWithDevice:device]];
    [self didChangeValueForKey:@"connectedDevices"];
}

- (void)newHidValue:(IOHIDValueRef)value {
    IOHIDElementRef changedElement = IOHIDValueGetElement(value);
    IOHIDDeviceRef changedDevice = IOHIDElementGetDevice(changedElement);
    for (HIDDevice *device in _connectedDevices) {
        if (device.device == changedDevice) {
            for (HIDInputElement *element in device.elements) {
                if (element.element == changedElement) {
                    [element forceUpdate];
                }
            }
        }
    }
}

@end
