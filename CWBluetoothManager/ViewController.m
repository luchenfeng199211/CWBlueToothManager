//
//  ViewController.m
//  CWBluetoothManager
//
//  Created by Healforce on 2017/6/2.
//  Copyright © 2017年 ChrisWei. All rights reserved.
//

#import "ViewController.h"

#import "BluetoothManager.h"

@interface ViewController () <BluetoothManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIButton              *button;
@property (nonatomic, strong) UITableView           *tableView;

@property (nonatomic, strong) NSMutableArray        *peripherals;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripherals = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadSubViews];
    [self loadBluetoothManager];
}

- (void)loadSubViews
{
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 20, 100, 44);
    self.button.backgroundColor = [UIColor redColor];
    [self.button setTitle:@"搜索蓝牙" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(searchBLEClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)loadBluetoothManager
{
    [[BluetoothManager shareManager] getCentralManager];
    [BluetoothManager shareManager].delegate = self;
}

- (void)searchBLEClick
{
    [self searchBLE];
}

- (void)searchBLE
{
    if (self.peripherals.count > 0) {
        [self.peripherals removeAllObjects];
    }
    [[BluetoothManager shareManager] startSrcBluetooth:5];
}

#pragma mark - BluetoothManager Delegate
- (void)srcBluetoothFinished
{
    NSLog(@"count ==== %ld || %@",self.peripherals.count, self.peripherals);
    [self.tableView reloadData];
}

- (void)CW_CentralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn) {
        [self searchBLE];
    }
}

- (void)CW_CentralManager:(CBCentralManager *)central
    didDiscoverPeripheral:(CBPeripheral *)peripheral
        advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                     RSSI:(NSNumber *)RSSI
{
    if ([peripheral.name isEqualToString:@"Xsleep Ble"]) {
        [self.peripherals addObject:peripheral];
        NSLog(@"peripheral ===== %@",peripheral);
    }
}

- (void)CW_CentralManager:(CBCentralManager *)central
  didDisconnectPeripheral:(CBPeripheral *)peripheral
                    error:(NSError *)error
{
    NSLog(@"设备断开");
}

- (void)CW_Peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"error:%@",error.localizedDescription);
    }else{
        for (CBService *service in peripheral.services) {
            NSLog(@"serviceUUID === %@",service.UUID);
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A23"]] forService:service];
        }
    }
}

- (void)CW_Peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"%@",service.characteristics);
    //遍历服务“系统信息”服务中的特征
    for (CBCharacteristic *curCharacteristic in service.characteristics) {
        if ([curCharacteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A23"]]) {
            //获取特征中蓝牙mac地址
            NSString *value = [NSString stringWithFormat:@"%@",curCharacteristic.value];
            if (value.length > 6) {
                NSMutableString *macString = [[NSMutableString alloc] init];
                [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
                [macString appendString:@":"];
                [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
                [macString appendString:@":"];
                [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
                [macString appendString:@":"];
                [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
                [macString appendString:@":"];
                [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
                [macString appendString:@":"];
                [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
                NSLog(@"\nmac path ==== %@",macString);
                //如果mac地址与二维码上的对不上，断开蓝牙
            } else {
                NSLog(@"%@",value);
            }
        }
    }
}

#pragma mark - UITableViewDataSource Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"systemCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"systemCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier.UUIDString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    [BluetoothManager shareManager].peripheral = peripheral;
    [[BluetoothManager shareManager].centralManager connectPeripheral:peripheral options:nil];
    NSLog(@"%@",peripheral);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
