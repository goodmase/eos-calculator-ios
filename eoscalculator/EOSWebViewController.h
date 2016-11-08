//
//  EOSWebViewController.h
//  eoscalculator
//
//  Created by Stephen Goodman on 10/31/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EOSWebViewController : UIViewController


@property (nonatomic, strong) NSURL *url;
-(instancetype)initWithURL:(NSURL *)url;

@end
