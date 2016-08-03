//
//  FrameCell.h
//  AnimatedGIFs
//
//  Created by Brennan Stehling on 8/2/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrameCell : UICollectionViewCell

@property (weak, nonatomic) UIImage *image;

+ (NSString *)cellIdentifier;

@end
