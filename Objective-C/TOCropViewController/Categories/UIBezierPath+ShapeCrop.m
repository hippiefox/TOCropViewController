//
//  UIBezierPath+ShapeCrop.m
//  TOCropViewControllerExample
//
//  Created by BigBrother on 22/11/2020.
//  Copyright © 2020 Tim Oliver. All rights reserved.
//

#import "UIBezierPath+ShapeCrop.h"

@implementation UIBezierPath (ShapeCrop)
+ (UIBezierPath *)pathWith:(CGRect)bounds Option:(TOCropOption)opt{
    CGSize boundsSize = bounds.size;
    BOOL isHorzitalLonger = boundsSize.width > boundsSize.height;
    CGFloat unitSize = MIN(boundsSize.width, boundsSize.height);
    
    CGFloat x = isHorzitalLonger ? (boundsSize.width - boundsSize.height) / 2 : 0;
    CGFloat y = isHorzitalLonger ? 0 : (boundsSize.height - boundsSize.width) / 2;
   
    CGPoint offSetP = CGPointMake(x, y);
    
    UIBezierPath * path = nil;
    switch (opt) {
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
    
    return path;
    
}

+ (CGPoint)offsetPoint:(CGPoint)p Offset:(CGPoint)offset{
    CGPoint point = p;
    point.x += offset.x;
    point.y += offset.y;
    return  point;
}

+ (UIBezierPath *)trianglePath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGFloat h = tan(M_PI / 3) * unitSize / 2;
    CGFloat y = (unitSize - h) / 2;
    
    CGPoint firstP = CGPointMake(unitSize/2, y);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGPoint secondP = CGPointMake(0,unitSize-y);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGPoint thirdP = CGPointMake(unitSize,unitSize-y);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
    
    path.lineWidth = 3;
    [path closePath];
    return path;
}

+ (UIBezierPath *)invertedTrianglePath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGFloat h = tan(M_PI / 3) * unitSize / 2;
    CGFloat y = (unitSize - h) / 2;

    
    CGPoint firstP = CGPointMake(0, y);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGPoint secondP = CGPointMake(unitSize/2, unitSize-y);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGPoint thirdP = CGPointMake(unitSize, y);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
   
    path.lineWidth = 3;
    [path closePath];
    return path;
}

+ (UIBezierPath *)squarePath:(CGFloat)unitSize OffSet:(CGPoint)offset{
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

+ (UIBezierPath *)pentagonPath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    path.lineWidth = 3;

    CGFloat halfSize = unitSize / 2;
    CGFloat side = halfSize / cos(36.0/180*M_PI);
    CGFloat sh = cos(18.0/180.0 * M_PI) * side;
    CGFloat lh = tan(36.0/180*M_PI)*halfSize;
    CGFloat h = sh + lh;
    CGFloat y = (unitSize - h) / 2;
    
    
    CGFloat firstY = lh + y;
    CGPoint firstP = CGPointMake(0, firstY);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGFloat vrtSegLength = unitSize - firstY;
    CGFloat secondX = tan(18.0/180.0*M_PI) * vrtSegLength;
    CGPoint secondP = CGPointMake(secondX, y+h);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGFloat thirdX = unitSize - secondX;
    CGPoint thirdP = CGPointMake(thirdX, y+h);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
    
    CGPoint forthP = CGPointMake(unitSize, firstY);
    forthP = [self offsetPoint:forthP Offset:offset];
    [path addLineToPoint:forthP];
    
    CGPoint fifthP = CGPointMake(unitSize/2, y);
    fifthP = [self offsetPoint:fifthP Offset:offset];
    [path addLineToPoint:fifthP];

    [path closePath];
    return path;
}

+ (UIBezierPath *)hexagonPath:(CGFloat)unitSize OffSet:(CGPoint)offset{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGFloat halfSize = unitSize / 2;
    CGFloat h = sin(M_PI / 3) * halfSize * 2;
    CGFloat y = (unitSize - h) / 2;
    
    CGPoint firstP = CGPointMake(0, halfSize);
    firstP = [self offsetPoint:firstP Offset:offset];
    [path moveToPoint:firstP];
    
    CGFloat secondX = h/2 / tan(60.0/180.0*M_PI);
    CGPoint secondP = CGPointMake(secondX, unitSize - y);
    secondP = [self offsetPoint:secondP Offset:offset];
    [path addLineToPoint:secondP];
    
    CGPoint thirdP = CGPointMake(unitSize-secondX, unitSize - y);
    thirdP = [self offsetPoint:thirdP Offset:offset];
    [path addLineToPoint:thirdP];
    
    CGPoint forthP = CGPointMake(unitSize, unitSize/2);
    forthP = [self offsetPoint:forthP Offset:offset];
    [path addLineToPoint:forthP];
    
    CGPoint fifthP = CGPointMake(unitSize-secondX, y);
    fifthP = [self offsetPoint:fifthP Offset:offset];
    [path addLineToPoint:fifthP];
    
    CGPoint sixthP = CGPointMake(secondX, y);
    sixthP = [self offsetPoint:sixthP Offset:offset];
    [path addLineToPoint:sixthP];
    [path closePath];
    
    return path;
}

@end
