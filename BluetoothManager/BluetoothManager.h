//
//  BluetoothManager.h
//  StethoscopeDemo
//
//  Created by Healforce on 2017/2/16.
//  Copyright © 2017年 HealForce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothManagerDelegate <NSObject>

@optional   //----->可选协议
/****************************************
 * 停止搜索后会进行回调 *
 ****************************************/
- (void)srcBluetoothFinished;

/****************************************
 * 蓝牙状态改变后通知外部界面 *
 * CBManagerStateUnknown -- 中心管理器状态未知 *
 * CBManagerStateResetting -- 中心管理器状态重置 *
 * CBManagerStateUnsupported -- 中心管理器状态不被支持 *
 * CBManagerStateUnauthorized -- 中心管理器状态未被授权 *
 * CBManagerStatePoweredOff -- 中心管理器状态电源关闭 *
 * CBManagerStatePoweredOn -- 中心管理器状态电源开启 *
 ****************************************/
- (void)CW_CentralManagerDidUpdateState:(CBCentralManager *)central;

/****************************************
 * 搜索到蓝牙外设后调用 *
 * central : 蓝牙中心对象 *
 * peripheral : 搜索到的蓝牙外设 *
 * advertisementData : 一个包含任何广播和扫描响应数据的字典 *
 * RSSI : Received Signal Strength Indicator 是接收信号的强度指示 *
 ****************************************/
- (void)CW_CentralManager:(CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                     RSSI:(NSNumber *)RSSI;

/****************************************
 * 设备断开后通知外部界面进行相关操作 *
 * central : 蓝牙中心对象 *
 * peripheral : 搜索到的蓝牙外设 *
 * error : 错误回调 *
 ****************************************/
- (void)CW_CentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

/****************************************
 * 发现服务后的回调 *
 * peripheral : 连接上的蓝牙设备 *
 * service : 蓝牙设备中的服务 *
 * error : 错误回调 *
 ****************************************/
- (void)CW_Peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

/****************************************
 * 收到设备发送过来的数据时会执行该回调 *
 * 会多次调用 *
 * data : 收到的数据 *
 ****************************************/
- (void)CW_PeripheralData:(NSData *)data;

@required   //----->必选协议

@end

@interface BluetoothManager : NSObject

@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *peripheral;

@property (nonatomic,assign) id <BluetoothManagerDelegate> delegate;

+ (BluetoothManager *)shareManager;

/****************************************
 * 实例化蓝牙中心 *
 * 在此只作为蓝牙中心接受外设消息 *
 ****************************************/
- (void)getCentralManager;


/****************************************
 * 开始搜索蓝牙设备 *
 * secNum : 搜索多少秒后停止，0为马上停止 *
 ****************************************/
- (void)startSrcBluetooth:(NSInteger)secNum;


/****************************************
 * 停止搜索蓝牙设备 *
 ****************************************/
- (void)stopSrcBlueTooth;


/****************************************
 * 断开与蓝牙外设的连接 *
 ****************************************/
- (void)cutBoolthDevice;



@end
