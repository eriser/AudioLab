//
//  CurveController.h
//  CurveController
//
//  Created by Ness on 7/10/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"
#define xOffset 5
#define yOffset 0
#define xStep 15
#define yStep 10
#define EG_TIME_GLOBAL 30
typedef enum  {ATTACK,DECAY,SUSTAIN, RELEASE} CurveSection;

@interface CurveController : UIView

@property IBOutlet AudioController *AUEnvelope;
-(void)sendTimePercentage:(CGFloat)time;

@end
