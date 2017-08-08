//
//  BluetoothManager.m
//  StethoscopeDemo
//
//  Created by Healforce on 2017/2/16.
//  Copyright © 2017年 HealForce. All rights reserved.
//

#import "BluetoothManager.h"

@interface BluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    
}
@end

@implementation BluetoothManager

+ (BluetoothManager *)shareManager
{
    static BluetoothManager *manager;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        manager = [[BluetoothManager alloc] init];
    });
    return manager;
}

- (void)getCentralManager
{
    if (_centralManager == nil) {
        /*把蓝牙放在子线程中执行*/
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                             options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    }
}

- (void)startSrcBluetooth:(NSInteger)secNum
{
    //搜索成功之后,会调用我们找到外设的代理方法 services为空则会扫描所有的设备
    if (_centralManager.state == CBManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secNum * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_centralManager stopScan];
            
            if ([self.delegate respondsToSelector:@selector(srcBluetoothFinished)]) {
                [self.delegate srcBluetoothFinished];
            }
        });
    }
}

- (void)stopSrcBlueTooth
{
    [_centralManager stopScan];
    
    if ([self.delegate respondsToSelector:@selector(srcBluetoothFinished)]) {
        [self.delegate srcBluetoothFinished];
    }
}

- (void)cutBoolthDevice
{
    if (_peripheral != nil && _centralManager != nil) {
        [_centralManager cancelPeripheralConnection:_peripheral];
    }
}

- (void)setPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral;
}

#pragma mark - CBCentralManagerDelegate
/*CBCentralManager一旦初始化成功，就会调用该协议*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(CW_CentralManagerDidUpdateState:)]) {
            [self.delegate CW_CentralManagerDidUpdateState:central];
        }
    });
}

/*搜索到一个设备会调用一次*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(CW_CentralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
            [self.delegate CW_CentralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
        }
    });
}

/*设备连接成功后的回调*/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_peripheral != nil) {
            //外设发现服务,传nil代表不过滤
            _peripheral.delegate = self;
            [_peripheral discoverServices:nil];
        }
    });
}

/*设备连接失败*/
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"设备连接失败");
    });
}

/*设备已断开*/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(CW_CentralManager:didDisconnectPeripheral:error:)]) {
            [self.delegate CW_CentralManager:central didDisconnectPeripheral:peripheral error:error];
        }
    });
}

#pragma mark - CBPeripheralDelegate
/*发现外设的服务后调用的方法*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(CW_Peripheral:didDiscoverServices:)]) {
            [self.delegate CW_Peripheral:peripheral didDiscoverServices:error];
        }
    });
}

/*发现服务后,让设备再发现服务内部的特征*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(CW_Peripheral:didDiscoverCharacteristicsForService:error:)]) {
            [self.delegate CW_Peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
        }
    });
}

/*收到设备发送过来的数据*/
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (characteristic != nil) {
            if ([self.delegate respondsToSelector:@selector(CW_PeripheralData:)]) {
                [self.delegate CW_PeripheralData:characteristic.value];
            }
        }
    });
}

@end
