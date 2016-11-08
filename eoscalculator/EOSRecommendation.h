//
//  EOSRecommendation.h
//  eoscalculator
//
//  Created by Stephen Goodman on 10/31/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EOSCalc.h"

@interface EOSRecommendation : NSObject

@property (nonatomic, assign) EOSExamClassification examClassification;
@property (nonatomic, assign) float probabilityAtBirth;
@property (nonatomic, assign) float probability;

-(instancetype)initWithAtBirthProbability:(float)p andExamClassification:(EOSExamClassification)e;
-(UIColor *)severityColor;
-(NSString *)vitalsRecommendation;
-(NSString *)clinicalRecommendation;



@end
