//
//  FullScreenVC.m
//  Klips
//
//  Created by iOS Developer on 29/02/16.
//  Copyright © 2016 iOS Developer. All rights reserved.
//

#import "FullScreenVC.h"

@interface FullScreenVC ()
{
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation FullScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.fullScroll.minimumZoomScale=1.0;
    self.fullScroll.maximumZoomScale=3.0;
    self.fullScroll.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imgUrlString]];
    self.fullImgView.image = [UIImage imageWithData:imageData];
    
    self.headerLabel.text = self.headerString;
    
}

#pragma mark - ScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.fullImgView;
}

#pragma mark - Navigation

- (IBAction)goBackToHome:(id)sender {
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
    
}
- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
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
