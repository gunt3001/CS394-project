//
//  MSPShareMesoActivity.m
//  Meso
//
//  Created by Napat R on 15/4/2014.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPShareMesoActivity.h"

@implementation MSPShareMesoActivity

- (NSString *)activityType{
    return @"com.kmabwp.mesoshareactivity";
}

- (NSString *)activityTitle{
    return @"Add to Meso Playlist";
}

- (UIImage *)activityImage{
#warning Needs Image
    return [UIImage imageNamed:@"radar"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    // Assuming this class won't be used out of Up Next View Sharing
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems{
    // Store activity items
#warning TBD: Incomplete Implementation
}

+ (UIActivityCategory)activityCategory{
    return UIActivityCategoryShare;
}

- (void)performActivity{
    // Add song to Meso list
#warning TBD: Incomplete Implementation
    [self activityDidFinish:YES];
}

+ (MSPShareMesoActivity *)sharedActivity{
    
    static MSPShareMesoActivity* sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[MSPShareMesoActivity alloc] init];
    }
    
    return(sharedInstance);
}
@end
