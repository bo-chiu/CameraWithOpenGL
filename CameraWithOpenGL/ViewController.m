//
//  ViewController.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "AVCamPreviewView.h"

@interface ViewController ()

@property (nonatomic , strong) dispatch_queue_t cameraProcessingQueue;
@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _session = [[AVCaptureSession alloc] init];
    
    AVCamPreviewView *previewView = [[AVCamPreviewView alloc] initWithFrame:self.view.frame];
    previewView.session = _session;
    self.view = previewView;
    
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
    
    [_session commitConfiguration];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(self.cameraProcessingQueue, ^{
        [self.session startRunning];
    });
}

@end
