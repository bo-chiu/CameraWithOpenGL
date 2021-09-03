//
//  SimpleFilter.h
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/2.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "SimpleGLProgram.h"
#import "SimpleGLDrawable.h"
#import "SimpleGLUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimpleFilter : NSObject

@property (strong, nonatomic, readonly) SimpleGLProgram *program;

@property (nonatomic) SimpleGLImageRotation inputRotation;
@property (nonatomic) CGSize inputSize;
@property (nonatomic) CGSize outputSize;
@property (nonatomic) CGSize viewPortSize;
@property (nonatomic) CGPoint textureScaleFactor;

@property (nonatomic) CVOpenGLESTextureCacheRef textureCacheRef;
@property (nonatomic) GLuint outputTextureId;
@property (nonatomic, readonly) CVPixelBufferRef outputPixelBuffer;

- (instancetype)initWithVertexShader:(const char *)vertexShader
                      fragmentShader:(const char *)fragmentShader;

- (void)loadTexture:(GLuint)textureId;

- (void)setAdditionalUniformVarsForRender;

- (void)bindDrawable;

- (GLuint)render;

- (void)draw;

@end

NS_ASSUME_NONNULL_END
