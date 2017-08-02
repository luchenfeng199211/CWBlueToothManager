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
    [self.peripherals addObject:peripheral];
    NSLog(@"peripheral ===== %@",peripheral);
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
        
        CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = peripheral.identifier.UUIDString;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
