//
//  GalleryViewController.m
//  AnimatedGIFs
//
//  Created by Brennan Stehling on 7/14/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#import "GalleryViewController.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "NetworkSessionManager.h"
#import "DeconstructedViewController.h"

#define kImageURL @"https://i.giphy.com/1mlp6SCMRNEWc.gif"

@interface GalleryViewController ()

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *animatedImageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;

@property (strong, nonatomic) FLAnimatedImage *animatedImage;

@property (strong, nonatomic) NetworkSessionManager *networkSessionManager;

@end

@implementation GalleryViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animatedImageView.image = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.textField.text = kImageURL;
    [self loadAnimatedImage:self.textField.text];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DeconstructedViewController class]]) {
        DeconstructedViewController *vc = (DeconstructedViewController *)segue.destinationViewController;
        vc.animatedImage = self.animatedImage;
    }
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)loadButtonTapped:(id)sender {
    [self loadAnimatedImage:self.textField.text];
}

#pragma mark - Private
#pragma mark -

- (void)loadAnimatedImage:(NSString *)urlString {
    if (urlString.length) {
        NSURL *imageURL = [NSURL URLWithString:urlString];
        if (imageURL) {
            __weak typeof(self) weakSelf = self;
            [self.networkSessionManager fetchDataRequestWithURL:imageURL params:nil withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
                    });
                }
                else {
                    weakSelf.animatedImage = [[FLAnimatedImage alloc ] initWithAnimatedGIFData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!weakSelf.animatedImage) {
                            [weakSelf showAlertWithTitle:@"No Image" andMessage:@"Image could not be loaded"];
                        }
                        else {
                            NSAssert([NSThread isMainThread], @"Must be main thread");
                            weakSelf.animatedImageView.animatedImage = weakSelf.animatedImage;
                        }
                    });
                }
            }];
        }
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    NSAssert([NSThread isMainThread], @"Must be main thread");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okayAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NetworkSessionManager *)networkSessionManager {
    if (!_networkSessionManager) {
        _networkSessionManager = [NetworkSessionManager new];
    }

    return _networkSessionManager;
}

@end
