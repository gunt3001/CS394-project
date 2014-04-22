//
//  MSPNowPlayingViewController.m
//  Meso
//
//  Created by Gun on 20/3/14.
//  Copyright (c) 2014 Napat R. All rights reserved.
//

#import "MSPNowPlayingViewController.h"
#import "MSPUpNextViewController.h"

@interface MSPNowPlayingViewController ()
@property (weak, nonatomic) IBOutlet UIView *lyricsView;
@property (weak, nonatomic) IBOutlet UITextView *lyricsTextView;

@end

@implementation MSPNowPlayingViewController{
    BOOL _isShowingLyrics;
    UITapGestureRecognizer* _tapToShowLyrics;
}

#pragma mark - Initialization

- (void)viewDidLoad
{
    // Set color scheme
    [self setColorScheme:MSPColorSchemeWhiteOnBlack];
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    
    // Setup "tap to show additional controls" gesture
    _isShowingLyrics = NO;
    _tapToShowLyrics = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLyrics:)];
    [_tapToShowLyrics setNumberOfTapsRequired:1];
    [_tapToShowLyrics setDelegate:self];
    [self.view addGestureRecognizer:_tapToShowLyrics];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // If we're detecting lyrics gesture
    if (gestureRecognizer == _tapToShowLyrics){
        CGPoint touchLocation = [touch locationInView:_lyricsView];
        return CGRectContainsPoint(_lyricsTextView.frame, touchLocation);
    }
    // Or we're detecting alt title gesture
    else return [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}

#pragma mark - View Properties

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Button Actions
- (IBAction)backButton:(id)sender {
    // Close nowplaying view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"idupnextpopover"]){
        UIPopoverController* popOverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        [(MSPUpNextViewController*)[segue destinationViewController] setParentPopover:popOverController];
    }
    
}

- (void)showLyrics:(UITapGestureRecognizer*) sender{
    // Show additional controls and lyrics
    
    if (_isShowingLyrics){
        [UIView transitionWithView:_lyricsView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_lyricsView setHidden:YES];
                        }
                        completion:NULL];
        
        [UIView transitionWithView:self.imageScroller
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.imageScroller setHidden:NO];
                        }
                        completion:NULL];

        _isShowingLyrics = NO;
    }
    else {
        [UIView transitionWithView:_lyricsView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_lyricsView setHidden:NO];
                        }
                        completion:NULL];
        
        [UIView transitionWithView:self.imageScroller
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.imageScroller setHidden:YES];
                        }
                        completion:NULL];
        
        _isShowingLyrics = YES;
    }
    
}

@end
