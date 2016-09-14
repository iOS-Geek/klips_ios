//
//  RegistrationVC.m
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "RegistrationVC.h"

@interface RegistrationVC ()<VSDropdownDelegate>
{
    AppDelegate *appDelegate;
    VSDropdown *_dropdown;
    NSMutableArray *idArray;
    NSMutableArray *namesArray;
    NSString *passedCountryId;
}
@end

@implementation RegistrationVC
BOOL forCountry;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    //placeholder color
    
    [self.firstNameTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.lastNameTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.countryTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self addImage:@"arrow_down.png" withPaddingToTextField:self.countryTextField];
    
    _dropdown = [[VSDropdown alloc]initWithDelegate:self];
    [_dropdown setAdoptParentTheme:YES];
    [_dropdown setShouldSortItems:YES];
    
    forCountry = YES;
    [self dataForString:@"countries" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"now",@"current_timestamp", nil]];
}

#pragma mark - Getting data from Server

-(void)dataForString:(NSString*)serverString andParamaters:(NSMutableDictionary*)paramDict
{
    
    [RequestManager getFromServer:serverString parameters:paramDict completionHandler:^(NSDictionary *responseDict) {
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"0"] || [[responseDict valueForKey:@"code"] isEqualToString:@"-1"]) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            if (forCountry == YES) {
                idArray = [NSMutableArray array];
                namesArray = [NSMutableArray array];
                
                NSArray *dataArray=[responseDict valueForKey:@"data"];
                
                for (NSDictionary *dic in dataArray) {
                    NSString *idString = [dic valueForKey:@"country_id"];
                    NSString *nameString = [dic valueForKey:@"country_name"];
                    [idArray addObject:idString];
                    [namesArray addObject:nameString];
                }
                
            }
            else
            {
                // success
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         UIViewController *vc = self.presentingViewController;
                                         while (vc.presentingViewController) {
                                             vc = vc.presentingViewController;
                                         }
                                         [vc dismissViewControllerAnimated:YES completion:NULL];
                                         
                                         
                                     }];
                
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
            
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}


#pragma mark - Drop down Setup

- (IBAction)selectCountryButtonAction:(id)sender {
    
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
    [self showDropDownForButton:sender adContents:namesArray multipleSelection:NO];
    
}


-(void)showDropDownForButton:(UIButton *)sender adContents:(NSArray *)contents multipleSelection:(BOOL)multipleSelection
{
    
    [_dropdown setDrodownAnimation:rand()%2];
    
    [_dropdown setAllowMultipleSelection:multipleSelection];
    
    [_dropdown setupDropdownForView:sender];
    // seperator color
    [_dropdown setSeparatorColor:sender.titleLabel.textColor];
    
    if (_dropdown.allowMultipleSelection)
    {
        [_dropdown reloadDropdownWithContents:contents andSelectedItems:[[sender titleForState:UIControlStateNormal] componentsSeparatedByString:@";"]];
        
    }
    else
    {
        [_dropdown reloadDropdownWithContents:contents];
        
    }
    
}

#pragma mark - VSDropdown Delegate methods.

- (void)dropdown:(VSDropdown *)dropDown didChangeSelectionForValue:(NSString *)str atIndex:(NSUInteger)index selected:(BOOL)selected
{
    UIButton *btn = (UIButton *)dropDown.dropDownView;
    
    NSString *allSelectedItems = nil;
    if (dropDown.selectedItems.count > 1)
    {
        allSelectedItems = [dropDown.selectedItems componentsJoinedByString:@";"];
        
    }
    else
    {
        allSelectedItems = [dropDown.selectedItems firstObject];
        
    }
    if (btn.tag == 100) {
        
        self.countryTextField.text = allSelectedItems;
        passedCountryId = [idArray objectAtIndex:index];
        
    }
}

- (UIColor *)outlineColorForDropdown:(VSDropdown *)dropdown
{
    
    return [UIColor blackColor];
    
}

- (CGFloat)outlineWidthForDropdown:(VSDropdown *)dropdown
{
    return 2.0;
}

- (CGFloat)cornerRadiusForDropdown:(VSDropdown *)dropdown
{
    return 3.0;
}

- (CGFloat)offsetForDropdown:(VSDropdown *)dropdown
{
    return -2.0;
}

#pragma mark - Submit Action

- (IBAction)submitAction:(id)sender {
    
    if ([self.firstNameTextField.text isEqualToString:@""] || [self.lastNameTextField.text isEqualToString:@""] || [self.emailTextField.text isEqualToString:@""] || [self.countryTextField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please fill all the fields." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else{
        // if successful
        forCountry = NO;
        
        [appDelegate show_LoadingIndicator];
        [self dataForString:@"signup" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.firstNameTextField.text,@"user_first_name",self.lastNameTextField.text,@"user_last_name",self.emailTextField.text,@"user_email",passedCountryId,@"countries_id", nil]];
        
    }
    
    
}

#pragma mark - Navigation

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Custom method to add image to textfield

-(void)addImage:(NSString*)img withPaddingToTextField:(UITextField*)textField
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    imgView.image = [UIImage imageNamed:img];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
    [paddingView addSubview:imgView];
    [textField setRightViewMode:UITextFieldViewModeAlways];
    [textField setRightView:paddingView];
    
}

#pragma mark - handling keyboard with textfield delegate and touches

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.tag == 14) {
        [self.lastNameTextField becomeFirstResponder];
    }
    else if (textField.tag == 15)
    {
        [self.emailTextField becomeFirstResponder];
    }
    
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.firstNameTextField resignFirstResponder];
        [self.lastNameTextField resignFirstResponder];
        [self.emailTextField resignFirstResponder];
        
    }
    
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
