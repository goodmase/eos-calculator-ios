//
//  EOSWebViewController.m
//  eoscalculator
//
//  Created by Stephen Goodman on 10/31/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import "EOSWebViewController.h"

@interface EOSWebViewController ()


@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation EOSWebViewController

-(instancetype)initWithURL:(NSURL *)url{
    self = [super init];
    if (self) {
        _url = url;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
