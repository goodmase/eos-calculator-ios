//
//  eoscalculatorTests.m
//  eoscalculatorTests
//
//  Created by Stephen Goodman on 10/27/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EOSCalc.h"

#define EPSILON 0.005

@interface eoscalculatorTests : XCTestCase

@end

@implementation eoscalculatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testEOSCalcWithKaiserResults
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"eos_test_cases_all" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSArray *testCases = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    XCTAssertNil(error);
    
    for (NSDictionary *testCase in testCases) {
        NSUInteger incidence = [testCase[@"incidence"] unsignedIntegerValue];
        NSUInteger abxType = [testCase[@"abx_type"] unsignedIntegerValue];
        NSUInteger gbs_status = [testCase[@"gbs_status"] unsignedIntegerValue];
        float ageWeeks = [testCase[@"age_weeks"] floatValue];
        float ageDays = [testCase[@"age_days"] floatValue];
        float age = ageWeeks + ageDays/7.0;
        float tF = [testCase[@"temp"] floatValue];
        float rom = [testCase[@"rom"] floatValue];
        
        float eosRiskActual = [testCase[@"eos_risk"] floatValue];
        float eosRiskWellAppearingActual = [testCase[@"eos_risk_well_appearing"] floatValue];
        float eosRiskEquivocalActual = [testCase[@"eos_risk_equivocal"] floatValue];
        float eosRiskClinicalIllnessActual = [testCase[@"eos_risk_clinical_illness"] floatValue];
        
        float eosRisk = [EOSCalc EOSProbabilityWith:incidence age:age temp:tF rom:rom abx:abxType gbs:gbs_status];
        float eosRiskRounded = round(eosRisk*100.0)/100.0f;
        float eosRiskWellAppearing = [EOSCalc EOSProbability:eosRiskRounded afterExam:EOSExamClassificationWellAppearing];
        float eosRiskEquivocal = [EOSCalc EOSProbability:eosRiskRounded afterExam:EOSExamClassificationEquivocal];
        float eosRiskChilicalIllness = [EOSCalc EOSProbability:eosRiskRounded afterExam:EOSExamClassificationClinicalIllness];

        //only 2 decimal places given in online example so accuracy just needed to be within 0.005
        XCTAssertEqualWithAccuracy(eosRisk, eosRiskActual, EPSILON);
        XCTAssertEqualWithAccuracy(eosRiskWellAppearing, eosRiskWellAppearingActual, EPSILON);
        XCTAssertEqualWithAccuracy(eosRiskEquivocal, eosRiskEquivocalActual, EPSILON);
        XCTAssertEqualWithAccuracy(eosRiskChilicalIllness, eosRiskClinicalIllnessActual, EPSILON);

    
    }
}


- (void)test3in10000 {
    /*
     Tests EOS test cases with incidence 3 in 10,000
     The ABXType is 3 (EOSABXTypeNoneOrLessThan2Hours) 
     The EOSGBSStatus is 0 (EOSGBSNegative)
     Both these types modify our regressive solution by 0 making it
     easier to debug problems with the forumula.
     */
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"eos_test_cases_3_in_10000" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSArray *testCases = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    for (NSDictionary *testCase in testCases) {
        float age = [testCase[@"age"] floatValue];
        float actual = [testCase[@"actual"] floatValue];
        float temp = [testCase[@"temp"] floatValue];
        float rom = [testCase[@"ROM"] floatValue];
        
        float probability = [EOSCalc EOSProbabilityWith:EOSIncidence3in10000 age:age temp:temp rom:rom abx:3 gbs:0];
        //only 2 decimal places given in online example so accuracy just needed to be within 0.005
        XCTAssertEqualWithAccuracy(probability, actual, EPSILON);
    }
}


@end
