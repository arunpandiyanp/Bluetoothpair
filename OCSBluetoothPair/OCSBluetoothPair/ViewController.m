//
//  ViewController.m
//  OCSBluetoothPair
//
//  Created by OCS DEV on 19/03/18.
//  Copyright © 2018 OclockSoftware. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import<AVFoundation/AVFoundation.h>

@interface ViewController ()<CBCentralManagerDelegate>
{
    
    UIButton *scanButton,*playAudio;
    NSArray *services;
    AVAudioPlayer *player;
    BOOL isClickedSoundAlert;

}
@property (strong, nonatomic) UIPopoverController *airplayPopoverController;
@property(nonatomic)CBCentralManager * centralManager;

@end
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  self.view.backgroundColor=  [UIColor colorWithRed:245.0f/255 green:247.0f/255 blue:249.0f/255 alpha:1.0 ];
    [self configureTableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    isClickedSoundAlert=YES;
    // MARK: - Step 4
    // 指定特定Service UUID, 沒有也可傳nil
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSString* Identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
    NSLog(@"output is : %@", Identifier);
    services = @[[CBUUID UUIDWithString: Identifier]];
    
    NSArray *servies = @[];
    
    // Scan時, 是否允許相同UUID裝置同時出現
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [_centralManager scanForPeripheralsWithServices:services options:options];
}
- (void)configureTableView
{
   
   scanButton=[UIButton new];
    scanButton.translatesAutoresizingMaskIntoConstraints=NO;
    scanButton.backgroundColor=[UIColor whiteColor];
    [scanButton setTitle:@"Bluetooth Devices" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:scanButton];
    [scanButton addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
   
    scanButton.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f] CGColor];
    scanButton.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
   scanButton.layer.shadowOpacity = 0.5f;
    scanButton.layer.shadowRadius = 0.0f;
   scanButton.layer.masksToBounds = NO;
    scanButton.layer.cornerRadius = 4.0f;
    
    
    playAudio=[UIButton new];
    playAudio.translatesAutoresizingMaskIntoConstraints=NO;
    playAudio.backgroundColor=[UIColor whiteColor];
    [playAudio setTitle:@"Sound Alarm" forState:UIControlStateNormal];
  [playAudio setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:playAudio];
    
    playAudio.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f] CGColor];
    playAudio.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    playAudio.layer.shadowOpacity = 0.5f;
    playAudio.layer.shadowRadius = 0.0f;
    playAudio.layer.masksToBounds = NO;
    playAudio.layer.cornerRadius = 4.0f;
    
    
    
    
    [playAudio addTarget:self action:@selector(playAudioViaBluetoothMethod) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(scanButton,
                                                                  playAudio
                                                                  
                                                                  );
    
  
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[scanButton(250)]" //Background Scroll View
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewDictionary]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[playAudio(250)]" //Background Scroll View
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewDictionary]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[scanButton(100)]" //Background Scroll View
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewDictionary]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[playAudio(100)]" //Background Scroll View
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewDictionary]];
    
    [NSLayoutConstraint constraintWithItem:scanButton
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:scanButton
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0f
                                  constant:0].active = YES;
    
    
    
    [NSLayoutConstraint constraintWithItem:playAudio
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0f
                                  constant:0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:playAudio
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0f
                                  constant:+180].active = YES;

}
-(void)scanAction
{
    if(self.airplayPopoverController == nil)
    {
        //create the MPAudioVideoRoutingPopoverController class at runtime
        id TheClass = NSClassFromString(@"MPAudioVideoRoutingPopoverController");
        
        // a temp object of MPAudioVideoRoutingPopoverController
        id testObject = [[TheClass alloc] initWithContentViewController: self];
        // the selector to call for creating the right popover controller
        SEL initMethod = @selector(initWithType:includeMirroring:);
        
        if([testObject respondsToSelector: initMethod])
        {
            //use NSInvocation to create the object we need.
            NSMethodSignature* signature = [TheClass instanceMethodSignatureForSelector: initMethod];
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
            [invocation setTarget: testObject];
            [invocation setSelector:initMethod];
            
            //prepare arguments
            NSInteger type = 0;
            BOOL showMirroring = YES;//YES
            
            //the final popover controller
            static id returnObject = nil;
            
            // index 0 and 1 are reserved for system use: self; _cmd;
            // call 'initWithType:0 includeMirroring:YES' in runtime
            [invocation setArgument:&type atIndex:2];
            [invocation setArgument:&showMirroring atIndex:3];
            [invocation retainArguments];
            [invocation invoke];
            [invocation getReturnValue: &returnObject];
            
            //save the popover controller as a property
            self.airplayPopoverController = returnObject;
            
        }
    }
    //Dispaly the popover controller
    [self.airplayPopoverController presentPopoverFromRect:scanButton.frame
                                                   inView:self.view
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
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
-(void)playAudioViaBluetoothMethod
{
  if(isClickedSoundAlert==YES)
  {
    // Set AudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&sessionError];
    
     [playAudio setTitle:@"Stop Alarm" forState:UIControlStateNormal];
    
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"zapsplat_emergency_alarm_siren"
                                         ofType:@"mp3"]];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [player play];
      isClickedSoundAlert=NO;
  }
    else
    {
        isClickedSoundAlert=YES;
        [player stop];
        [playAudio setTitle:@"Sound Alarm" forState:UIControlStateNormal];


    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
