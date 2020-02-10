//
//  BINKBarcodeGenerator.h
//  BarcodeExploration
//
//  Created by Jack Rostron on 10/02/2017.
//  Copyright © 2017 Bink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BINKBarcodeTypes.h"

@interface BINKBarcodeGenerator : NSObject

/**
 *  Retrieve an image representing a barcode of the desired type scaled to the passed size
 *
 *  @param contents The string to encode in the barcode
 *  @param type     The type of barcode to generate
 *  @param size     The desired size. Non-system types will be aspect fit, system types will be stretched
 *
 *  @return Nil if the contents cannot be encoded in that barcode type, an image of the barcode if it can
 */
+ (UIImage *)generateBarcodeWithContents:(NSString *)contents
                                  ofType:(BINKBarcodeType)type
                                  inSize:(CGSize)size;

@end
