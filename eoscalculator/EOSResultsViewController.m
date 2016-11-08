//
//  EOSResultsViewController.m
//  eoscalculator
//
//  Created by Stephen Goodman on 10/28/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import "EOSResultsViewController.h"
#import "EOSCalc.h"
#import "EOSRecommendation.h"
#import "EOSWebViewController.h"

@interface EOSResultsViewController ()

@end

@implementation EOSResultsViewController

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
-(void)setupNavigation
{
    UIBarButtonItem *classificationButton = [[UIBarButtonItem alloc] initWithTitle:@"Classification" style:UIBarButtonItemStylePlain target:self action:@selector(loadExamClassificationView:)];
    self.navigationItem.rightBarButtonItem = classificationButton;
}
-(XLFormSectionDescriptor *)createEOSExamSectionWithRecommendation:(EOSRecommendation *)rec
{
    NSString *title = @"";
    if (rec.examClassification == EOSExamClassificationWellAppearing) {
        title = @"Well Appearing";
    } else if (rec.examClassification == EOSExamClassificationEquivocal){
        title = @"Equivocal";
    } else if (rec.examClassification == EOSExamClassificationClinicalIllness){
        title = @"Clinical Illness";
    } else {
        title = @"At Birth";
    }

    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSectionWithTitle:title];
    XLFormRowDescriptor *row = [self createNameRowWithTitle:@"Risk per 1000/births" tag:nil value:[NSString stringWithFormat:@"%.2f", rec.probability] required:NO];
    [section addFormRow:row];
    if (rec.examClassification != EOSExamClassificationAtBirth) {
        [row.cellConfig setObject:[rec severityColor] forKey:@"backgroundColor"];
        
        
        row = [self createNameRowWithTitle:@"Clinical Rec." tag:nil value:rec.clinicalRecommendation required:NO];
        [row.cellConfig setObject:[rec severityColor] forKey:@"backgroundColor"];
        [section addFormRow:row];
        
        row = [self createNameRowWithTitle:@"Vitals" tag:nil value:rec.vitalsRecommendation required:NO];
        [row.cellConfig setObject:[rec severityColor] forKey:@"backgroundColor"];
        [section addFormRow:row];
    }
    
    
    
    return section;
}
-(void)initializeForm
{
    XLFormDescriptor *formDescriptor = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    
    
    
    float atBirth = self.eosRiskAtBirth;
    EOSRecommendation *recAtBirth = [[EOSRecommendation alloc] initWithAtBirthProbability:atBirth andExamClassification:EOSExamClassificationAtBirth];
    EOSRecommendation *recWellAppearing = [[EOSRecommendation alloc] initWithAtBirthProbability:atBirth andExamClassification:EOSExamClassificationWellAppearing];
    EOSRecommendation *recEquivocal = [[EOSRecommendation alloc] initWithAtBirthProbability:atBirth andExamClassification:EOSExamClassificationEquivocal];
    EOSRecommendation *recClinicalIllness = [[EOSRecommendation alloc] initWithAtBirthProbability:atBirth andExamClassification:EOSExamClassificationClinicalIllness];
    
    
    section = [self createEOSExamSectionWithRecommendation:recAtBirth];
    [formDescriptor addFormSection:section];
    
    section = [self createEOSExamSectionWithRecommendation:recWellAppearing];
    [formDescriptor addFormSection:section];
    
    section = [self createEOSExamSectionWithRecommendation:recEquivocal];
    [formDescriptor addFormSection:section];
    
    section = [self createEOSExamSectionWithRecommendation:recClinicalIllness];
    [formDescriptor addFormSection:section];

    
    self.form = formDescriptor;
}

-(void)loadExamClassificationView:(id)sender
{
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"eos_classification" withExtension:@"html"];
    EOSWebViewController *examClassVC = [[EOSWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:examClassVC animated:YES];
    
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //do not allow selection of rows.
    return nil;
    
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
