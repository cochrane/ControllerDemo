//
//  InputList.m
//  ControllerDemo
//
//  Created by Torsten Kammer on 29.03.18.
//  Copyright © 2018 Torsten Kammer. All rights reserved.
//

#import "InputList.h"

#import "HIDInputManagement.h"
#import "ControllerDemo-Swift.h"

@interface InputList()
- (void)recalculate;
@end

@implementation InputList

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    _hid = [[HIDInputManagement alloc] init];
    [_hid addObserver:self forKeyPath:@"connectedDevices" options:NSKeyValueObservingOptionNew context:NULL];
    
    _gc = [[GameControllerManager alloc] init];
    [_gc addObserver:self forKeyPath:@"controllers" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self recalculate];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self willChangeValueForKey:@"inputs"];
    [self recalculate];
    [self didChangeValueForKey:@"inputs"];
}

- (void)recalculate {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObjectsFromArray:_hid.connectedDevices];
    [result addObjectsFromArray:_gc.controllers];
    [result addObject:[ICadeInputType sharedInput]];
    _inputs = result;
}

@end
