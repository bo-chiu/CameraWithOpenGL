//
//  SimpleYuvFilter.h
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/3.
//

#import <Foundation/Foundation.h>
#import "SimpleFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimpleYuvFilter : SimpleFilter

- (void)loadYUV:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
