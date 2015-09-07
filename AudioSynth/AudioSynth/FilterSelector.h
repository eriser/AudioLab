//
//  FilterSelector.h
//  Synth_Osc2
//
//  Created by Ness on 8/15/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

@interface FilterSelector : UIView <UIPickerViewDelegate, UIPickerViewDataSource> {
    CGFloat H;
    CGFloat W;
    CGPoint center;
    
}

@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *dataArray;
@property IBOutlet AudioController *AUFilterSelector;


-(void)updateFilterCutFrequency:(double)range;
-(void)updateFilterLFOFrequency:(double)range;
@end
