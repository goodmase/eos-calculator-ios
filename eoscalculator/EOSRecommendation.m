//
//  EOSRecommendation.m
//  eoscalculator
//
//  Created by Stephen Goodman on 10/31/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import "EOSRecommendation.h"


@implementation EOSRecommendation

-(instancetype)initWithAtBirthProbability:(float)p andExamClassification:(EOSExamClassification)e;
{
    self = [super init];
    if (self) {
        _examClassification = e;
        _probabilityAtBirth = p;
        _probability = [EOSCalc EOSProbability:p afterExam:e];
    }
    return self;
}

-(UIColor *)severityColor{
    return [EOSCalc colorWithProbability:self.probability afterExam:self.examClassification];
}
-(NSString *)vitalsRecommendation{
    return [EOSCalc vitialsWithProbability:self.probability afterExam:self.examClassification];
}
-(NSString *)clinicalRecommendation{
    return [EOSCalc clinicalRecommendationWithProbability:self.probability afterExam:self.examClassification];
}


@end
