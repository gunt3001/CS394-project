//
//  MSPPlayerViewController.h
//  Meso
//
//  Created by Gun on 10/4/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSPColorScheme) {
    MSPColorSchemeDefault,
    MSPColorSchemeWhiteOnBlack
};

@interface MSPPlayerViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic) MSPColorScheme colorScheme;

@end
