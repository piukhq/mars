//
//  BINKLoyaltyScannerSchemeIdentifierSample.h
//  binkapp
//
//  Created by Nick Farrant on 30/03/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BINKLoyaltyScannerSchemeIdentifierSample : NSObject

@property (assign, nonatomic) CMSampleBufferRef sample;
@property (strong, nonatomic) AVCaptureConnection *connection;

+ (instancetype)schemeIdentifierSampleWithBuffer:(CMSampleBufferRef)buffer
                                  fromConnection:(AVCaptureConnection *)connection;

- (void)updateWithBuffer:(CMSampleBufferRef)sample
          fromConnection:(AVCaptureConnection *)connection;

- (void)cardImageWithGuideRect:(CGRect)guideRect screenSize:(CGSize)screenSize completion:(void (^)(UIImage *image, CGFloat topOffset))completion;

@end
