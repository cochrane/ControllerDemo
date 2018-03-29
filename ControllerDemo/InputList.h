//
//  InputList.h
//  ControllerDemo
//
//  Created by Torsten Kammer on 29.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HIDInputManagement;
@class GameControllerManager;

@interface InputList : NSObject

@property (nonatomic, retain, readonly) HIDInputManagement *hid;
@property (nonatomic, retain, readonly) GameControllerManager *gc;
@property (nonatomic, retain, readonly) NSArray *inputs;

@end
