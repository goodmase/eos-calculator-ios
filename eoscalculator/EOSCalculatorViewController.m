//
//  EOSCalculatorViewController.m
//  eoscalculator
//
//  Created by Stephen Goodman on 10/28/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import "EOSCalculatorViewController.h"
#import "EOSWebViewController.h"
#import "EOSCalc.h"
#import "EOSResultsViewController.h"
#import "UIColor+EOSColors.h"

static NSString *const kIncidence = @"incidence";
static NSString *const kAgeWeeks = @"age_weeks";
static NSString *const kAgeDays = @"age_days";
static NSString *const kTempUnits = @"temp_units";
static NSString *const kTemp = @"temp";
static NSString *const kROM = @"rom";
static NSString *const kGBSStatus = @"gbs_status";
static NSString *const kAntibioticsType = @"antibiotics_type";


@interface EOSCalculatorViewController ()

@end

@implementation EOSCalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigation];
    [self initializeForm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupNavigation{
    self.navigationItem.title = @"EOS Calculator";
    UIBarButtonItem *validateButton = [[UIBarButtonItem alloc] initWithTitle:@"Calculate" style:UIBarButtonItemStylePlain target:self action:@selector(validateForm:)];
    self.navigationItem.rightBarButtonItem = validateButton;
    

    //UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(loadReferences:)];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(loadReferences:)];
    self.navigationItem.leftBarButtonItem = infoButton;
}
-(void)initializeForm
{
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    
    XLFormRowDescriptor *row;
    section = [XLFormSectionDescriptor formSectionWithTitle:nil];
    
    
    NSArray *ic = @[[XLFormOptionsObject formOptionsObjectWithValue:@(EOSIncidence3in10000) displayText:@"0.3/1000 live births (KPNC)"],
                    [XLFormOptionsObject formOptionsObjectWithValue:@(EOSIncidence4in10000) displayText:@"0.4/1000 live births"],
                    [XLFormOptionsObject formOptionsObjectWithValue:@(EOSIncidence5in10000) displayText:@"0.5/1000 live births (CDC)"],
                    [XLFormOptionsObject formOptionsObjectWithValue:@(EOSIncidence6in10000) displayText:@"0.6/1000 live births"]];
    
    row = [self createInlinePickerRowWithTitle:@"Incidence" tag:kIncidence choices:ic required:YES];
    row.value = ic[2];
    
    [section addFormRow:row];
    
    NSArray *ageWeeksChoices = @[@(34), @(35), @(36), @(37), @(38), @(39), @(40), @(41), @(42), @(43)];
    row = [self createInlinePickerRowWithTitle:@"Gestational Age (weeks)" tag:kAgeWeeks choices:ageWeeksChoices required:YES];
    row.value = @(34);
    
    [section addFormRow:row];
    
    NSArray *ageDaysChoices = @[@(0), @(1), @(2), @(3), @(4), @(5), @(6)];
    row = [self createInlinePickerRowWithTitle:@"Gestational Age (days)" tag:kAgeDays choices:ageDaysChoices required:YES];
    row.value = @(0);
    
    [section addFormRow:row];
    
    //Highest Maternal Antepartum Temp
    row = [self createNumberRowWithTitle:@"Temperature⁰" tag:kTemp placeholder:nil required:YES];
    [section addFormRow:row];
    

    row = [self createSegmentRowWithTitle:@"Units" tag:kTempUnits choices:@[@"Fahrenheit", @"Celsius"] required:YES];
    row.value = @"Fahrenheit";
    [section addFormRow:row];
    
    row = [self createNumberRowWithTitle:@"ROM (hours)¹" tag:kROM placeholder:nil required:YES];
    [section addFormRow:row];
    
    NSArray *gbsChoices = @[[XLFormOptionsObject formOptionsObjectWithValue:@(EOSGBSNegative) displayText:@"Negative"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(EOSGBSPositive) displayText:@"Positive"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(EOSGBSUnknown) displayText:@"Unknown"]];
    
                            
    
    row = [self createSegmentRowWithTitle:@"GBS Status²" tag:kGBSStatus choices:gbsChoices required:YES];
    
    [section addFormRow:row];
    
    NSArray *antibioticChoices = @[[XLFormOptionsObject formOptionsObjectWithValue:@(EOSABXTypeBroadGreater4Hours) displayText:@"BSA => 4 hrs prior to birth"],
                                   [XLFormOptionsObject formOptionsObjectWithValue:@(EOSABXTypeBroad2to4Hours) displayText:@"BSA 2-3.9 hrs prior to birth"],
                                   [XLFormOptionsObject formOptionsObjectWithValue:@(EOSABXTypeGBSGreaterThan2Hours) displayText:@"GBS specific abx > 2 hrs prior to birth"],
                                   [XLFormOptionsObject formOptionsObjectWithValue:@(EOSABXTypeNoneOrLessThan2Hours) displayText:@"None or any abx < 2 hrs prior to birth"]];
    
    row = [self createInlinePickerRowWithTitle:@"Intrapartum ABX³" tag:kAntibioticsType choices:antibioticChoices required:YES];
    
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeButton title:@"Calculate"];
    __typeof(self) __weak weakSelf = self;
    row.action.formBlock = ^(XLFormRowDescriptor * sender){
        [weakSelf deselectFormRow:sender];
        [weakSelf validateForm:sender];
        
    };
    [row.cellConfig setObject:[UIColor EOSBlue] forKey:@"textLabel.textColor"];

    [section addFormRow:row];
    
    section.footerTitle = @"⁰ Highest maternal antepartum temperature\n¹ Duration of rupture of membranes. (In hours to the neasrest 0.1 hour.)\n² Maternal GBS status\n³ If both Broad spectrum and GBS-specific intrapartum antibiotics were given, please select the appropriate timing among the Broad spectrum categories.";
    
    
    [formDescriptor addFormSection:section];
    
    self.form = formDescriptor;
}
-(BOOL)didPassAdditionalValidation
{
    NSDictionary *formData = self.formValues;
    
    NSString *tempUnits = formData[kTempUnits];
    float temp = [formData[kTemp] floatValue];
    float rom = [formData[kROM] floatValue];
    NSString *errorMsg = @"";
    if ([tempUnits isEqualToString:@"Celsius"]) {
        if (temp < 35.5 || temp > 40) {
            errorMsg = [errorMsg stringByAppendingString:@"Please enter a temprature between 35.5°C and 40.0°C\n"];
        }
    } else {
        if (temp < 96 || temp > 104) {
            errorMsg = [errorMsg stringByAppendingString:@"Please enter a temprature between 96.0°F and 104.0°F\n"];
        }
    }
    if (rom < 0 || rom > 240) {
        errorMsg = [errorMsg stringByAppendingString:@"Please enter a ROM value between 0 and 240 hours."];
    }
    
    if ([errorMsg length] != 0) {
        [self basicAlertWithTitle:@"Input Error" andMsg:errorMsg];
        return NO;
    }
    return YES;
    
    
    
}
-(void)validateForm:(id)sender
{
    [super validateForm:sender];
    NSArray * array = [self formValidationErrors];
    if ([array count]==0 && [self didPassAdditionalValidation]) {
        //no errors
        NSDictionary *formData = self.formValues;
        
        XLFormOptionsObject *obj = formData[kIncidence];
        NSUInteger incidenceOption = [obj.valueData unsignedIntegerValue];
        obj = formData[kGBSStatus];
        NSUInteger gbsOption = [obj.valueData unsignedIntegerValue];
        obj = formData[kAntibioticsType];
        NSUInteger abxOption = [obj.valueData unsignedIntegerValue];
        
        NSString *tempUnits = formData[kTempUnits];
        
        float age = [formData[kAgeWeeks] floatValue] + [formData[kAgeDays] floatValue]/7.0;
        float temp = [formData[kTemp] floatValue];
        float rom = [formData[kROM] floatValue];
        
        if ([tempUnits isEqualToString:@"Celsius"]) {
            temp = temp*1.8 + 32;
        }
        
        float p = [EOSCalc EOSProbabilityWith:incidenceOption
                                          age:age
                                         temp:temp
                                          rom:rom
                                          abx:abxOption
                                          gbs:gbsOption];
        
        EOSResultsViewController *resultsViewController = [[EOSResultsViewController alloc] initNewForm];
        resultsViewController.eosRiskAtBirth = p;
        [self.navigationController pushViewController:resultsViewController animated:YES];
        
        
    }
}
-(void)loadReferences:(id)sender
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"eos_info" withExtension:@"html"];
    EOSWebViewController *infoViewController = [[EOSWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:infoViewController animated:YES];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
