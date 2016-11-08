//
//  SGBaseFormViewController.m
//
//
//  Created by Stephen Goodman on 12/28/15.
//  Copyright © 2015 Stephen Goodman. All rights reserved.
//

#import "SGBaseFormViewController.h"
#import "SVProgressHUD.h"

@interface SGBaseFormViewController ()



@end

@implementation SGBaseFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupExit];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(instancetype)init{

    return [self initNewForm];
}

-(instancetype)initNewForm
{
    self = [super init];
    if (self) {
        self.formViewType = SGFormViewTypeNew;
    }
    return self;
}

-(instancetype)initEditForm
{
    self = [super init];
    if (self) {
        self.formViewType = SGFormViewTypeEdit;
    }
    return self;
}

-(instancetype)initReadOnlyForm
{
    self = [super init];
    if (self) {
        self.formViewType = SGFormViewTypeReadOnly;
    }
    return self;
}

-(void)setupExit
{
    
    if ([self isModal]) {
        UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
        [self.navigationItem setLeftBarButtonItem:exitButton];
    }


}
-(NSDictionary *)formValues
{
    NSDictionary *values = [super formValues];
    return [[self traverseGraphForNull:values] copy];
}
-(id)traverseDict:(NSDictionary *)dict{
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (NSString *key in dict) {
        id value = dict[key];
        result[key] = [self traverseGraphForNull:value];
    }
    return result;
}
-(id)traverseGraphForNull:(id)values{
    if ([values isKindOfClass:[NSArray class]]){
        return [self traverseArray:values];
    } else if ([values isKindOfClass:[NSDictionary class]]){
        return [self traverseDict:values];
    } else if ([values isKindOfClass:[NSNull class]]){
        return @"";
    } else {
        return values;
    }
}
-(id)traverseArray:(NSArray *)values
{
    
    NSMutableArray *result = [NSMutableArray new];
    for (id value in values) {
        [result addObject:[self traverseGraphForNull:value]];
    }
    return result;
    
}

#pragma mark - row validation
-(void)validateForm:(id)sender
{
    [self.view endEditing:YES]; //required otherwise the cell that is currently being edited will not be added to form values

    __block NSArray * array = [self formValidationErrors];
    __block BOOL didScroll = NO;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
        if ([self.requiredTags containsObject:validationStatus.rowDescriptor.tag]) {
            NSIndexPath *rowIndex = [self.form indexPathOfFormRow:validationStatus.rowDescriptor];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:rowIndex];
            if (!didScroll) {
                didScroll = YES;
                if (![self isRowVisibleAtIndexPath:rowIndex]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView scrollToRowAtIndexPath:rowIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    });
                    
                    [self animateCell:cell];
                
                } else {
                    [self animateCell:cell];
                }
                
            } else{
                [self animateCell:cell];
            }
            
        }
        
    }];
}
-(BOOL)isRowVisibleAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if ([index isEqual:indexPath]) {
            return YES;
        }
    }
    return NO;
    
}

-(XLFormOptionsObject *)findObjectWithValue:(NSString *)val inList:(NSArray *)optionsList{
    for (XLFormOptionsObject *obj in optionsList) {
        if ([obj.formValue isEqualToString:val] ) {
            return obj;
        }
    }
    return nil;
}


#pragma mark - row creation methods to standardize the app
-(XLFormRowDescriptor *)createBooleanRowWithTitle:(NSString *)title tag:(NSString *)tag isOn:(BOOL)isOn required:(BOOL)isReq
{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeBooleanSwitch title:title];
    if (isOn) {
        row.value = @1;
    } else{
        row.value = @0;
    }
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}


-(XLFormRowDescriptor *)createSegmentRowWithTitle:(NSString *)title tag:(NSString *)tag choices:(NSArray *)choices required:(BOOL)isReq{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:title];
    row.selectorOptions = choices;
    [row.cellConfigAtConfigure setObject:@(5.0) forKey:@"segmentedControl.layer.cornerRadius"];
    [row.cellConfigAtConfigure setObject:@(YES) forKey:@"segmentedControl.layer.masksToBounds"];
    //SegmentedControl appearance].layer setCornerRadius:5.0f
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}
-(XLFormRowDescriptor *)createInlinePickerRowWithTitle:(NSString *)title tag:(NSString *)tag choices:(NSArray *)choices required:(BOOL)isReq{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:title];
    row.selectorOptions = choices;
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
    
}
-(XLFormRowDescriptor *)createMultipleSelectorWithTitle:(NSString *)title tag:(NSString *)tag choices:(NSArray *)choices required:(BOOL)isReq
{
    XLFormRowDescriptor* row = [XLFormRowDescriptor formRowDescriptorWithTag:tag
                                                                     rowType:XLFormRowDescriptorTypeMultipleSelector
                                                                       title:title];
    row.selectorOptions = choices;
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}

-(XLFormRowDescriptor *)createNameRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq
{
    /*
    if (self.formViewType == MRIFormViewTypeReadOnly){
        return [self createInfoRowWithTitle:title tag:tag value:nil];
    }
     */
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeName title:title];
    [self configureKeyboardInputRow:row withPlaceholder:placeholder];
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    
    
    return row;
    
}
-(XLFormRowDescriptor *)createNameRowWithTitle:(NSString *)title tag:(NSString *)tag value:(NSString *)value required:(BOOL)isReq{
    XLFormRowDescriptor *row = [self createNameRowWithTitle:title tag:tag placeholder:nil required:isReq];
    if (value) row.value = value;
    
    return row;
}
-(void)configureKeyboardInputRow:(XLFormRowDescriptor *)row withPlaceholder:(NSString *)placeholder
{
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
}
-(void)applyViewTypeToRow:(XLFormRowDescriptor *)row{
    if (self.formViewType == SGFormViewTypeReadOnly) {
        row.disabled = @YES;
    }
}
-(void)applyReqToRow:(XLFormRowDescriptor *)row required:(BOOL)isReq tag:(NSString *)tag{
    if (isReq && [tag length] != 0) {
        if (!self.requiredTags) self.requiredTags = [NSMutableSet new];
        [self.requiredTags addObject:tag];
    }
    row.required = isReq;
    
}
-(XLFormRowDescriptor *)createInfoRowWithTitle:(NSString *)title tag:(NSString *)tag value:(NSString *)value
{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeInfo title:title];
    if (value) row.value = value;
    return row;
}
-(XLFormRowDescriptor *)createDateRowWithTitle:(NSString *)title tag:(NSString *)tag required:(BOOL)isReq
{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeDateInline title:title];
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}
-(XLFormRowDescriptor *)createNumberRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq
{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeNumber title:title];
    [self configureKeyboardInputRow:row withPlaceholder:placeholder];
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}
-(XLFormRowDescriptor *)createPhoneRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq
{

    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypePhone title:title];
    [self configureKeyboardInputRow:row withPlaceholder:placeholder];
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}
-(XLFormRowDescriptor *)createZipRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq
{

    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeZipCode title:title];
    //identical to phone for now. The DescriptorTypeZip is not a number pad so using the phone one.
    //TODO add validator
    [self configureKeyboardInputRow:row withPlaceholder:placeholder];
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}
-(XLFormRowDescriptor *)createNPIRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq
{

    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeAccount title:title];
    //identical to phone for now. The DescriptorTypeAccount is not a number pad so using the phone one.
    //TODO add validator
    [self configureKeyboardInputRow:row withPlaceholder:placeholder];
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}
-(XLFormRowDescriptor *)createEmailRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq{

    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeEmail title:title];
    [self configureKeyboardInputRow:row withPlaceholder:placeholder];
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    [row addValidator:[XLFormValidator emailValidator]];

    return row;
    
}

-(XLFormRowDescriptor *)createPasswordRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypePassword title:title];
    [self configureKeyboardInputRow:row withPlaceholder:placeholder];
    [self applyReqToRow:row required:isReq tag:tag];
    [row addValidator:[XLFormRegexValidator formRegexValidatorWithMsg:@"At least 6, max 32 characters" regex:@"^(?=.*\\d)(?=.*[A-Za-z]).{6,32}$"]];
    return row;
    
}

-(XLFormRowDescriptor *)createTextViewRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq
{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeTextView title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textView.placeholder"];
    }
    
    [self applyViewTypeToRow:row];
    [self applyReqToRow:row required:isReq tag:tag];
    return row;
}
-(XLFormRowDescriptor *)createTextViewRowWithTitle:(NSString *)title tag:(NSString *)tag value:(NSString *)value required:(BOOL)isReq
{
    XLFormRowDescriptor *row = [self createTextViewRowWithTitle:title tag:tag placeholder:nil required:isReq];
    if (value) row.value = value;
    return row;
}


- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

-(BOOL)isNPINumberValid:(NSString *)npi
{
    if ([npi length] != 10) return NO;
    
    NSMutableArray *temp = [self stringToArray:npi];

    int checkNumber = [[temp lastObject] intValue];
    [temp removeLastObject];
    int oddSum = 0;
    int evenSum = 0;
    BOOL isOdd = YES;
    NSArray *luhnNumbers = [@[@"8", @"0", @"8", @"4", @"0"] arrayByAddingObjectsFromArray:temp];
    NSString *oddNumStr = @"";
    for (int i = (int)([luhnNumbers count] - 1); i >= 0; i--) {
        int digit = [luhnNumbers[i] intValue];
        if (isOdd) {
            oddNumStr = [[NSString stringWithFormat:@"%i", digit*2] stringByAppendingString:oddNumStr];
        } else {
            evenSum += digit;
            NSLog(@"Even number %i", digit);
        }
        
        isOdd = !isOdd;
        
    }
    NSMutableArray *oddNumArray = [self stringToArray:oddNumStr];
    for (int i = 0; i < [oddNumArray count]; i++) {
        oddSum += [oddNumArray[i] intValue];
    }
    
    if ((oddSum + evenSum + checkNumber) % 10 == 0) return YES;
    
    
    return NO;
    
}
-(NSMutableArray *)stringToArray:(NSString *)str{
    NSMutableArray *characters = [NSMutableArray new];
    for (int i=0; i < [str length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [str characterAtIndex:i]];
        [characters addObject:ichar];
    }
    return characters;
}

-(void)exitButtonPressed:(id)sender
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    } else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        });
    }
    
}
-(void)showLoadingDataHUDWithText:(NSString *)title
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD showWithStatus:title];
    });
    
}
-(void)hideLoadingDataHUD
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        
    });
}

-(void)animateCell:(UITableViewCell *)cell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position.x";
        animation.values =  @[ @0, @20, @-20, @10, @0];
        animation.keyTimes = @[@0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.additive = YES;
        
        [cell.layer addAnimation:animation forKey:@"shake"];
    });
    
}

-(void)handleResponse:(NSURLResponse *)response withData:(NSData *)data
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    
    NSError *error;
    if (responseStatusCode == 400) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSString *tempString = @"";
        for (NSString *key in jsonDict){
            id value = jsonDict[key];
            NSString *tempString2 = [NSString stringWithFormat:@"%@: ", key];
            if ([value isKindOfClass:[NSArray class]]) {
                for (NSString *aString in (NSArray *)value) {
                    tempString2 = [tempString2 stringByAppendingString:[NSString stringWithFormat:@"%@\n", aString]];
                }
            } else if ([value isKindOfClass:[NSString class]]){
                tempString2 = [tempString2 stringByAppendingString:[NSString stringWithFormat:@"%@\n", (NSString *)value]];
            }
            tempString = [tempString stringByAppendingString:tempString2];
            
        }
        [self basicAlertWithTitle:@"Error" andMsg:tempString];
    }
    if (responseStatusCode == 500) {
        [self basicAlertWithTitle:@"Error" andMsg:@"500: Internal Server Error"];
    }
    
}
-(UINavigationController *)createModalNavWithRoot:(id)root{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    return nav;
}
-(void)basicAlertWithTitle:(NSString *)title andMsg:(NSString *)msg{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
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
