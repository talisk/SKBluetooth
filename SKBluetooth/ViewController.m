//
//  ViewController.m
//  SKBluetooth
//
//  Created by 孙恺 on 15/8/8.
//  Copyright (c) 2015年 Kai Sun. All rights reserved.
//

#import "ViewController.h"
#import "SKBluetoothManager.h"

@interface ViewController ()<SKBluetoothManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *readBtn;

@property (strong, nonatomic) SKBluetoothManager *bluetoothManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bluetoothManager = [[SKBluetoothManager alloc] init];
    [self.bluetoothManager scan];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)pressSendButton:(id)sender {
    if (self.textfield.text) {
        [self.bluetoothManager writeToPeripheral:self.textfield.text];
    }
}

- (void)didGetDataForString:(NSString *)dataString {
    [self.textfield setText:[NSString stringWithFormat:@"Receive:%@",dataString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
