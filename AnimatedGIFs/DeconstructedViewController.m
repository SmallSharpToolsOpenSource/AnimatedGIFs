//
//  DeconstructedViewController.m
//  AnimatedGIFs
//
//  Created by Brennan Stehling on 8/2/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#import "DeconstructedViewController.h"

#import "FrameCell.h"

#define kLabelsHeight 57.0

#define kPadding 5.0
#define kColumns 3.0

#pragma mark - Class Extension
#pragma mark -

@interface DeconstructedViewController ()

@property (weak, nonatomic) IBOutlet UILabel *frameCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSCache *cache;
@property (readonly) CGSize cellSize;

@end

@implementation DeconstructedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.cache = [NSCache new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // adjust the top inset to make space for the labels
    CGRect navbarFrame = self.navigationController.navigationBar.frame;
    CGFloat headerHeight = navbarFrame.origin.y + CGRectGetHeight(navbarFrame);
    CGFloat topSpacing = headerHeight + kLabelsHeight;
    self.collectionView.contentInset = UIEdgeInsetsMake(topSpacing, 0, 0, 0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(headerHeight, 0, 0, 0);;
    [self.collectionView setContentOffset:CGPointMake(0, -1 * topSpacing) animated:NO];

    // Select the first item
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self updateSelectionForFrame:0];
}

- (NSTimeInterval)delayAtFrame:(NSUInteger)frame {
    NSNumber *delayNumber = self.animatedImage.delayTimesForIndexes[@(frame)];
    return [delayNumber doubleValue];
}

- (void)fetchImageAtFrame:(NSUInteger)frame withCompletionBlock:(void (^)(UIImage *image))completionBlock {
    if (!completionBlock) {
        return;
    }

    // Look in cache for the image
    UIImage *image = [self.cache objectForKey:@(frame)];
    if (image) {
        completionBlock(image);
    }
    else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            // try loading image at frame from animated image
            UIImage *frameImage = [weakSelf.animatedImage imageLazilyCachedAtIndex:frame];
            if (frameImage) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resizedImage = [weakSelf resizeImage:frameImage toSize:weakSelf.cellSize];
                    // save the resized image to the cache
                    [weakSelf.cache setObject:resizedImage forKey:@(frame)];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(resizedImage);
                    });
                });
            }
            else {
                dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
                dispatch_after(when, dispatch_get_main_queue(), ^{
                    [weakSelf fetchImageAtFrame:frame withCompletionBlock:completionBlock];
                });
            }
        });
    }
}

- (CGSize)cellSize {
    CGFloat originalWidth = self.animatedImage.size.width ? self.animatedImage.size.width : 100.0;
    CGFloat padding = kPadding * 2;
    CGFloat maxWidth = (CGRectGetWidth([UIApplication sharedApplication].keyWindow.frame) / kColumns) - padding;
    CGFloat delta = maxWidth / originalWidth;
    CGFloat width = (self.animatedImage.size.width * delta) + padding;
    CGFloat height = (self.animatedImage.size.height * delta) + padding;

    return CGSizeMake(width, height);
}

- (void)updateSelectionForFrame:(NSUInteger)frame {
    self.frameCountLabel.text = [NSString stringWithFormat:@"Frame %lu", (unsigned long)frame];
    self.delayLabel.text = [NSString stringWithFormat:@"Delay %.1f", [self delayAtFrame:frame]];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.animatedImage.frameCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // dequeue named cell template

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FrameCell cellIdentifier] forIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[FrameCell class]]) {
        FrameCell *frameCell = (FrameCell *)cell;
        [self fetchImageAtFrame:indexPath.item withCompletionBlock:^(UIImage *image) {
            frameCell.image = image;
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSelectionForFrame:indexPath.item];
}

#pragma mark - UICollectionViewDelegateFlowLayout
#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellSize;
}

@end
