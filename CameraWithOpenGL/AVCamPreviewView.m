//
//  AVCamPreviewView.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//

@import AVFoundation;

#import "AVCamPreviewView.h"

@implementation AVCamPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer*) videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession*) session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession*) session
{
    self.videoPreviewLayer.session = session;
}

@end
