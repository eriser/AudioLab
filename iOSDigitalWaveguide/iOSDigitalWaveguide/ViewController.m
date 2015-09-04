//
//  ViewController.m
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize appTitle;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    ////-- Set App Title
    
    
    //-- Set a dark background color
    UIColor *darkBackground=[UIColor colorWithRed:8/255.0f green:27/255.0f blue:23/255.0f alpha:1.0];
    self.view.backgroundColor=darkBackground;
    
    appTitle =[[UITextField alloc]initWithFrame:CGRectMake(0, 3, self.view.bounds.size.width, self.view.bounds.size.height*0.075)];
    appTitle.backgroundColor=[UIColor colorWithRed:14/255.0f green:57/255.0f blue:50/255.0f alpha:1.0];
    UIFont *font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
    appTitle.font=font;
    appTitle.textAlignment=NSTextAlignmentCenter;
    appTitle.textColor=[UIColor colorWithRed:54/255.0f green:179/255.0f blue:163/255.0f alpha:1.0];
    appTitle.text=@"Digital Waveguide";
    appTitle.enabled=NO;
    [self.view addSubview:appTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
