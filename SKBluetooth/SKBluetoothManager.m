//
//  SKBluetoothManager.m
//  SKBluetoothManager
//
//  Created by 孙恺 on 15/5/15.
//  Copyright (c) 2015年 Kai Sun. All rights reserved.
//

//  请务必根据您所使用的设备来修改 UUID

#define kPeripheralUUID @"F92FE801-4151-A61F-28DA-BD109B645CBA"

#define kServiceUUID @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
#define kCharacteristicWriteUUID @"49535343-8841-43F4-A8D4-ECBE34729BB3"            // inUse
#define kCharacteristicNotifyUUID @"49535343-1E4D-4BD9-BA61-23C647249616"           // inUse
#define kCharacteristicWriteNotifyUUID @"49535343-ACA3-481C-91EC-D85E28A60318"
#define kCharacteristicReadWriteUUID @"49535343-6DAA-4D02-ABF6-19569ACA69FE"

#import "SKBluetoothManager.h"

@interface SKBluetoothManager()

@property (strong,nonatomic) NSMutableArray *peripherals;   //连接的外围设备
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@end

@implementation SKBluetoothManager

@synthesize delegate=delegate;

#pragma mark - Public Methods

- (void)writeToPeripheral:(NSString *)dataString {
    if(_writeCharacteristic == nil){
        NSLog(@"writeCharacteristic 为空");
        return;
    }
    NSData *value = [self dataWithHexstring:dataString];
//    NSLog(@"十六进制:%@",value);
    [_peripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"已经向外设%@写入数据%@",_peripheral.name,dataString);

}

- (void)scan{
    [manager scanForPeripheralsWithServices:nil
                                    options:nil];
    NSLog(@"开始扫描");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        manager.delegate = self;
        _isConnected = NO;
    }
    return self;
}

#pragma mark - CBPeripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"已发现服务");
    if (error) {
        NSLog(@"搜索服务%@时发生错误:%@", peripheral.name, [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        //发现服务
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
            NSLog(@"发现服务:%@", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"搜索特征%@时发生错误:%@", service.UUID, [error localizedDescription]);
        return;
    }
    NSLog(@"服务:%@",service.UUID);
    for (CBCharacteristic *characteristic in service.characteristics) {
//        NSLog(@"特征:%@",characteristic);
        //发现特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicWriteUUID]]) {
            _writeCharacteristic = characteristic;
        }
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicNotifyUUID]]) {
            NSLog(@"监听特征:%@",characteristic);//监听特征
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            _isConnected = YES;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"更新特征值%@时发生错误:%@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    // 收到数据
//    NSLog(@"%@",characteristic.value);
    [delegate didGetDataForString:[self hexadecimalString:characteristic.value]];
//    NSLog(@"%@",[self hexadecimalString:characteristic.value]);
}

#pragma mark - CBCentralManager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString * state = nil;
    
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"StateUnsupported";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"StateUnauthorized";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"PoweredOff";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"PoweredOn";
            break;
        case CBCentralManagerStateUnknown:
            state = @"unknown";
            break;
        default:
            break;
    }
    NSLog(@"手机状态:%@", state);
}

// 发现外设后
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *str = [NSString stringWithFormat:@"发现外设:%@ rssi:%@, UUID:%@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier.UUIDString, advertisementData];
    NSLog(@"%@",str);
    [_peripherals addObject:peripheral];
    
    if ([peripheral.name isEqualToString:@"Dual-SPP"]) {
        [manager stopScan];
        [manager connectPeripheral:peripheral options:nil];
        NSLog(@"连接外设:%@",peripheral.description);
        self.peripheral = peripheral;
    }
}

// 连接到外设后
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"已经连接到:%@", peripheral.description);
    peripheral.delegate = self;
    [central stopScan];
    [peripheral discoverServices:nil];
}

// 连接失败后
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接外设%@失败",peripheral);
}

// 断开外设
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"与%@断开连接",peripheral);
}

#pragma mark - NSData and NSString

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}
//将传入的NSString类型转换成NSData并返回
- (NSData*)dataWithHexstring:(NSString *)hexstring{
    NSData* aData;
    return aData = [hexstring dataUsingEncoding: NSASCIIStringEncoding];
}

@end