//
//  EOSCalc.h
//  eoscalculator
//
//  Created by Stephen Goodman on 10/27/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//Incidence of Early-Onset Sepsis

typedef enum : NSUInteger {
    EOSIncidence3in10000,
    EOSIncidence4in10000,
    EOSIncidence5in10000,
    EOSIncidence6in10000
} EOSIncidence;

typedef enum : NSUInteger {
    EOSGBSNegative,
    EOSGBSPositive,
    EOSGBSUnknown
} EOSGBSStatus;

typedef enum : NSUInteger {
    EOSABXTypeBroadGreater4Hours,
    EOSABXTypeBroad2to4Hours,
    EOSABXTypeGBSGreaterThan2Hours,
    EOSABXTypeNoneOrLessThan2Hours
} EOSABXType;

typedef enum : NSUInteger {
    EOSExamClassificationAtBirth,
    EOSExamClassificationWellAppearing,
    EOSExamClassificationEquivocal,
    EOSExamClassificationClinicalIllness
} EOSExamClassification;


@interface EOSCalc : NSObject
+(float)EOSRegressionSolutionWith:(EOSIncidence)incidence age:(float)a temp:(float)t rom:(float)r abx:(EOSABXType)abxType gbs:(EOSGBSStatus)gbs;
+(float)EOSProbabilityWith:(EOSIncidence)incidence age:(float)a temp:(float)t rom:(float)r abx:(EOSABXType)abxType gbs:(EOSGBSStatus)gbs;
+(float)interceptFromEOSIncidence:(EOSIncidence)incidence;
+(float)valueFromGBSStatus:(EOSGBSStatus)status;
+(float)valueFromABXType:(EOSABXType)t;

+(float)probabilityModificationAfterExam:(EOSExamClassification)examClassification;
+(float)EOSProbability:(float)p afterExam:(EOSExamClassification)examClassification;
+(NSString *)vitialsWithProbability:(float)p afterExam:(EOSExamClassification)examClassification;
+(NSString *)clinicalRecommendationWithProbability:(float)p afterExam:(EOSExamClassification)examClassification;
+(UIColor *)colorWithProbability:(float)p afterExam:(EOSExamClassification)examClassification;





@end
