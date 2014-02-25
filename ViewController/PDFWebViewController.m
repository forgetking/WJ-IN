//
//  pdfWebView.m
//  WJ-IN
//
//  Created by Matthias Lukjantschuk on 26.12.13.
//  Copyright (c) 2013 GUNDF. All rights reserved.
//

#import "PDFWebViewController.h"

@interface PDFWebViewController () <UIWebViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *pdfWebView;
@end

@implementation PDFWebViewController

- (IBAction)goBack:(id)sender {
    [self.pdfWebView goBack];
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
//    NSString *urlAddress = [[NSString alloc] init];
//    
//    urlAddress = [[NSBundle mainBundle] pathForResource:@"wjJahrbuch2014appV72m"
//                                                 ofType:@"pdf"];
//    
//    NSURL *url = [NSURL fileURLWithPath:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    //[[UIApplication sharedApplication]canOpenURL:url];
//    [[UIApplication sharedApplication]openURL:url];
//    [_pdfWebView setDelegate:self];
//    [_pdfWebView loadRequest:requestObj];
//    self.automaticallyAdjustsScrollViewInsets = YES;
//    [super viewDidLoad];
//    typedef NSUInteger UIDataDetectorTypes;
	// Do any additional setup after loading the view.
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClickMenu:(id)sender {
    
    [self.frostedViewController presentMenuViewController];
    
}

@end
