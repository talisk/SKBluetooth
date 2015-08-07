//
//  SKBluetoothManager.h
//  SKBluetoothManager
//
//  Created by 孙恺 on 15/5/15.
//  Copyright (c) 2015年 Kai Sun. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@protocol SKBluetoothManagerDelegate

@required
- (void)didGetDataForString:(NSString *)dataString;

@end

@interface SKBluetoothManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>{
    CBCentralManager *manager;
    id<SKBluetoothManagerDelegate> delegate;
}

@property BOOL isConnected;
@property (retain, nonatomic) id<SKBluetoothManagerDelegate> delegate;
@property (nonatomic, strong) CBPeripheral *peripheral;

- (void)writeToPeripheral:(NSString *)dataString;
- (void)scan;

@end
