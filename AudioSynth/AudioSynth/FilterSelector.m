//
//  FilterSelector.m
//  Synth_Osc2
//
//  Created by Ness on 8/15/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "FilterSelector.h"
#import "roundControlSlider.h"
@implementation FilterSelector 
@synthesize dataArray,pickerView,AUFilterSelector;

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        ////--- Container View settings
        //Set the container to have round borders
        
        self.layer.cornerRadius=40.0;
        self.backgroundColor=[UIColor blackColor];


        ////--- Geometric References
        H=self.bounds.size.height;
        W=self.bounds.size.width;
        center=CGPointMake(W/2, H/2);
        // Calculate the UIVIew width.
        float screenWidth = self.bounds.size.width;
        float pickerWidth = screenWidth * 3 / 4;
        
        ////-- Array that contains the filter options
        dataArray = [[NSMutableArray alloc] init];
        [dataArray addObject:@"L o w P a s s"];
        [dataArray addObject:@"H i g h P a s s"];
        [dataArray addObject:@"L o w P a s s 2-Ord"];
        [dataArray addObject:@"H i g h P a s s 2-Ord"];

        ////--- Initialize the picker view
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, W*0.8, H*0.10)];
        [pickerView setDataSource: self];
        [pickerView setDelegate: self];
        pickerView.showsSelectionIndicator = YES;
        pickerView.backgroundColor=[UIColor clearColor];
        // Allow us to pre-select the third option in the pickerView.
        [pickerView selectRow:2 inComponent:0 animated:YES];
        ////Reduce the size a bit: Create a view to contain the picker view and apply a transform to reduce
        CGSize pickerSize = [pickerView sizeThatFits:CGSizeZero];
        UIView *pickerTransformView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, pickerSize.width, pickerSize.height)];
        pickerTransformView.transform = CGAffineTransformMakeScale(0.90f, 0.90f);
        [pickerTransformView addSubview:pickerView];
        [self addSubview:pickerTransformView];
        
        
        
        //Add Cut Frequency slider
        roundControlSlider *FreqSlider=[[roundControlSlider alloc]initWithFrame:CGRectMake(W*0.05, H*0.60, W*0.30, W*0.30)];
        [FreqSlider setParameterName:@"FC"];
        [FreqSlider setIdentity:2];
        [self addSubview:FreqSlider];
        
        //Add LFO filter control slider
        roundControlSlider *LFOFilterSlider=[[roundControlSlider alloc]initWithFrame:CGRectMake(W*0.55, H*0.60, W*0.30, W*0.30)];
        [LFOFilterSlider setParameterName:@"LFO"];
        [LFOFilterSlider setIdentity:1];
        [self addSubview:LFOFilterSlider];
        
    }
    return self;
}


-(void)drawRect:(CGRect)rect{

    
}
// Number of Columns.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our Column.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [dataArray count];
}

/* NSAttributed string doesn't respond when it's inside a picker view. 
   To create a costumized picker view you need to change the view corresponding to the selector row/Component
 */
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    ////--- Text to be displayed
    NSString *rowItem = [dataArray objectAtIndex: row];
    
    ////-- Prepare the UILabel to be inserted in the picker view
    // We must set our label's width equal to our picker's width.
    // We'll give the default height in each row.
    UILabel *lblRow = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [self.pickerView bounds].size.width, 24.0f)];
    // Colors, text and font settings

    lblRow.layer.cornerRadius=20.0;
    [lblRow setTextAlignment:NSTextAlignmentCenter];
    UIFont *font = [UIFont fontWithName:@"Digital-7" size:24.0];
    [lblRow setFont:font];
    //NSLog(@"%@",[[UIFont familyNames]objectAtIndex:0]);
    [lblRow setTextColor: [UIColor orangeColor]];
    [lblRow setText:rowItem];
    [lblRow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"rustMetal.jpeg"]]];
    //[lblRow setBackgroundColor:[UIColor blackColor]];
    
    // Return the label.
    return lblRow;
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    //printf("row: %lu\n",row);
    NSLog(@"You selected this: %@", [dataArray objectAtIndex: row]);
    [AUFilterSelector setFilterType:row];
    
}
-(void)updateFilterCutFrequency:(double)range{
    [AUFilterSelector setFilterFrequencyCut:range];
    
}
-(void)updateFilterLFOFrequency:(double)range{
    [AUFilterSelector setFilterLFOFrequency:range];
    
}

@end
