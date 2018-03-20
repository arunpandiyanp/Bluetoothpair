//
//  ScanViewController.m
//  OCSBluetoothPair
//
//  Created by OCS DEV on 19/03/18.
//  Copyright © 2018 OclockSoftware. All rights reserved.
//

#import "ScanViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import<ExternalAccessory/ExternalAccessory.h>
#import<AVFoundation/AVFoundation.h>
@interface ScanViewController ()<CBCentralManagerDelegate,UITableViewDataSource, UITableViewDelegate,AVAudioSessionDelegate>
{
    
    UITableView* mainTableView;
    NSMutableArray* cbArray;
    NSArray *services;
    AVAudioPlayer *player;
    AVPlayer *songPlayer;
}
@property(nonatomic)CBCentralManager * centralManager;
@property (nonatomic, strong) CBPeripheral *myPeripheral;
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    cbArray=[[NSMutableArray alloc]init];
    [self backMethod];
    self.view.backgroundColor=[UIColor whiteColor];
    [self configureTableView];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSString* Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
    NSLog(@"output is : %@", Identifier);
      services = @[[CBUUID UUIDWithString: Identifier]];
   
    
  

    [self becomeFirstResponder];
    
}
-(void)playAudioViaBluetoothMethod
{
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                             sizeof(sessionCategory),&sessionCategory);
    
    // Set AudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&sessionError];
    
   
    
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"default"
                                         ofType:@"aiff"]];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [player play];
    
    //Avplayer
    AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:url]];
    songPlayer = player;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[songPlayer currentItem]];
    [songPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    
    [songPlayer play];
    
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
          
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
           
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
           
        }
    } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
        
       
    }
}
- (void)backMethod
{
    
    UIButton *scanButton=[UIButton new];
    scanButton.translatesAutoresizingMaskIntoConstraints=NO;
    scanButton.backgroundColor=[UIColor whiteColor];
    [scanButton setTitle:@"BACK" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:scanButton];
    [scanButton addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(scanButton
                                                                  
                                                                  );
    
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[scanButton(130)]" //Background Scroll View
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewDictionary]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[scanButton(30)]" //Background Scroll View
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewDictionary]];
    

    
}
-(void)scanAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)configureTableView
{
    // MARK: - Step 4
    // 指定特定Service UUID, 沒有也可傳nil
    NSArray *servies = @[];
    
    // Scan時, 是否允許相同UUID裝置同時出現
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [_centralManager scanForPeripheralsWithServices:services options:options];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 250) style:UITableViewStylePlain];
    
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.backgroundColor = [UIColor whiteColor];
    mainTableView.backgroundView = nil;
    mainTableView.allowsMultipleSelectionDuringEditing = NO;
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    mainTableView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:mainTableView];
    
    
    UIButton *scanButton=[UIButton new];
    scanButton.frame=CGRectMake(60, CGRectGetMaxY(mainTableView.frame)+10, 150, 40);
    scanButton.backgroundColor=[UIColor redColor];
    [scanButton setTitle:@"Play" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:scanButton];
    [scanButton addTarget:self action:@selector(playAudioViaBluetoothMethod) forControlEvents:UIControlEventTouchUpInside];
    
    
   
    
    
}
- (void) centralManagerDidUpdateState:(CBCentralManager *)central;
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
           
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
          

            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }
}
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
{
    CBPeripheral* currentPer = peripheral;
    
    if(![cbArray containsObject:currentPer])
    {
        [cbArray addObject:currentPer];
    }
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
                            connectedAccessories];
    for (EAAccessory *obj in accessories)
    {
        NSLog(@"Found accessory named: %@", obj.name);
    }
    
    [mainTableView reloadData];
    
}
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
{
    NSLog(@"Connection successfull to peripheral: %@",peripheral);
    
}
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    
}
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    NSLog(@"Connection failed to peripheral: %@",peripheral);
    
}
- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals;
{
    // Initialize a private variable with the heart rate service UUID
   
}
- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;
{
    
}
#pragma mark UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    CBPeripheral* currentPer = [cbArray objectAtIndex:indexPath.row];
    cell.textLabel.text = (currentPer.name ? currentPer.name : @"Not available");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral* currentPer = [cbArray objectAtIndex:indexPath.row];
    [self.centralManager connectPeripheral:currentPer options:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Total count %lu",(unsigned long)cbArray.count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return cbArray.count;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
