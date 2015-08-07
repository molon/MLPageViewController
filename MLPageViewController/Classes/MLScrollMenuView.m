//
//  MLScrollMenuView.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLScrollMenuView.h"
#import "MLScrollMenuCollectionViewCell.h"

@interface MLScrollMenuCollectionView : UICollectionView

@property (nonatomic, copy) void(^didReloadDataBlock)(MLScrollMenuCollectionView *collectionView);

@end
@implementation MLScrollMenuCollectionView

- (void)reloadData
{
    [super reloadData];
    if (self.didReloadDataBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
           self.didReloadDataBlock(self);
        });
    }
}

@end

@interface MLScrollMenuView()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) MLScrollMenuCollectionView *collectionView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, assign) NSInteger currentIndex;

//最小的cell宽度
@property (nonatomic, assign) CGFloat minCellWidth;

@end

@implementation MLScrollMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _titleFont = [UIFont boldSystemFontOfSize:14.0f];
    _titleColor = [UIColor blackColor];
    _indicatorColor = [UIColor colorWithRed:0.996 green:0.827 blue:0.216 alpha:1.000];
    
    [self addSubview:self.collectionView];
    __weak __typeof(self)weakSelf = self;
    [self.collectionView setDidReloadDataBlock:^(MLScrollMenuCollectionView *collectionView) {
        __strong __typeof(weakSelf)sSelf = weakSelf;
        
        if (collectionView.contentSize.width<collectionView.frame.size.width) {
            self.minCellWidth = collectionView.frame.size.width/[sSelf.delegate titleCount];
            //重新布局
            [collectionView reloadData];
            return;
        }
        
        //矫正indicator的位置，可能有变化
        [sSelf setCurrentIndex:sSelf.currentIndex animated:NO];
    }];
    
    [self.collectionView addSubview:self.indicatorView];
}

#pragma mark - getter
- (MLScrollMenuCollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.0f;
        layout.minimumInteritemSpacing = 0.0f;
        layout.sectionInset = UIEdgeInsetsZero;
        
        _collectionView = [[MLScrollMenuCollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, kMLScrollMenuViewIndicatorViewHeight, 0);
        
        [_collectionView registerClass:[MLScrollMenuCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MLScrollMenuCollectionViewCell class])];
    }
    return _collectionView;
}

- (UIView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [UIView new];
        _indicatorView.backgroundColor = self.indicatorColor;
    }
    return _indicatorView;
}

#pragma mark - setter
- (void)setDelegate:(id<MLScrollMenuViewDelegate>)delegate
{
    _delegate = delegate;
    [self reloadData];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    [self reloadData];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    
    [self reloadData];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    _indicatorColor = indicatorColor;
    self.indicatorView.backgroundColor = indicatorColor;
}


- (void)setCurrentIndex:(NSInteger)currentIndex
{
    NSAssert(currentIndex>=0&&currentIndex<[self.delegate titleCount], @"currentIndex设置越界");
    
    _currentIndex = currentIndex;

    //移动contentOffset
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    //找到其前一个位置的frame，让其也显示出来，否则就是当前的cell为基准
    if (currentIndex!=0) {
        contentOffset.x = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex-1 inSection:0]].frame.origin.x;
    }else{
        contentOffset.x = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]].frame.origin.x;
    }
    contentOffset.x = MIN(contentOffset.x, self.collectionView.contentSize.width-self.collectionView.frame.size.width);
    contentOffset.x = MAX(contentOffset.x, 0);
    
    [self.collectionView setContentOffset:contentOffset animated:YES];
    
    self.indicatorView.frame = [self indicatorFrameWithIndex:currentIndex];
}

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:.25f animations:^{
            self.currentIndex = currentIndex;
        }];
    }else{
        self.currentIndex = currentIndex;
    }
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}

#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSAssert(self.delegate, @"MLScrollMenuViewDelegate is required");
    return [self.delegate titleCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.delegate, @"MLScrollMenuViewDelegate is required");
    
    MLScrollMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MLScrollMenuCollectionViewCell class]) forIndexPath:indexPath];
#warning 测试
//    cell.backgroundColor = indexPath.row%2?[UIColor yellowColor]:[UIColor greenColor];
    NSString *title = [self.delegate titleForIndex:indexPath.row];
    
    cell.titleLabel.font = self.titleFont;
    cell.titleLabel.textColor = self.titleColor;
    cell.titleLabel.text = title;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSAssert(self.delegate, @"MLScrollMenuViewDelegate is required");
    
    //找到title对应的宽度
    NSString *title = [self.delegate titleForIndex:indexPath.row];
    CGSize size = [self singleSizeWithFont:self.titleFont string:title];
    size.height = collectionView.frame.size.height-(collectionView.contentInset.top+collectionView.contentInset.bottom);
    
    size.width+=kMLScrollMenuViewCollectionViewCellXPadding*2;
    
    size.width = MAX(size.width, self.minCellWidth);
    
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    [self setCurrentIndex:indexPath.row animated:YES];
}

#pragma mark - helper
- (CGSize)singleSizeWithFont:(UIFont*)font string:(NSString*)string
{
    NSAssert(font, @"singleHeightWithFont:方法必须传进font参数");
    if (string.length<=0) {
        return CGSizeZero;
    }
    
    CGSize size = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    size.height = ceilf(size.height);
    size.width = ceilf(size.width);
    
    return size;
}

- (CGRect)indicatorFrameWithIndex:(NSInteger)index
{
    //找到对应cell的位置
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    //找到title对应的宽度
    NSString *title = [self.delegate titleForIndex:index];
    CGSize size = [self singleSizeWithFont:self.titleFont string:title];
    size.width += kMLScrollMenuViewIndicatorViewXPadding*2;
    
    return CGRectMake(attributes.frame.origin.x+(attributes.frame.size.width-size.width)/2, attributes.frame.size.height, size.width, kMLScrollMenuViewIndicatorViewHeight);
}

#pragma mark - outcall
- (void)reloadData
{
    [self.collectionView reloadData];
}

@end
