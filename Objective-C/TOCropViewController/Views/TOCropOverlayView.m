//
//  TOCropOverlayView.m
//
//  Copyright 2015-2018 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropOverlayView.h"

static const CGFloat kTOCropOverLayerCornerWidth = 20.0f;

@interface TOCropOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@property (nonatomic, strong) NSArray *outerLineViews;   //top, right, bottom, left

@property (nonatomic, strong) NSArray *topLeftLineViews; //vertical, horizontal
@property (nonatomic, strong) NSArray *bottomLeftLineViews;
@property (nonatomic, strong) NSArray *bottomRightLineViews;
@property (nonatomic, strong) NSArray *topRightLineViews;

@property (nonatomic, assign) TOCropOption shapeOption;
@property (nonatomic, strong) UIView *maskView;
@end

@implementation TOCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        [self setup];
        self.shapeOption = TOCropOptNone;
    }
    
    return self;
}

- (void)setup
{
    self.maskView = [[UIView alloc]initWithFrame:CGRectZero];
    self.maskView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.maskView];
    
    UIView *(^newLineView)(void) = ^UIView *(void){
        return [self createNewLineView];
    };

    _outerLineViews     = @[newLineView(), newLineView(), newLineView(), newLineView()];
    
    _topLeftLineViews   = @[newLineView(), newLineView()];
    _bottomLeftLineViews = @[newLineView(), newLineView()];
    _topRightLineViews  = @[newLineView(), newLineView()];
    _bottomRightLineViews = @[newLineView(), newLineView()];
    
//    self.backgroundColor = [UIColor.systemPinkColor colorWithAlphaComponent:0.3];
    self.displayHorizontalGridLines = YES;
    self.displayVerticalGridLines = YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.maskView.frame = self.bounds;
    if (_outerLineViews) {
        [self layoutLines];
        [self drawShape];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (_outerLineViews) {
        [self layoutLines];
        [self drawShape];
    }
}

- (void)layoutLines
{
    CGSize boundsSize = self.bounds.size;
    
    //border lines
    for (NSInteger i = 0; i < 4; i++) {
        UIView *lineView = self.outerLineViews[i];
        
        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = (CGRect){0,-1.0f,boundsSize.width+2.0f, 1.0f}; break; //top
            case 1: frame = (CGRect){boundsSize.width,0.0f,1.0f,boundsSize.height}; break; //right
            case 2: frame = (CGRect){-1.0f,boundsSize.height,boundsSize.width+2.0f,1.0f}; break; //bottom
            case 3: frame = (CGRect){-1.0f,0,1.0f,boundsSize.height+1.0f}; break; //left
        }
        
        lineView.frame = frame;
    }
    
    //corner liness
    NSArray *cornerLines = @[self.topLeftLineViews, self.topRightLineViews, self.bottomRightLineViews, self.bottomLeftLineViews];
    for (NSInteger i = 0; i < 4; i++) {
        NSArray *cornerLine = cornerLines[i];
        
        CGRect verticalFrame = CGRectZero, horizontalFrame = CGRectZero;
        switch (i) {
            case 0: //top left
                verticalFrame = (CGRect){-3.0f,-3.0f,3.0f,kTOCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){0,-3.0f,kTOCropOverLayerCornerWidth,3.0f};
                break;
            case 1: //top right
                verticalFrame = (CGRect){boundsSize.width,-3.0f,3.0f,kTOCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-kTOCropOverLayerCornerWidth,-3.0f,kTOCropOverLayerCornerWidth,3.0f};
                break;
            case 2: //bottom right
                verticalFrame = (CGRect){boundsSize.width,boundsSize.height-kTOCropOverLayerCornerWidth,3.0f,kTOCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-kTOCropOverLayerCornerWidth,boundsSize.height,kTOCropOverLayerCornerWidth,3.0f};
                break;
            case 3: //bottom left
                verticalFrame = (CGRect){-3.0f,boundsSize.height-kTOCropOverLayerCornerWidth,3.0f,kTOCropOverLayerCornerWidth};
                horizontalFrame = (CGRect){-3.0f,boundsSize.height,kTOCropOverLayerCornerWidth+3.0f,3.0f};
                break;
        }
        
        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }
    
    //grid lines - horizontal
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    //grid lines - vertical
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated
{
    _gridHidden = hidden;
    
    if (animated == NO) {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
    
        return;
    }
    
    [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
        for (UIView *lineView in self.horizontalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
        
        for (UIView *lineView in self.verticalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
    }];
}

#pragma mark - Property methods

- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines {
    _displayHorizontalGridLines = displayHorizontalGridLines;
    
    [self.horizontalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayHorizontalGridLines) {
        self.horizontalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.horizontalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines {
    _displayVerticalGridLines = displayVerticalGridLines;
    
    [self.verticalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayVerticalGridLines) {
        self.verticalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.verticalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [self setGridHidden:gridHidden animated:NO];
}

#pragma mark - Private methods

- (nonnull UIView *)createNewLineView {
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    newLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:newLine];
    return newLine;
}

- (void)updateCropShape:(TOCropOption)option{
    self.shapeOption = option;
    [self drawShape];
}

- (void)drawShape{
    
    CGSize boundsSize = self.bounds.size;
    BOOL isHorzitalLonger = boundsSize.width > boundsSize.height;
    CGFloat unitSize = MIN(boundsSize.width, boundsSize.height);
    
    CGFloat x = isHorzitalLonger ? (boundsSize.width - boundsSize.height) / 2 : 0;
    CGFloat y = isHorzitalLonger ? 0 : (boundsSize.height - boundsSize.width) / 2;
   
    CGPoint offSetP = CGPointMake(x, y);
    
    UIBezierPath * path;
    switch (self.shapeOption) {
        case TOCropOptTriangle:
            path = [self trianglePath:unitSize OffSet:offSetP];
            break;
        case TOCropOptPentagon:
            path = [self pentagonPath:unitSize OffSet:offSetP];
            break;
        case TOCropOptInvertedTriangle:
            path = [self invertedTrianglePath:unitSize OffSet:offSetP];
            break;
        case TOCropOptSquare:
            path = [self squarePath:unitSize OffSet:offSetP];
            break;
        case TOCropOptHexagan:
            path = [self hexagonPath:unitSize OffSet:offSetP];
            break;
        default:
            break;
    }
    
    if(self.shapeOption == TOCropOptNone){
        [self.maskView setHidden:YES];
    }else{
        [self.maskView setHidden:NO];
        CGRect selfBounds = self.bounds;
        UIBezierPath * outerPath =  [UIBezierPath bezierPathWithRect:selfBounds];
        [outerPath appendPath:path];
        
        CAShapeLayer * outerLayer = [[CAShapeLayer alloc]init];
        outerLayer.path = outerPath.CGPath;
        self.maskView.layer.mask = outerLayer;
    }
}

- (CGPoint)offsetPoint:(CGPoint)p Offset:(CGPoint)offset{
    CGPoint point = p;
    point.x += offset.x;
    point.y += offset.y;
    return  point;
}

- (UIBezierPath *)trianglePath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint firstP = CGPointMake(unitSize/2, 0);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGPoint secondP = CGPointMake(0,unitSize);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGPoint thirdP = CGPointMake(unitSize,unitSize);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
    
    path.lineWidth = 3;
    [path closePath];
    return path;
}

- (UIBezierPath *)invertedTrianglePath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint firstP = CGPointMake(0, 0);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGPoint secondP = CGPointMake(unitSize/2, unitSize);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGPoint thirdP = CGPointMake(unitSize, 0);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
   
    path.lineWidth = 3;
    [path closePath];
    return path;
}

- (UIBezierPath *)squarePath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint firstP = CGPointMake(0, unitSize/2);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGPoint secondP = CGPointMake(unitSize/2, unitSize);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGPoint thirdP = CGPointMake(unitSize, unitSize/2);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
    
    CGPoint forthP = CGPointMake(unitSize/2, 0);
    forthP = [self offsetPoint:forthP Offset:offset];
    [path addLineToPoint:forthP];
    
    path.lineWidth = 3;
    [path closePath];
    return path;
}

- (UIBezierPath *)pentagonPath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    path.lineWidth = 3;

    CGFloat halfSize = unitSize / 2;
    
    CGFloat firstY = tan(36.0/180.0*M_PI) * halfSize;
    CGPoint firstP = CGPointMake(0, firstY);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGFloat vrtSegLength = unitSize - firstY;
    CGFloat secondX = tan(18.0/180.0*M_PI) * vrtSegLength;
    CGPoint secondP = CGPointMake(secondX, unitSize);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGFloat thirdX = unitSize - secondX;
    CGPoint thirdP = CGPointMake(thirdX, unitSize);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
    
    CGPoint forthP = CGPointMake(unitSize, firstY);
    forthP = [self offsetPoint:forthP Offset:offset];
    [path addLineToPoint:forthP];
    
    CGPoint fifthP = CGPointMake(unitSize/2, 0);
    fifthP = [self offsetPoint:fifthP Offset:offset];
    [path addLineToPoint:fifthP];

    [path closePath];
    return path;
}

- (UIBezierPath *)hexagonPath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGFloat halfSize = unitSize / 2;
    
    CGPoint firstP = CGPointMake(0, halfSize);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGFloat secondX = halfSize / tan(60.0/180.0*M_PI);
    CGPoint secondP = CGPointMake(secondX, unitSize);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGPoint thirdP = CGPointMake(unitSize-secondX, unitSize);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
    
    CGPoint forthP = CGPointMake(unitSize, unitSize/2);
    forthP = [self offsetPoint:forthP Offset:offset];
    [path addLineToPoint:forthP];
    
    CGPoint fifthP = CGPointMake(unitSize-secondX, 0);
    fifthP = [self offsetPoint:fifthP Offset:offset];
    [path addLineToPoint:fifthP];
    
    CGPoint sixthP = CGPointMake(secondX, 0);
    sixthP = [self offsetPoint:sixthP Offset:offset];
    [path addLineToPoint:sixthP];
    [path closePath];
    
    return path;
}



@end
