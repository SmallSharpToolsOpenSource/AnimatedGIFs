//
//  FrameCell.m
//  AnimatedGIFs
//
//  Created by Brennan Stehling on 8/2/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#import "FrameCell.h"

#pragma mark - Class Extension
#pragma mark -

@interface FrameCell ()

@property (weak, nonatomic) IBOutlet UIView *highlightView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation FrameCell

+ (NSString *)cellIdentifier {
    return @"FrameCell";
}

- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    self.highlightView.backgroundColor = selected ? [UIColor lightGrayColor] : [UIColor clearColor];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)prepareForReuse {
    self.selected = NO;
    self.imageView.image = nil;
}

@end
