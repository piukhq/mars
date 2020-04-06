//
//  BINKLoyaltyScannerSchemeIdentifierSample.m
//  binkapp
//
//  Created by Nick Farrant on 30/03/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
//#include <opencv2/highgui/ios.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#include <opencv2/imgproc/imgproc.hpp>
#include <cstddef>
#endif

#import <AVFoundation/AVFoundation.h>
#import "BINKLoyaltyScannerSchemeIdentifierSample.h"

static NSInteger const BINKSchemeDetectorRotation = 90;
//static CGFloat const BINKSchemeDetectorImageScale = 2.0;

struct BINKSchemeDetectorVideoFrame {
    size_t width;
    size_t height;
    size_t stride;
    unsigned char * data;
};

@implementation BINKLoyaltyScannerSchemeIdentifierSample

+ (instancetype)schemeIdentifierSampleWithBuffer:(CMSampleBufferRef)buffer fromConnection:(AVCaptureConnection *)connection {
    BINKLoyaltyScannerSchemeIdentifierSample *sample = [[BINKLoyaltyScannerSchemeIdentifierSample alloc] init];
    [sample updateWithBuffer:buffer fromConnection:connection];
    return sample;
}

- (void)updateWithBuffer:(CMSampleBufferRef)sample fromConnection:(AVCaptureConnection *)connection {
    self.sample = sample;
    self.connection = connection;
}

- (void)cardImageWithGuideRect:(CGRect)guideRect screenSize:(CGSize)screenSize completion:(void (^)(UIImage *image, CGFloat topOffset))completion {

    __weak typeof(self) weakSelf = self;

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(weakSelf.sample);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    uint8_t *baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(imageBuffer);
    BINKSchemeDetectorVideoFrame frame = {width, height, stride, baseAddress};
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

    // Get the input image.

    cv::Mat inputImage = [weakSelf getImageWithFrame:frame];

    if (!inputImage.data) {
        completion(nil, 0.0);

        return;
    }

    // Required to make sure our colours are mapped correctly
//    cvtColor(inputImage, inputImage, CV_BGR2RGB);

    cv::Mat rotatedImage;
    rotate_image_90n(inputImage, rotatedImage, BINKSchemeDetectorRotation);

    // height here is actually width due to rotation
    CGRect videoFrameScaled = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(height, width), (CGRect){CGPointZero, screenSize});

    CGFloat horizontalRatio = height / videoFrameScaled.size.width;
    CGFloat verticalRatio = width / videoFrameScaled.size.height;

    CGFloat offset = videoFrameScaled.origin.y;
    cv::Rect cropRect(guideRect.origin.x * horizontalRatio, (guideRect.origin.y - offset) * verticalRatio, guideRect.size.width * horizontalRatio, guideRect.size.height * verticalRatio);
    cv::Mat croppedImage = rotatedImage(cropRect);

    cv::Mat cropped;
    croppedImage.copyTo(cropped);

    UIImage *image = MatToUIImage(cropped);

    completion(image, offset);
}

#pragma mark - Image Processing (Private)

- (cv::Mat)getImageWithFrame:(BINKSchemeDetectorVideoFrame)frame {
    return cv::Mat((int)frame.height, (int)frame.width, CV_8UC4, frame.data, frame.stride);
}

static void rotate_image_90n(cv::Mat &src, cv::Mat &dst, int angle) {
    if (src.data != dst.data){
        src.copyTo(dst);
    }

    angle = ((angle / 90) % 4) * 90;

    //0 : flip vertical; 1 flip horizontal
    bool const flip_horizontal_or_vertical = angle > 0 ? 1 : 0;
    int const number = std::abs(angle / 90);

    for(int i = 0; i != number; ++i){
        cv::transpose(src, dst);
        cv::flip(dst, dst, flip_horizontal_or_vertical);
    }
}

@end
