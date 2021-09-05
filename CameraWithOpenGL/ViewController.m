//
//  ViewController.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//

#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import "ViewController.h"
#import "SimpleGLContext.h"

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic , strong) dispatch_queue_t cameraProcessingQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (strong, nonatomic) SimpleGLContext *glContext;
@property (strong, nonatomic) GLKView *glkView;
@property (nonatomic) CGRect previewRect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _previewRect = [self ratio_16_9_fill_frame:[UIScreen mainScreen].bounds];
    
    self.cameraProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _session = [[AVCaptureSession alloc] init];
    
    [_session beginConfiguration];
    _session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    // input: front camera
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                 mediaType:AVMediaTypeVideo
                                                                  position:AVCaptureDevicePositionFront];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    NSAssert(input != nil, @"Encounter error while trying to open camera: %@", error);
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    
    // output
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.alwaysDiscardsLateVideoFrames = YES;
    dataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    [dataOutput setSampleBufferDelegate:self queue:self.cameraProcessingQueue];
    if ([_session canAddOutput:dataOutput]) {
        [_session addOutput:dataOutput];
    }
    
    [_session commitConfiguration];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setGLKViewRect];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(self.cameraProcessingQueue, ^{
        [self.session startRunning];
    });
}

- (SimpleGLContext *)glContext {
    if (!_glContext) {
        _glContext = [[SimpleGLContext alloc] init];
        _glContext.outputSize = CGSizeMake(720.0, 1280.0);
    }
    return _glContext;
}

- (GLKView *)glkView {
    if (!_glkView) {
        _glkView = [[GLKView alloc] initWithFrame:self.previewRect context:self.glContext.glContext];
        _glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
        _glkView.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
        _glkView.drawableStencilFormat = GLKViewDrawableStencilFormatNone;
        _glkView.drawableMultisample = GLKViewDrawableMultisampleNone;
        _glkView.layer.masksToBounds = YES;
        _glkView.enableSetNeedsDisplay = NO;
        _glkView.contentScaleFactor = 1.0;
        
        [self transformGLKViewToRect:self.previewRect];
        
        [_glkView bindDrawable];
    }
    
    return _glkView;
}

- (void)setGLKViewRect {
    if (self.glkView.superview) {
        [self.glkView removeFromSuperview];
    }
    
    [self.view insertSubview:self.glkView atIndex:0];
    self.glkView.frame = self.previewRect;
}

- (CGRect)ratio_16_9_fill_frame:(CGRect)inputFrame {
    CGRect frame = inputFrame;
    CGFloat widthDiff = 0.f;
    CGFloat heightDiff = 0.f;
    if (frame.size.width * 16.f < frame.size.height * 9.f) {
        CGFloat newWidth = frame.size.height * 9.f / 16.f;
        widthDiff = newWidth - frame.size.width;
        frame.size.width = newWidth;
        frame.origin.x = frame.origin.x - widthDiff / 2.f;
        
    } else if (frame.size.width * 16.f > frame.size.height * 9.f) {
        CGFloat newHeight = frame.size.width * 16.f / 9.f;
        heightDiff = newHeight - frame.size.height;
        frame.size.height = newHeight;
        frame.origin.y = frame.origin.y - heightDiff / 2.f;
    }
    return frame;
}

- (void)transformGLKViewToRect:(CGRect)rect {
    if (!_glkView || self.previewRect.size.width <= 0 || self.previewRect.size.height <= 0) {
        return;
    }
    
    CGAffineTransform identity = CGAffineTransformIdentity;
    // center move to top left
    CGFloat xOffset = -(self.previewRect.size.width / 2.0);
    CGFloat yOffset = -(self.previewRect.size.height / 2.0);
    // move to position
    xOffset = xOffset + (rect.origin.x + rect.size.width / 2.0);
    yOffset = yOffset + (rect.origin.y + rect.size.height / 2.0);
    
    CGFloat width = rect.size.width / self.previewRect.size.width;
    CGFloat height = rect.size.height / self.previewRect.size.height;
    
    _glkView.transform = identity;
    _glkView.transform = CGAffineTransformTranslate(_glkView.transform, xOffset, yOffset);
    _glkView.transform = CGAffineTransformScale(_glkView.transform, width, height);
    _glkView.transform = CGAffineTransformRotate(_glkView.transform, -M_PI);
}

- (CGPoint)textureScaleFactorForGLKView {
    CGPoint scaleFactor = CGPointMake(1.f, 1.f);
    if (!_glkView || self.previewRect.size.width <= 0 || self.previewRect.size.height <= 0) {
        return scaleFactor;
    }
    
    float textureAspect = self.previewRect.size.width / self.previewRect.size.height;
    float frameAspect = _glkView.frame.size.width / _glkView.frame.size.height;
    float textureFrameRatio = textureAspect / frameAspect;
    BOOL portraitFrame = (frameAspect < 1);

    if (portraitFrame) {
        if (textureFrameRatio < 1) { // GLKView frame more fat
            scaleFactor.y = textureFrameRatio;
        } else { // GLKView frame more thin
            scaleFactor.x = 1.f / textureFrameRatio;
        }
    } else {
        scaleFactor.y = textureFrameRatio;
    }
    
    return scaleFactor;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"-- 0: did output");
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self.glContext becomeCurrentContext];
    self.glContext.viewPortSize = self.previewRect.size;
    self.glContext.outputSize = self.previewRect.size;
    
    GLuint outputTextureId = [self.glContext renderWithPixelBuffer:pixelBuffer];
    [self.glkView bindDrawable];
    CGPoint textureScaleFactor = [self textureScaleFactorForGLKView];
    [self.glContext renderToPreviewFilterWithInputTextureId:outputTextureId textureScaleFactor:textureScaleFactor];
    NSLog(@"-- 8: display");
    [self.glkView display];
}

@end
