//
//  SCRecordingUploadProgressView.m
//  SoundCloudAPI
//
//  Created by Tobias Kräntzer on 29.07.11.
//  Copyright 2011 nxtbgthng. All rights reserved.
//

#import "QuartzCore+SoundCloudAPI.h"
#import "UIImage+SoundCloudAPI.h"

#import "SCBundle.h"

#import "SCRecordingUploadProgressView.h"

#define SPACING 10.0
#define COVER_IMAGE_SIZE 40

typedef enum SCRecordingUploadProgressViewState {
    SCRecordingUploadProgressViewStateUploading = 0,
    SCRecordingUploadProgressViewStateSuccess,
    SCRecordingUploadProgressViewStateFail
} SCRecordingUploadProgressViewState;

@interface SCRecordingUploadProgressView ()
- (void)commonAwake;

@property (nonatomic, readwrite, assign) UIImageView *coverImageView;
@property (nonatomic, readwrite, assign) UILabel *titleLabel;
@property (nonatomic, readwrite, assign) UIView *line;
@property (nonatomic, readwrite, assign) UILabel *progressLabel;
@property (nonatomic, readwrite, assign) UIProgressView *progressView;
@property (nonatomic, readwrite, assign) UIButton *cancelButton;

@property (nonatomic, readwrite, assign) UIImageView *successImageView;
@property (nonatomic, readwrite, assign) UILabel *successLabel;

@property (nonatomic, readwrite, assign) SCRecordingUploadProgressViewState state;

@end

@implementation SCRecordingUploadProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonAwake];
    }
    return self;
}

- (void)commonAwake;
{
    self.backgroundColor = [UIColor whiteColor];
//    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    self.coverImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    [self addSubview:self.coverImageView];
    
    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.titleLabel.text = nil;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [self addSubview:self.titleLabel];
    
    self.line = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    self.line.backgroundColor = [UIColor colorWithWhite:0.949 alpha:1.0];
    [self addSubview:self.line];
    
    self.progressLabel = [[[UILabel alloc] init] autorelease];
    self.progressLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.progressLabel.text = SCLocalizedString(@"record_save_uploading", @"Uploading ...");
    [self addSubview:self.progressLabel];
    
    self.progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    self.progressView.progress = 0;
    [self addSubview:self.progressView];
    
    self.cancelButton = [[[UIButton alloc] init] autorelease];
    [self.cancelButton setImage:[SCBundle imageFromPNGWithName:@"cancel_dark"] forState:UIControlStateNormal];
    [self.cancelButton setImage:[SCBundle imageFromPNGWithName:@"cancelUpload"] forState:UIControlStateHighlighted];
    [self addSubview:self.cancelButton];
}


#pragma mark Accessors

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize line;
@synthesize progressLabel;
@synthesize progressView;
@synthesize cancelButton;
@synthesize successImageView;
@synthesize successLabel;
@synthesize state;

- (void)setTitle:(NSString *)aTitle;
{
    self.titleLabel.text = aTitle;
    [self setNeedsLayout];
}

- (void)setCoverImage:(UIImage *)aCoverImage;
{
    self.coverImageView.image = [aCoverImage imageByResizingTo:CGSizeMake(COVER_IMAGE_SIZE, COVER_IMAGE_SIZE) forRetinaDisplay:YES];
    [self.coverImageView sizeToFit];
    [self setNeedsLayout];
    
}

- (void)setSuccess:(BOOL)success;
{
    self.state = SCRecordingUploadProgressViewStateSuccess;
    
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    
    [self.progressLabel removeFromSuperview];
    self.progressLabel = nil;
    
    [self.cancelButton removeFromSuperview];
    self.cancelButton = nil;
    
    self.successLabel = [[[UILabel alloc] init] autorelease];
    if (success) {
        self.successImageView = [[[UIImageView alloc] initWithImage:[SCBundle imageFromPNGWithName:@"success"]] autorelease];
        self.successLabel.text = SCLocalizedString(@"record_save_upload_success", @"Yay, that worked!");
        
    } else {
        self.successImageView = [[[UIImageView alloc] initWithImage:[SCBundle imageFromPNGWithName:@"fail"]] autorelease];
        self.successLabel.text = SCLocalizedString(@"record_save_upload_fail", @"Ok, that went wrong.");
    }
    [self.successImageView sizeToFit];
    [self addSubview:self.successImageView];
    
    self.successLabel.textAlignment = UITextAlignmentCenter;
    self.successLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [self.successLabel sizeToFit];
    [self addSubview:self.successLabel];
    
    [self setNeedsLayout];
}


#pragma mark View Management

- (void)layoutSubviews;
{
    [super layoutSubviews];
 
//    NSLog(@"%s self.bounds: %@", __FUNCTION__, NSStringFromCGRect(self.bounds));
    
    if (self.coverImageView.image) {
        self.coverImageView.frame = CGRectMake(SPACING, SPACING, COVER_IMAGE_SIZE, COVER_IMAGE_SIZE);
        
        CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds) - 2 * SPACING - CGRectGetMaxX(self.coverImageView.frame),
                                    COVER_IMAGE_SIZE);
        CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                           constrainedToSize:maxSize
                                               lineBreakMode:self.titleLabel.lineBreakMode];
        
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.coverImageView.frame) + SPACING,
                                           SPACING,
                                           textSize.width,
                                           textSize.height);

    } else {
        CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds) - 2 * SPACING,
                                    COVER_IMAGE_SIZE);
        CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                           constrainedToSize:maxSize
                                               lineBreakMode:self.titleLabel.lineBreakMode];
        
        self.titleLabel.frame = CGRectMake(SPACING,
                                           SPACING,
                                           textSize.width,
                                           textSize.height);
    }
    
    
    self.line.frame = CGRectMake(SPACING,
                                 MAX(CGRectGetMaxY(self.titleLabel.frame),
                                     CGRectGetMaxY(self.coverImageView.frame)) + SPACING,
                                 CGRectGetWidth(self.bounds) - 2 * SPACING,
                                 1);
    
    switch (self.state) {
        case SCRecordingUploadProgressViewStateSuccess:
        case SCRecordingUploadProgressViewStateFail:
        {
            self.successImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.line.frame) + SPACING + CGRectGetHeight(self.successImageView.frame) / 2.0);
            
            self.successLabel.frame = CGRectMake(SPACING, CGRectGetMaxY(self.successImageView.frame) + SPACING, CGRectGetWidth(self.bounds) - 2 * SPACING, CGRectGetHeight(self.successLabel.frame));
            
            CGRect frame = self.frame;
            frame.size.height = CGRectGetMaxY(self.successLabel.frame) + SPACING;
            self.frame = frame;
            break;
        }

        default:
        {
            self.cancelButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - SPACING - 30, CGRectGetMaxY(self.line.frame) + SPACING, 30, 30);
            
            self.progressLabel.frame = CGRectMake(SPACING, CGRectGetMaxY(self.line.frame) + SPACING, 0, 0);
            [self.progressLabel sizeToFit];
            
            self.progressView.frame = CGRectMake(SPACING, CGRectGetMaxY(self.progressLabel.frame) + 6, CGRectGetWidth(self.bounds) - 30 - 3 * SPACING, 10);
            
            CGRect frame = self.frame;
            frame.size.height = CGRectGetMaxY(self.progressView.frame) + SPACING;
            self.frame = frame;
            break;
        }
            break;
    }
}

@end
