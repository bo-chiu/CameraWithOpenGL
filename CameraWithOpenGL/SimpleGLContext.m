//
//  SimpleGLContext.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//

#import "SimpleGLContext.h"
#import "SimpleGLUtils.h"
#import "SimpleYuvFilter.h"
#import "SimpleGrayScaleFilter.h"

@interface SimpleGLContext ()

@property (strong, nonatomic) SimpleYuvFilter *inputFilter;
@property (strong, nonatomic) SimpleFilter *previewFilter;
@property (nonatomic) SimpleGLImageRotation previewInputRotation;
@property (nonatomic) CVOpenGLESTextureCacheRef textureCacheRef;

@end

@implementation SimpleGLContext

- (instancetype)init {
    return [self initWithContext:nil];
}

- (instancetype)initWithContext:(EAGLContext *)context {
    if (context.API == kEAGLRenderingAPIOpenGLES1)
        @throw [NSException exceptionWithName:@"SimpleGLContext init error" reason:@"GL context  can't be kEAGLRenderingAPIOpenGLES1" userInfo:nil];
    if (self = [super init]) {
        _previewInputRotation = SimpleGLImageRotationRight;
        _glContext = context ?: [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [self becomeCurrentContext];
    }
    return self;
}

- (void)dealloc {
    [self becomeCurrentContext];
    CFRelease(_textureCacheRef);
    
    [EAGLContext setCurrentContext:nil];
}

- (SimpleYuvFilter *)inputFilter {
    if (!_inputFilter) {
        _inputFilter = [[SimpleGrayScaleFilter alloc] init];
        _inputFilter.textureCacheRef = _textureCacheRef;
    }
    return _inputFilter;
}

- (SimpleFilter *)previewFilter {
    if (!_previewFilter) {
        _previewFilter = [[SimpleFilter alloc] init];
        _previewFilter.textureCacheRef = _textureCacheRef;
    }
    return _previewFilter;
}

- (void)becomeCurrentContext {
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
}

- (void)reloadTextureCache {
    [self becomeCurrentContext];
        
    if (_textureCacheRef) {
        CFRelease(_textureCacheRef);
    }
    
    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &_textureCacheRef);
    
    self.inputFilter.textureCacheRef = _textureCacheRef;
    self.previewFilter.textureCacheRef = _textureCacheRef;
}

- (GLuint)renderWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CGSize cameraSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));;
    CGSize viewPortSize = self.viewPortSize;
    CGSize outputSize = self.outputSize;
    
    self.inputFilter.inputSize = cameraSize;
    self.inputFilter.viewPortSize = viewPortSize;
    self.inputFilter.outputSize = outputSize;
    
    [self.inputFilter bindDrawable];
    [self.inputFilter loadYUV:pixelBuffer];
    [self renderFilter:self.inputFilter inputRotation:self.previewInputRotation];
    
    return self.inputFilter.outputTextureId;
}

- (void)renderFilter:(__kindof SimpleFilter *)filter
       inputRotation:(SimpleGLImageRotation)inputRotation {
    filter.inputRotation = inputRotation;
    [filter render];
    [filter draw];
}

- (void)renderToPreviewFilterWithInputTextureId:(GLuint)inputTextureId textureScaleFactor:(CGPoint)textureScaleFactor {
    self.previewFilter.textureScaleFactor = textureScaleFactor;
    // input preparation
    [self.previewFilter loadTexture:inputTextureId];
    // output preparation
    [self renderFilter:self.previewFilter inputRotation:SimpleGLImageRotationNone];
}

- (void)setOutputSize:(CGSize)outputSize {
    if (CGSizeEqualToSize(outputSize, _outputSize)) {
        return;
    }
    
    _outputSize = outputSize;
    
    [self reloadTextureCache];
    
    self.inputFilter.outputSize = outputSize;
    self.previewFilter.inputSize = self.previewFilter.outputSize = outputSize;
}


- (void)setViewPortSize:(CGSize)viewPortSize {
    if (CGSizeEqualToSize(viewPortSize, _viewPortSize)) {
        return;
    }
    
    _viewPortSize = viewPortSize;
    
    self.inputFilter.viewPortSize = viewPortSize;
    self.previewFilter.viewPortSize = viewPortSize;
}


@end
