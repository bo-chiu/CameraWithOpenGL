//
//  AVCamPreviewView.h
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCamPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) AVCaptureSession *session;

@end

NS_ASSUME_NONNULL_END
