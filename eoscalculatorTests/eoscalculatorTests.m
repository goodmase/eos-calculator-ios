//
//  eoscalculatorTests.m
//  eoscalculatorTests
//
//  Created by Stephen Goodman on 10/27/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EOSCalc.h"

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

- (void)test3in10000 {
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
        
        float probability = [EOSCalc EOSProbabilityWith:EOSIncidence3in10000 age:age temp:temp rom:rom];
        float diff = fabsf(probability-actual);
        NSLog(@"diff is: %.4f", diff);
        
        //only 2 decimal places given in online example so accuracy just needed to be within 0.005
        XCTAssertEqualWithAccuracy(probability, actual, 0.005);
        
        
        
    }
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


@end
