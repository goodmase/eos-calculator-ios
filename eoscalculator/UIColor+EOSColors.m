//
//  UIColor+EOSColors.m
//  eoscalculator
//
//  Created by Stephen Goodman on 10/31/16.
//  Copyright © 2016 Stephen Goodman. All rights reserved.
//

#import "UIColor+EOSColors.h"
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (EOSColors)

+(UIColor *)EOSRed{
    return UIColorFromRGB(0xf44336);
}
+(UIColor *)EOSGreen{
    return UIColorFromRGB(0x4CAF50);
}
+(UIColor *)EOSYellow{
    return UIColorFromRGB(0xFFEB3B);
}
+(UIColor *)EOSBlue{
    return UIColorFromRGB(0x1F8DD6);
}

@end
