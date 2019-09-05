//
//  BINKBarcodeTypes.h
//  BarcodeExploration
//
//  Created by Jack Rostron on 10/02/2017.
//  Copyright © 2017 Bink. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Barcode types to pass through the the barcode generator.
 Explicit casting is being made to ensure mapping from the Bink API is correct.

 - BINKBarcodeTypeCode128: Single dimension barcode of type Code128
 - BINKBarcodeTypeCode39: Single dimension barcode of type Code39
 - BINKBarcodeTypeEAN13: Single dimension barcode of type
 - BINKBarcodeTypeITF: Single dimension barcode of type
 - BINKBarcodeTypeAztec: Two dimension barcode of type Aztec
 - BINKBarcodeTypeDataMatrix: Two dimension barcode of type Data Matrix
 - BINKBarcodeTypePDF417: Two dimension barcode of type PDF417
 - BINKBarcodeTypeQR: Two dimension barcode of type QR
 */
typedef NS_ENUM (NSUInteger, BINKBarcodeType) {
    BINKBarcodeTypeCode128      = 0,
    BINKBarcodeTypeCode39       = 7,
    BINKBarcodeTypeEAN13        = 4,
    BINKBarcodeTypeITF          = 6,
    
    BINKBarcodeTypeAztec        = 2,
    BINKBarcodeTypeDataMatrix   = 5,
    BINKBarcodeTypePDF417       = 3,
    BINKBarcodeTypeQR           = 1,
};
