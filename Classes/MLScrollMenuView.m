//
//  MLScrollMenuView.m
//  MLPageViewController
//
//  Created by molon on 15/8/7.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLScrollMenuView.h"

CGFloat const DefaultMLScrollMenuViewCollectionViewCellXPadding = 10.0f;
CGFloat const DefaultMLScrollMenuViewIndicatorViewHeight = 2.0f;
CGFloat const DefaultMLScrollMenuViewIndicatorViewXPadding = 5.0f;

@interface NSString(FitSizeForMLScrollMenu)

- (CGSize)_MLScrollMenu_singleLineSizeForFont:(UIFont*)font;

@end

@implementation NSString(FitSizeForMLScrollMenu)

- (CGSize)_MLScrollMenu_singleLineSizeForFont:(UIFont*)font
{
    NSAssert(font, @"singleHeightWithFont:方法必须传进font参数");
    if (self.length<=0) {
        return CGSizeZero;
    }
    
    NSArray* lines = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *firstLine = [lines firstObject];
    if (firstLine.length<=0) {
        return CGSizeZero;
    }
    
    CGSize size = CGSizeZero;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    size = [firstLine boundingRectWithSize:CGSizeMake(HUGE, HUGE)
                                   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    size.height = ceilf(size.height);
    size.width = ceilf(size.width);
    
    return size;
}

@end

@interface _MLScrollMenuCollectionView : UICollectionView

@property (nonatomic, copy) void(^didReloadDataBlock)(_MLScrollMenuCollectionView *collectionView);

@end
@implementation _MLScrollMenuCollectionView

- (void)reloadData {
    [super reloadData];
    if (self.didReloadDataBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
           self.didReloadDataBlock(self);
        });
    }
}

- (void)forceSuperReloadData {
    [super reloadData];
}

@end

@interface MLScrollMenuCollectionViewCell()

@property (nonatomic, copy) void(^afterLayoutBlock)(MLScrollMenuCollectionViewCell *cell);

@end

@implementation MLScrollMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.extraSignLabel];
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

- (UILabel *)extraSignLabel
{
    if (!_extraSignLabel) {
        UILabel* label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14.0f];
        
        _extraSignLabel = label;
    }
    return _extraSignLabel;
}


#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //找到标题文字大小
    CGSize titleSize = [self.titleLabel.text _MLScrollMenu_singleLineSizeForFont:self.titleLabel.font];
    CGSize extraSignSize = [self.extraSignLabel.text _MLScrollMenu_singleLineSizeForFont:self.extraSignLabel.font];
    
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;
    
    self.titleLabel.frame = CGRectMake((width-titleSize.width)/2, (height-titleSize.height)/2, titleSize.width, titleSize.height);
    self.extraSignLabel.frame = CGRectMake((self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width)+1.0f, self.titleLabel.frame.origin.y-extraSignSize.height/2, extraSignSize.width, extraSignSize.height);
    
    if (_afterLayoutBlock) {
        _afterLayoutBlock(self);
    }
}

@end

@interface MLScrollMenuView()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) _MLScrollMenuCollectionView *collectionView;
@property (nonatomic, strong) UIView *indicatorBackgroundView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation MLScrollMenuView
{
    NSMutableArray *_cellWidths;
    BOOL _changeCurrentIndexAnimated;
}

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
    self.exclusiveTouch = YES;
    _titleFont = [UIFont systemFontOfSize:14.0f];
    _extraSignFont = [UIFont systemFontOfSize:10.0f];
    _titleColor = [UIColor blackColor];
    _currentTitleColor = [UIColor redColor];
    _currentIndicatorColor = [UIColor colorWithRed:0.996 green:0.827 blue:0.216 alpha:1.000];
    _indicatorBackgroundColor = [UIColor clearColor];
    
    _indicatorViewHeight = DefaultMLScrollMenuViewIndicatorViewHeight;
    _collectionViewCellXPadding = DefaultMLScrollMenuViewCollectionViewCellXPadding;
    _currentIndicatorViewXPadding = DefaultMLScrollMenuViewIndicatorViewXPadding;
    _currentIndicatorViewOffset = UIOffsetZero;
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.indicatorBackgroundView];
    [self addSubview:self.collectionView];
    
    __weak __typeof(self)weakSelf = self;
    [self.collectionView setDidReloadDataBlock:^(_MLScrollMenuCollectionView *collectionView) {
        //矫正indicator的位置，可能有变化
        __strong __typeof(weakSelf)sSelf = weakSelf;
        [sSelf setCurrentIndex:sSelf.currentIndex animated:NO];
    }];
    
    [self.collectionView addSubview:self.indicatorView];
}

#pragma mark - getter
- (_MLScrollMenuCollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.0f;
        layout.minimumInteritemSpacing = 0.0f;
        layout.sectionInset = UIEdgeInsetsZero;
        
        _collectionView = [[_MLScrollMenuCollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerClass:[MLScrollMenuCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MLScrollMenuCollectionViewCell class])];
    }
    return _collectionView;
}

- (UIView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [UIView new];
        _indicatorView.backgroundColor = self.currentIndicatorColor;
    }
    return _indicatorView;
}

- (UIView *)indicatorBackgroundView
{
    if (!_indicatorBackgroundView) {
        _indicatorBackgroundView = [UIView new];
        _indicatorBackgroundView.backgroundColor = self.indicatorBackgroundColor;
    }
    return _indicatorBackgroundView;
}

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        _backgroundImageView = imageView;
    }
    return _backgroundImageView;
}

#pragma mark - setter
- (void)setDelegate:(id<MLScrollMenuViewDelegate>)delegate
{
    _delegate = delegate;

    [self setNeedsLayout];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;

    [self setNeedsLayout];
}

- (void)setCurrentTitleColor:(UIColor *)currentTitleColor
{
    _currentTitleColor = currentTitleColor;

    [self setNeedsLayout];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;

    [self setNeedsLayout];
}

- (void)setExtraSignFont:(UIFont *)extraSignFont
{
    _extraSignFont = extraSignFont;
    
    [self setNeedsLayout];
}

- (void)setCollectionViewCellXPadding:(CGFloat)collectionViewCellXPadding
{
    _collectionViewCellXPadding = collectionViewCellXPadding;

    [self setNeedsLayout];
}

- (void)setIndicatorViewHeight:(CGFloat)indicatorViewHeight
{
    _indicatorViewHeight = indicatorViewHeight;

    [self setNeedsLayout];
}

- (void)setCurrentIndicatorViewXPadding:(CGFloat)currentIndicatorViewXPadding
{
    _currentIndicatorViewXPadding = currentIndicatorViewXPadding;

    [self setNeedsLayout];
}

- (void)setCurrentIndicatorColor:(UIColor *)indicatorColor
{
    _currentIndicatorColor = indicatorColor;
    self.indicatorView.backgroundColor = indicatorColor;
}

- (void)setIndicatorBackgroundColor:(UIColor *)indicatorBackgroundColor
{
    _indicatorBackgroundColor = indicatorBackgroundColor;
    self.indicatorBackgroundView.backgroundColor = indicatorBackgroundColor;
}

- (void)setCurrentIndicatorViewOffset:(UIOffset)currentIndicatorViewOffset
{
    _currentIndicatorViewOffset = currentIndicatorViewOffset;
    [self setNeedsLayout];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    NSAssert(currentIndex>=0&&currentIndex<[self.delegate titleCount], @"currentIndex设置越界");
    
    if (_currentIndex != currentIndex&&self.delegate&&[self.delegate respondsToSelector:@selector(shouldChangeCurrentIndexFrom:to:scrollMenuView:)]) {
        if (![self.delegate shouldChangeCurrentIndexFrom:_currentIndex to:currentIndex scrollMenuView:self]) {
            return;
        }
    }
    
    NSInteger oldIndex = _currentIndex;
    _currentIndex = currentIndex;
    
    if (oldIndex!=_currentIndex&&self.delegate&&[self.delegate respondsToSelector:@selector(didChangeCurrentIndexFrom:to:animated:scrollMenuView:)]) {
        [self.delegate didChangeCurrentIndexFrom:oldIndex to:currentIndex animated:_changeCurrentIndexAnimated scrollMenuView:self];
    }
    
    [self updateTitleColorWithCurrentIndex:currentIndex];
    
    if (_changeCurrentIndexAnimated) {
        self.collectionView.userInteractionEnabled = NO;
        _animating = YES;
        [UIView animateWithDuration:.25f animations:^{
            [self.collectionView setContentOffset:[self contentOffsetWidthIndex:currentIndex] animated:YES];
            self.indicatorView.frame = [self indicatorFrameWithIndex:currentIndex];
        } completion:^(BOOL finished) {
            _animating = NO;
            self.collectionView.userInteractionEnabled = YES;
        }];
    }else{
        [self.collectionView setContentOffset:[self contentOffsetWidthIndex:currentIndex] animated:NO];
        self.indicatorView.frame = [self indicatorFrameWithIndex:currentIndex];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated
{
    //不直接用动画block包括进来是怕didChangeCurrentIndex里有对其他view进行调整的同时也被动画了
    _changeCurrentIndexAnimated = animated;
    self.currentIndex = currentIndex;
    _changeCurrentIndexAnimated = NO;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundImageView.frame = self.bounds;
    self.indicatorBackgroundView.frame = CGRectMake(0, self.frame.size.height-_indicatorViewHeight+self.currentIndicatorViewOffset.vertical, self.frame.size.width, _indicatorViewHeight);
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.frame = self.bounds;
    [self reloadData];
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
    
    NSString *title = [self.delegate titleForIndex:indexPath.row];
    
    cell.titleLabel.font = self.titleFont;
    cell.titleLabel.textColor = self.currentIndex==indexPath.row?self.currentTitleColor:self.titleColor;
    cell.titleLabel.text = title;
    
    if ([self.delegate respondsToSelector:@selector(extraSignForIndex:)]) {
        NSString *extraSign = [self.delegate extraSignForIndex:indexPath.row];
        cell.extraSignLabel.font = self.extraSignFont;
        cell.extraSignLabel.textColor = cell.titleLabel.textColor;
        cell.extraSignLabel.text = extraSign;
    }
    
    __weak __typeof__(self)weakSelf = self;
    [cell setAfterLayoutBlock:^(MLScrollMenuCollectionViewCell *c) {
        __strong __typeof__(self)self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(afterLayoutWithCell:index:)]) {
            [self.delegate afterLayoutWithCell:c index:indexPath.row];
        }
    }];
    
    [cell setNeedsLayout];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSAssert(self.delegate, @"MLScrollMenuViewDelegate is required");
    
    return CGSizeMake(
                             [_cellWidths[indexPath.row] doubleValue],
                             fmax(0.0f, collectionView.frame.size.height-(collectionView.contentInset.top+collectionView.contentInset.bottom))
                             );
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    [self setCurrentIndex:indexPath.row animated:YES];
}

#pragma mark - helper
- (CGRect)indicatorFrameWithIndex:(NSInteger)index
{
    //找到对应cell的位置
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    //找到title对应的宽度
    NSString *title = [self.delegate titleForIndex:index];
    CGSize size = [title _MLScrollMenu_singleLineSizeForFont:self.titleFont];
    size.width += _currentIndicatorViewXPadding*2;
    size.width = fmin(size.width, attributes.frame.size.width);
    
    CGRect result = CGRectMake(attributes.frame.origin.x+(attributes.frame.size.width-size.width)/2, attributes.frame.size.height-_indicatorViewHeight, size.width, _indicatorViewHeight);
    
    result = CGRectOffset(result, _currentIndicatorViewOffset.horizontal, _currentIndicatorViewOffset.vertical);
    return result;
}

- (CGPoint)contentOffsetWidthIndex:(NSInteger)index
{
    //移动contentOffset
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    //找到其前一个位置的frame，让其也显示出来，否则就是当前的cell为基准
    if (index!=0) {
        contentOffset.x = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0]].frame.origin.x;
    }else{
        contentOffset.x = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]].frame.origin.x;
    }
    contentOffset.x = fmin(contentOffset.x, self.collectionView.contentSize.width-self.collectionView.frame.size.width);
    contentOffset.x = fmax(contentOffset.x, 0);
    return contentOffset;
}

- (void)updateTitleColorWithCurrentIndex:(NSInteger)currentIndex
{
    for (MLScrollMenuCollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        cell.titleLabel.textColor = (indexPath.row==currentIndex)?self.currentTitleColor:self.titleColor;
        cell.extraSignLabel.textColor = cell.titleLabel.textColor;
    }
}

#pragma mark - outcall
- (void)reloadDisplay {
    [self.collectionView forceSuperReloadData];
}

- (void)reloadData
{
    NSInteger count = [self.delegate titleCount];
    _cellWidths = [NSMutableArray arrayWithCapacity:count];
    
    CGFloat totalWidth = 0.0f;
    for (NSInteger i=0; i<count; i++) {
        NSString *title = [self.delegate titleForIndex:i];
        CGSize size = [title _MLScrollMenu_singleLineSizeForFont:self.titleFont];
        size.width += _collectionViewCellXPadding*2;
        [_cellWidths addObject:@(size.width)];
        totalWidth += size.width;
    }
    
    if (totalWidth<self.collectionView.frame.size.width) {
        CGFloat widthOffset = (self.collectionView.frame.size.width-totalWidth)/count;
        //剩余空间均衡一下
        for (NSInteger i=0; i<count; i++) {
            _cellWidths[i] = @(widthOffset+[_cellWidths[i] doubleValue]);
        }
    }
    
    [self.collectionView reloadData];
}

- (void)displayFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex ratio:(double)ratio
{
    if (fromIndex<0||fromIndex>[self.delegate titleCount]-1) {
        return;
    }
    if (toIndex<0||toIndex>[self.delegate titleCount]-1) {
        return;
    }

    //当前的contentOffset
    CGPoint originalContentOffset = [self contentOffsetWidthIndex:fromIndex];
    
    //如果当前的
    
    //当前的indicator frame
    CGRect originalIndicatorFrame = [self indicatorFrameWithIndex:fromIndex];
    
    //移动contentOffset
    CGPoint contentOffset = [self contentOffsetWidthIndex:toIndex];
    
    //取个中间位置的即可
    contentOffset.x = originalContentOffset.x+(contentOffset.x-originalContentOffset.x)*ratio;
    
    
    CGRect indicatorFrame = [self indicatorFrameWithIndex:toIndex];
    indicatorFrame.origin.x = originalIndicatorFrame.origin.x+(indicatorFrame.origin.x-originalIndicatorFrame.origin.x)*ratio;
    indicatorFrame.size.width = originalIndicatorFrame.size.width+(indicatorFrame.size.width-originalIndicatorFrame.size.width)*ratio;
    
    self.indicatorView.frame = indicatorFrame;
    
    [self.collectionView setContentOffset:contentOffset animated:NO];
    
    NSInteger highlightedIndex = ratio<.5f?fromIndex:toIndex;
    [self updateTitleColorWithCurrentIndex:highlightedIndex];
}

@end
