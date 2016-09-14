//
//  SideMenuVC.m
//  Klips
//
//  Created by iOS Developer on 14/12/15.
//  Copyright © 2015 iOS Developer. All rights reserved.
//

#import "SideMenuVC.h"

@interface SideMenuVC ()
{
    
    NSArray *menuItems;
    NSArray *menuItemImages;
    AppDelegate *appDelegate;
    UIStoryboard *storyboard;
    FBSDKLikeControl *likeButton;
}
@end

@implementation SideMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.profileImageView.layer.cornerRadius = 40;
    self.profileImageView.clipsToBounds = true;
    
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (likeButton == nil) {
        likeButton = [[FBSDKLikeControl alloc] initWithFrame:CGRectMake(190, 70, 60, 30)];
    }
    likeButton.objectID = @"https://www.facebook.com/klipshub";
//    likeButton.likeControlStyle = FBSDKLikeControlStyleBoxCount;
    likeButton.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionInline;
    [self.view addSubview:likeButton];
    
    if (appDelegate.loggedInAsGuest) {
        
        self.editButton.hidden = true;
        self.fullNameLabel.text = @"Guest";
        self.emailAdressLabel.text = @"";
        likeButton.hidden = true;
        
    }
    else if (appDelegate.loggedIn == YES || appDelegate.loggedInWithFb == YES) {
        
        self.editButton.hidden = false;
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_profile_image_url"]]];
        self.profileImageView.image = [UIImage imageWithData:imageData];
        
        self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_first_name"],[[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_last_name"]];
        
        self.emailAdressLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"logged_user_email"];
        
        likeButton.hidden = false;
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if (appDelegate.loggedIn == YES) {
        menuItems = @[@"Home",@"About Us",@"Artists",@"My Playlists",@"My Favorites",@"Change Password",@"Contact Us",@"Logout",@"Share App"];
        menuItemImages = @[@"bar_chart.png",@"About Us Male Filled-50.png",@"Gender-Filled-50.png",@"Musical Notes-48.png",@"Like-48.png",@"Lock-Filled-50.png",@"Office Phone Filled-50.png",@"Export-50.png",@"Share-48.png"];
    }else if (appDelegate.loggedInAsGuest == YES){
        menuItems = @[@"Home",@"About Us",@"Artists",@"Contact Us",@"Logout As Guest",@"Share App"];
        menuItemImages = @[@"bar_chart.png",@"About Us Male Filled-50.png",@"Gender-Filled-50.png",@"Office Phone Filled-50.png",@"Export-50.png",@"Share-48.png"];
    }else if (appDelegate.loggedInWithFb == YES){
        menuItems = @[@"Home",@"About Us",@"Artists",@"My Playlists",@"My Favorites",@"Contact Us",@"Logout",@"Share App"];
         menuItemImages = @[@"bar_chart.png",@"About Us Male Filled-50.png",@"Gender-Filled-50.png",@"Musical Notes-48.png",@"Like-48.png",@"Office Phone Filled-50.png",@"Export-50.png",@"Share-48.png"];
    }
    [self.menuTable reloadData];
}

#pragma mark - navigation

- (IBAction)editButtonPressed:(id)sender {
    
    EditProfileVC *viewController = (EditProfileVC *)[storyboard instantiateViewControllerWithIdentifier:@"editView"];
    [self.revealViewController pushFrontViewController:viewController animated:YES];
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
    
    [headerView setBackgroundColor:[UIColor blackColor]];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIImageView *imgVw = (UIImageView *)[cell viewWithTag:50];
    UILabel *lbl = (UILabel *)[cell viewWithTag:51];
    
    lbl.text = [menuItems objectAtIndex:indexPath.row];
    imgVw.image = [UIImage imageNamed:[menuItemImages objectAtIndex:indexPath.row]];
    return cell;
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIViewController *newFrontController = nil;
    
    if (appDelegate.loggedIn == YES) {
        
        if (indexPath.row == 0) {
            HomeVC *viewController = (HomeVC *)[storyboard instantiateViewControllerWithIdentifier:@"homeView"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 1)
        {
            AboutViewController *viewController = (AboutViewController *)[storyboard instantiateViewControllerWithIdentifier:@"aboutVC"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 2)
        {
            ArtistsVC *viewController = (ArtistsVC *)[storyboard instantiateViewControllerWithIdentifier:@"artistsList"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 3)
        {
            UITabBarController *viewController = (UITabBarController*)[storyboard instantiateViewControllerWithIdentifier: @"playlistTabBar"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 4)
        {
            UITabBarController *viewController = (UITabBarController*)[storyboard instantiateViewControllerWithIdentifier: @"favoritesTabBar"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 5)
        {
            ChangePasswordVC *viewController = (ChangePasswordVC *)[storyboard instantiateViewControllerWithIdentifier:@"changePasswordView"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 6)
        {
            ContactViewController *viewController = (ContactViewController *)[storyboard instantiateViewControllerWithIdentifier:@"contactVC"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 7)
        {
            appDelegate.loggedIn = NO;
            appDelegate.loggedInWithFb = NO;
            appDelegate.loggedInAsGuest = NO;
            appDelegate.showLanguageAlert = NO;
            
            //dismiss all presented view controllers if any
            UIViewController *vc = self.presentingViewController;
            while (vc.presentingViewController) {
                vc = vc.presentingViewController;
            }
            [vc dismissViewControllerAnimated:NO completion:NULL];
            
            //clearing all user defaults
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            
        }
        else if (indexPath.row == 8)
        {
            HomeVC *viewController = (HomeVC *)[storyboard instantiateViewControllerWithIdentifier:@"homeView"];
            newFrontController = viewController;
            
            NSString *informatory = @"Check out this application:";
            NSString *myWebsite = @"www.erginus.com";
            NSArray *objectsToShare = @[informatory,myWebsite];
            UIActivityViewController *activityVw = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            [self presentViewController:activityVw animated:YES completion:nil];
            
        }
        
        
    }
    
    else if (appDelegate.loggedInAsGuest) {
        
        if (indexPath.row == 0) {
            HomeVC *viewController = (HomeVC *)[storyboard instantiateViewControllerWithIdentifier:@"homeView"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 1)
        {
            AboutViewController *viewController = (AboutViewController *)[storyboard instantiateViewControllerWithIdentifier:@"aboutVC"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 2)
        {
            ArtistsVC *viewController = (ArtistsVC *)[storyboard instantiateViewControllerWithIdentifier:@"artistsList"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 3)
        {
            ContactViewController *viewController = (ContactViewController *)[storyboard instantiateViewControllerWithIdentifier:@"contactVC"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 4)
        {
            appDelegate.loggedIn = NO;
            appDelegate.loggedInWithFb = NO;
            appDelegate.loggedInAsGuest = NO;
            appDelegate.showLanguageAlert = NO;
            
            //dismiss all presented view controllers if any
            UIViewController *vc = self.presentingViewController;
            while (vc.presentingViewController) {
                vc = vc.presentingViewController;
            }
            [vc dismissViewControllerAnimated:NO completion:NULL];
            
            //clearing all user defaults
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            
        }
        else if (indexPath.row == 5)
        {
            HomeVC *viewController = (HomeVC *)[storyboard instantiateViewControllerWithIdentifier:@"homeView"];
            newFrontController = viewController;
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"You need to login to your account to share." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
    }
    else if (appDelegate.loggedInWithFb) {
        
        if (indexPath.row == 0) {
            HomeVC *viewController = (HomeVC *)[storyboard instantiateViewControllerWithIdentifier:@"homeView"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 1)
        {
            AboutViewController *viewController = (AboutViewController *)[storyboard instantiateViewControllerWithIdentifier:@"aboutVC"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 2)
        {
            ArtistsVC *viewController = (ArtistsVC *)[storyboard instantiateViewControllerWithIdentifier:@"artistsList"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 3)
        {
            UITabBarController *viewController = (UITabBarController*)[storyboard instantiateViewControllerWithIdentifier: @"playlistTabBar"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 4)
        {
            UITabBarController *viewController = (UITabBarController*)[storyboard instantiateViewControllerWithIdentifier: @"favoritesTabBar"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 5)
        {
            ContactViewController *viewController = (ContactViewController *)[storyboard instantiateViewControllerWithIdentifier:@"contactVC"];
            newFrontController = viewController;
        }
        else if (indexPath.row == 6)
        {
            [[[FBSDKLoginManager alloc] init] logOut];
            
            appDelegate.loggedIn = NO;
            appDelegate.loggedInWithFb = NO;
            appDelegate.loggedInAsGuest = NO;
            appDelegate.showLanguageAlert = NO;
            
            //dismiss all presented view controllers if any
            UIViewController *vc = self.presentingViewController;
            while (vc.presentingViewController) {
                vc = vc.presentingViewController;
            }
            [vc dismissViewControllerAnimated:NO completion:NULL];
            
            //clearing all user defaults
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        }
        else if (indexPath.row == 7)
        {
            HomeVC *viewController = (HomeVC *)[storyboard instantiateViewControllerWithIdentifier:@"homeView"];
            newFrontController = viewController;
            
            NSString *informatory = @"Check out this application:";
            NSString *myWebsite = @"www.erginus.com";
            NSArray *objectsToShare = @[informatory,myWebsite];
            UIActivityViewController *activityVw = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            [self presentViewController:activityVw animated:YES completion:nil];
            
        }
        
    }
    [self.revealViewController pushFrontViewController:newFrontController animated:YES];
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
