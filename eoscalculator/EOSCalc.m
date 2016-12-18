//
//  EOSCalc.m
//  eoscalculator
//
//  Created by Stephen Goodman on 10/27/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import "EOSCalc.h"
#import "UIColor+EOSColors.h"

static float const TEMP_CO = 0.868;
static float const AGE_CO = -6.9325;
static float const AGE_2_CO = 0.0877;
static float const ROM_CO = 1.2256;

@implementation EOSCalc


//equation is (rom + 0.5)^0.2
+(float)transformedROM:(float)rom
{
    return powf((rom+0.05), 0.2);
}
//temp is in f
//age is in weeks 34 to 43
//ROM is in hours (non transformed)

+(float)valueFromGBSStatus:(EOSGBSStatus)status{
    if (status == EOSGBSNegative) {
        return 0.0;
    } else if (status == EOSGBSPositive){
        return 0.5771;
    } else if (status == EOSGBSUnknown){
        return 0.0427;
    } else {
        return -1;
    }
}
+(float)valueFromABXType:(EOSABXType)t{

    if (t == EOSABXTypeBroadGreater4Hours) {
        return -1.1861;
    } else if (t == EOSABXTypeBroad2to4Hours){
        return -1.0488;
    } else if (t == EOSABXTypeGBSGreaterThan2Hours){
        return -1.0488;
    } else if (t == EOSABXTypeNoneOrLessThan2Hours){
        return 0.0;
    } else{
        return -1;
    }
}

+(float)interceptFromEOSIncidence:(EOSIncidence)incidence
{
    if (incidence == EOSIncidence3in10000) {
        return 40.0528;
    } else if (incidence == EOSIncidence4in10000){
        return 40.3415;
    } else if (incidence == EOSIncidence5in10000){
        return 40.5656;
    } else if (incidence == EOSIncidence6in10000){
        return 40.7489;
    } else{
        return -1;
    }
}


+(float)EOSRegressionSolutionWith:(EOSIncidence)incidence age:(float)a temp:(float)t rom:(float)r abx:(EOSABXType)abxType gbs:(EOSGBSStatus)gbs{
    
    float transformedROM = [EOSCalc transformedROM:r];
    float ageSquared = powf(a, 2);
    float intercept = [EOSCalc interceptFromEOSIncidence:incidence];
    float gbsValue = [EOSCalc valueFromGBSStatus:gbs];
    float abxValue = [EOSCalc valueFromABXType:abxType];

    return intercept + TEMP_CO*t + AGE_CO*a + AGE_2_CO*ageSquared + ROM_CO*transformedROM + gbsValue + abxValue;
}
+(float)EOSProbabilityWith:(EOSIncidence)incidence age:(float)a temp:(float)t rom:(float)r abx:(EOSABXType)abxType gbs:(EOSGBSStatus)gbs{
    float regressionSol = [EOSCalc EOSRegressionSolutionWith:incidence age:a temp:t rom:r abx:abxType gbs:gbs];
    return 1000/(1+expf(-1*regressionSol));
}
+(float)probabilityModificationAfterExam:(EOSExamClassification)examClassification{
    if (examClassification == EOSExamClassificationAtBirth) {
        return 1.0;
    } else if (examClassification == EOSExamClassificationWellAppearing){
        return 0.41;
    } else if (examClassification == EOSExamClassificationEquivocal){
        return 5.0;
    } else if (examClassification == EOSExamClassificationClinicalIllness){
        return 21.2;
    } else{
        return -1;
    }
    
}
+(float)EOSProbability:(float)p afterExam:(EOSExamClassification)examClassification{
    if (EOSExamClassificationAtBirth) {
        return p;
    }
    float odds = p*0.001 / (1 - p*.001);
    float scaler = [EOSCalc probabilityModificationAfterExam:examClassification];
    return (odds*scaler*1000)/(1+odds*scaler);
    
}
+(NSString *)clinicalRecommendationWithProbability:(float)p afterExam:(EOSExamClassification)examClassification{
    if (examClassification == EOSExamClassificationAtBirth) {
        return @"No Additional Care";
    } else if (examClassification == EOSExamClassificationEquivocal || examClassification == EOSExamClassificationWellAppearing){
        if (p < 1) {
            return @"No Additional Care";
        } else if (p >= 1 && p < 3){
            return @"Blood Culture";
        } else {
            return @"Empiric Antibiotics";
        }
    } else{
        if (p < 3){
            return @"Consider Antibiotic Treatment";
        } else {
            return @"Empiric Antibiotics";
        }
    }
}
+(NSString *)vitialsWithProbability:(float)p afterExam:(EOSExamClassification)examClassification{
    if (examClassification == EOSExamClassificationAtBirth) {
        if (p < 1) {
            return @"Routine Vitials";
        }
        else {
            return @"Vitals every 4 hours for 24 hours";
        }
    } else if (examClassification == EOSExamClassificationEquivocal || examClassification == EOSExamClassificationWellAppearing){
        if (p < 1) {
            //might be an error on kaiser permanente but risk for well appearing above 0.41
            //result in vitals every 4 hours for 24 hours. Everything else requires risk above 1
            if (examClassification == EOSExamClassificationWellAppearing && p >= 0.41) {
                return @"Vitals every 4 hours for 24 hours";
            } else {
                return @"Routine Vitials";
            }
            
        } else if (p >= 1 && p < 3){
            return @"Vitals every 4 hours for 24 hours";
        } else {
            return @"Vitals per NICU";
        }
    } else{
        return @"Vitals per NICU";
    }
    
}
+(UIColor *)colorWithProbability:(float)p afterExam:(EOSExamClassification)examClassification
{
    if (examClassification == EOSExamClassificationClinicalIllness) {
        //always red if clinical illness
        return [UIColor EOSRed];
    } else {
        if (p < 1) {
            if (examClassification == EOSExamClassificationWellAppearing && p >= 0.41) {
                return [UIColor EOSYellow];
            } else {
                return [UIColor EOSGreen];
            }
        } else if (p >= 1 && p < 3){
            return [UIColor EOSYellow];
        } else{
            return [UIColor EOSRed];
        }
    }
}
@end
