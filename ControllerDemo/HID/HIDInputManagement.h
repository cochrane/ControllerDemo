//
//  HIDInputManagement.h
//  ControllerDemo
//
//  Created by Torsten Kammer on 28.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HIDDevice;

@interface HIDInputManagement : NSObject

+ (NSString *)nameForElementPage:(uint32_t)page usage:(uint32_t)usage;

@property (nonatomic, readonly) NSMutableArray<HIDDevice *> * connectedDevices;

@end
