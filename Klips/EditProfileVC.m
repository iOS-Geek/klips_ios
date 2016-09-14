//
//  EditProfileVC.m
//  Klips
//
//  Created by iOS Developer on 15/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "EditProfileVC.h"

@interface EditProfileVC ()<VSDropdownDelegate>
{
    VSDropdown *_dropdown;
    UIImagePickerController *imagePicker;
    NSMutableArray *idArray;
    NSMutableArray *namesArray;
    NSString *passedCountryId;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
}
@end

@implementation EditProfileVC
BOOL isCountry;
BOOL isCamera;
BOOL isEdited;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideMenuButton addTarget:self.revealViewController action:@selector( revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.userImageView.layer.cornerRadius = 45;
    self.userImageView.clipsToBounds = true;
    
    [self.editFirstTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.editLastTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];[self.editMailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.editCountryTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self addImage:@"arrow_down.png" withPaddingToTextField:self.editCountryTextField];
    
    _dropdown = [[VSDropdown alloc]initWithDelegate:self];
    [_dropdown setAdoptParentTheme:YES];
    [_dropdown setShouldSortItems:YES];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    self.bgView.hidden=true;
    isCamera = NO;
    isEdited = NO;
    isCountry = YES;
    [appDelegate show_LoadingIndicator];
    [self dataForString:@"countries" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"now", @"current_timestamp", nil]];
    
}


#pragma mark - Getting data from Server

-(void)dataForString:(NSString*)serverString andParamaters:(NSMutableDictionary*)paramDict
{
    
    [RequestManager getFromServer:serverString parameters:paramDict completionHandler:^(NSDictionary *responseDict) {
        
        
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"0"])
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            NSArray *dataDict=[responseDict valueForKey:@"data"];
            
            if (isCountry == YES)
            {
                idArray = [NSMutableArray array];
                namesArray = [NSMutableArray array];
                
                for (NSDictionary *dic in dataDict) {
                    NSString *idString = [dic valueForKey:@"country_id"];
                    NSString *nameString = [dic valueForKey:@"country_name"];
                    [idArray addObject:idString];
                    [namesArray addObject:nameString];
                }
                
                if (appDelegate.loggedIn == YES || appDelegate.loggedInWithFb == YES) {
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_profile_image_url"]]];
                    self.userImageView.image = [UIImage imageWithData:imageData];
                    
                    self.editFirstTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_first_name"];
                    
                    self.editLastTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_last_name"];
                    
                    self.editMailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_email"];
                    
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"logged_countries_id"]) {
                        
                        NSUInteger index = [idArray indexOfObject:[NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_countries_id"]]];
                        passedCountryId = [idArray objectAtIndex:index];
                        self.editCountryTextField.text = [namesArray objectAtIndex:index];
                    }
                    else
                    {
                        passedCountryId = [idArray objectAtIndex:0];
                        self.editCountryTextField.text = [namesArray objectAtIndex:0];
                    }
                    isCountry = NO;
                }
                
            }
            
            else if (isEdited == YES)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_first_name"] forKey:@"logged_user_first_name"];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_last_name"] forKey:@"logged_user_last_name"];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_email"] forKey:@"logged_user_email"];
                
                [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"countries_id"] forKey:@"logged_countries_id"];
                
                isEdited = NO;
            }
            
        }
        [appDelegate hide_LoadingIndicator];
    }];
    
}

#pragma mark - Navigation

- (IBAction)goBackHome:(id)sender {
    SWRevealViewController *viewController = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"revealView"];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Changing profile image

- (IBAction)changeImageButtonAction:(id)sender {
    
    self.bgView.hidden=false;
    [self.view bringSubviewToFront:self.bgView];
    UITapGestureRecognizer *tapOnBgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapOnBgView.numberOfTapsRequired=1;
    tapOnBgView.delegate = self;
    [self.bgView addGestureRecognizer:tapOnBgView];
    
}

-(void)viewTapped:(id) sender
{
    NSLog(@"gesture received event");
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if( [touch view] != self.bgView)
    {
        NSLog(@"child");
        return YES;
    }
    else{
        NSLog(@"parent");
        self.bgView.hidden=true;
        return NO;
    }
}

- (IBAction)chooseFromGalleryButtonAction:(id)sender {
    isCamera = NO;
    self.bgView.hidden=true;
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
    else{
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Error!!"
                                    message:@"Your phone does not support this feature."
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (IBAction)takeFromCameraButtonAction:(id)sender {
    isCamera = YES;
    self.bgView.hidden=true;
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
    else{
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Error!!"
                                    message:@"Your phone does not support this feature."
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (chosenImage == nil) {
        chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    
    NSData *webData = UIImagePNGRepresentation(chosenImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:@"klips_photo.png"];
    [webData writeToFile:localFilePath atomically:YES];
    chosenImage = [UIImage imageWithContentsOfFile:localFilePath];
    
    self.userImageView.image = chosenImage;
    
    if (isCamera) {
        UIImageWriteToSavedPhotosAlbum(chosenImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [appDelegate show_LoadingIndicator];
    
    [RequestManager uploadImageData:webData toServer:@"profile_image" withImageName:localFilePath andParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"],@"user_id",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"],@"user_security_hash", nil] completionHandler:^(NSDictionary *responseDict) {
        
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[responseDict valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        
        if ([[responseDict valueForKey:@"code"] isEqualToString:@"1"])
        {
            NSArray *dataDict=[responseDict valueForKey:@"data"];
            
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_profile_image_url"] forKey:@"logged_user_profile_image_url"];
            [[NSUserDefaults standardUserDefaults]setObject:[dataDict valueForKey:@"user_security_hash"] forKey:@"logged_user_security_hash"];
            
        }
        
        [appDelegate hide_LoadingIndicator];
    }];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    // Unable to save the image
    if (error)
        NSLog(@"sorry, unable to save the image");
    else // All is well
        NSLog(@"done");
    
    isCamera = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Drop down Setup

- (IBAction)editCountryButtonAction:(id)sender {
    
    [self.editFirstTextField resignFirstResponder];
    [self.editLastTextField resignFirstResponder];
    [self.editMailTextField resignFirstResponder];
    
    if (self.view.frame.origin.y != 0) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                             
                         } completion:nil];
    }
    
    
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
    if (btn.tag == 75) {
        
        self.editCountryTextField.text = allSelectedItems;
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

#pragma mark - Submit button action

- (IBAction)submitEditedData:(id)sender {
    
    isEdited = YES;
    isCountry = NO;
    
    [appDelegate show_LoadingIndicator];
    [self dataForString:@"edit_profile" andParamaters:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_id"], @"user_id", [[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_security_hash"], @"user_security_hash", self.editFirstTextField.text, @"user_first_name", self.editLastTextField.text, @"user_last_name", self.editMailTextField.text, @"user_email", passedCountryId, @"countries_id", nil]];
    
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if (textField.tag == 71 || textField.tag == 72) {
        [UIView animateWithDuration:0.33
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self.view setFrame:CGRectMake(0,-90,self.view.frame.size.width,self.view.frame.size.height)];
                             
                         } completion:nil];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField.tag == 70) {
        [self.editLastTextField becomeFirstResponder];
    }
    else if (textField.tag == 71)
    {
        [self.editMailTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                             
                         } completion:nil];
        
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.editFirstTextField resignFirstResponder];
        [self.editLastTextField resignFirstResponder];
        [self.editMailTextField resignFirstResponder];
        
        if (self.view.frame.origin.y != 0) {
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 
                                 [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                                 
                             } completion:nil];
        }
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
