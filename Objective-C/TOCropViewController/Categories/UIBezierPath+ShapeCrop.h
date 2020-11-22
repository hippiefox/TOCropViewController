//
//  UIBezierPath+ShapeCrop.h
//  TOCropViewControllerExample
//
//  Created by BigBrother on 22/11/2020.
//  Copyright © 2020 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TOCropOptNone = 1,
    TOCropOptTriangle,
    TOCropOptInvertedTriangle,
    TOCropOptSquare,
    TOCropOptPentagon,
    TOCropOptHexagan
} TOCropOption;


@interface UIBezierPath (ShapeCrop)
+ (UIBezierPath *)pathWith:(CGRect)bounds Option:(TOCropOption)opt;
@end

NS_ASSUME_NONNULL_END
