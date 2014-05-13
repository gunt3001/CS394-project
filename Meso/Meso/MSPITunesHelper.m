//
//  MSPITunesHelper.m
//  Meso
//
//  Created by Gun on 5/13/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPITunesHelper.h"

@implementation MSPITunesHelper;

/////////////////////////////The json parsing for the apple search
+(NSDictionary*) appleSearchApi:(NSString*)artistName didGetSongName:(NSString*)songName {
    NSString * searchString = [NSString alloc];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES; //mark the start of the parsing
    
    //if something in text fields make search url
    //replace the artist field with the neccessary things and just add it to the
    if (artistName.length > 0 && songName.length > 0) {
        searchString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@+%@&limit=1",artistName,songName];
        //get rid of spaces in url
        searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        // escape other characters
        searchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    
    
    //begin json parsing
    NSURL *appleSearchApiUrl = [NSURL URLWithString:searchString];
    NSError *error;
    NSData *dataFromSite = [NSData dataWithContentsOfURL:appleSearchApiUrl options:NSDataReadingUncached error:&error];
    
    //check parsing
    if (error)
    {
        NSLog(@"error==%@==",[error localizedDescription]);
    }
    else
    {
        NSError *errorInJsonParsing;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataFromSite options:NSJSONReadingMutableContainers error:&errorInJsonParsing];
        
        if(errorInJsonParsing)
        {
            NSLog(@"error in json==%@==",[error localizedDescription]);
        }
        else
        {
            //checks if the results are empty
            NSArray *sitejson =[json objectForKey:@"results"];
            if(sitejson.count > 0)
            {
                NSDictionary *somethingcoooool = sitejson[0];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                return somethingcoooool;
            }
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    return nil;
}

+ (AVPlayer*)playPreviewSound:(NSDictionary*)data{
    ////////////////////////////////
    //this gets the preview sound
    if([data objectForKey:@"previewUrl"] != nil){
        NSURL* previewUrl = [NSURL URLWithString:[data objectForKey:@"previewUrl"]];
        
        //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        AVAsset* asset = [AVURLAsset URLAssetWithURL:previewUrl options:nil];
        AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
        AVPlayer* player = [AVPlayer playerWithPlayerItem:item];
        
        
        [player play];
        
        return player;
    }
    
    return nil;
}

+ (UIImage*)artworkImage:(NSDictionary*)data{
    //this gets the album art
    if([data objectForKey:@"artworkUrl60"] != nil){
        NSURL* albumUrl = [NSURL URLWithString:[data objectForKey:@"artworkUrl60"]];
        
        ///this is what needs to be done to change the picture
        
        NSData* imageData = [NSData dataWithContentsOfURL:albumUrl];
        return [UIImage imageWithData:imageData];
        
    }
    
    return nil;
}

+ (void)openITunesStore:(NSDictionary*)data{
    ////////////////////// this gets the itunes link
    if([data objectForKey:@"trackViewUrl"]!= nil){
        NSURL* itunesUrl = [NSURL URLWithString:[data objectForKey:@"trackViewUrl"]];
        [[UIApplication sharedApplication] openURL:itunesUrl];
    }
}

@end
