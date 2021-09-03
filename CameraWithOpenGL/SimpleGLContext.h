//
//  SimpleGLContext.h
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimpleGLContext : NSObject

@property (strong, nonatomic, readonly) EAGLContext *glContext;
@property (nonatomic) CGSize outputSize;
@property (nonatomic) CGSize viewPortSize;

- (instancetype)initWithContext:(EAGLContext *)context;
- (void)becomeCurrentContext;
- (GLuint)renderWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)renderToPreviewFilterWithInputTextureId:(GLuint)inputTextureId textureScaleFactor:(CGPoint)textureScaleFactor;

@end

NS_ASSUME_NONNULL_END
