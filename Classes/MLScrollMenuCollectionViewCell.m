//
//  MLScrollMenuCollectionViewCell.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLScrollMenuCollectionViewCell.h"

@interface MLScrollMenuCollectionViewCell()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MLScrollMenuCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

#pragma mark - getter
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        UILabel* label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textAlignment = NSTextAlignmentCenter;
        
        _titleLabel = label;
    }
    return _titleLabel;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = self.contentView.bounds;
}


@end
