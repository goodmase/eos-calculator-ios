//
//  SGBaseFormViewController.h
//
//
//  Created by Stephen Goodman on 12/28/15.
//  Copyright © 2015 Stephen Goodman. All rights reserved.
//

#import <XLForm/XLForm.h>

@interface SGBaseFormViewController : XLFormViewController

typedef NS_ENUM(NSInteger, SGFormViewType) {
    SGFormViewTypeNew,
    SGFormViewTypeEdit,
    SGFormViewTypeReadOnly
};

@property (nonatomic, assign) SGFormViewType formViewType;
@property (nonatomic, strong) NSMutableSet *requiredTags;

-(instancetype)initNewForm;
-(instancetype)initEditForm;
-(instancetype)initReadOnlyForm;



-(void)setupExit;
-(void)showLoadingDataHUDWithText:(NSString *)title;
-(void)exitButtonPressed:(id)sender;
-(void)animateCell:(UITableViewCell *)cell;
-(void)basicAlertWithTitle:(NSString *)title andMsg:(NSString *)msg;
-(void)hideLoadingDataHUD;
-(void)handleResponse:(NSURLResponse *)response withData:(NSData *)data;
-(UINavigationController *)createModalNavWithRoot:(id)root;

-(void)validateForm:(id)sender;

-(XLFormOptionsObject *)findObjectWithValue:(NSString *)val inList:(NSArray *)optionsList;

//rows
-(XLFormRowDescriptor *)createBooleanRowWithTitle:(NSString *)title tag:(NSString *)tag isOn:(BOOL)isOn required:(BOOL)isReq;
-(XLFormRowDescriptor *)createSegmentRowWithTitle:(NSString *)title tag:(NSString *)tag choices:(NSArray *)choices required:(BOOL)isReq;
-(XLFormRowDescriptor *)createInlinePickerRowWithTitle:(NSString *)title tag:(NSString *)tag choices:(NSArray *)choices required:(BOOL)isReq;
-(XLFormRowDescriptor *)createMultipleSelectorWithTitle:(NSString *)title tag:(NSString *)tag choices:(NSArray *)choices required:(BOOL)isReq;

-(XLFormRowDescriptor *)createInfoRowWithTitle:(NSString *)title tag:(NSString *)tag value:(NSString *)value;
-(XLFormRowDescriptor *)createNameRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;
-(XLFormRowDescriptor *)createNameRowWithTitle:(NSString *)title tag:(NSString *)tag value:(NSString *)value required:(BOOL)isReq;
-(XLFormRowDescriptor *)createDateRowWithTitle:(NSString *)title tag:(NSString *)tag required:(BOOL)isReq;
-(XLFormRowDescriptor *)createNumberRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;
-(XLFormRowDescriptor *)createPhoneRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;
-(XLFormRowDescriptor *)createZipRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;
-(XLFormRowDescriptor *)createNPIRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;
-(XLFormRowDescriptor *)createEmailRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;
-(XLFormRowDescriptor *)createPasswordRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;


-(XLFormRowDescriptor *)createTextViewRowWithTitle:(NSString *)title tag:(NSString *)tag placeholder:(NSString *)placeholder required:(BOOL)isReq;
-(XLFormRowDescriptor *)createTextViewRowWithTitle:(NSString *)title tag:(NSString *)tag value:(NSString *)value required:(BOOL)isReq;



@end
