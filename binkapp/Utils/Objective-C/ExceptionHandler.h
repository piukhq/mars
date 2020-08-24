//
//  ExceptionHandler.h
//  binkapp
//
//  Created by Nick Farrant on 28/07/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
