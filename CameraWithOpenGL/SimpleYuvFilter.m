//
//  SimpleYuvFilter.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/3.
//

#import "SimpleYuvFilter.h"
#import "SimpleGLProgram.h"
#import "SimpleGLDrawable.h"
#import "SimpleGLUtils.h"

char * const kSimpleGLYuvFilterVertex;
char * const kSimpleGLYuvFilterFragment;

@interface SimpleYuvFilter ()

@property (strong, nonatomic) SimpleGLDrawable *yDrawable;
@property (strong, nonatomic) SimpleGLDrawable *uvDrawable;

@end

@implementation SimpleYuvFilter

- (instancetype)init {
    return [self initWithVertexShader:kSimpleGLYuvFilterVertex fragmentShader:kSimpleGLYuvFilterFragment];
}

- (void)loadYUV:(CVPixelBufferRef)pixelBuffer {
    NSLog(@"-- 4: load yuv texture");
    int width = (int) CVPixelBufferGetWidth(pixelBuffer);
    int height = (int) CVPixelBufferGetHeight(pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    CVOpenGLESTextureRef luminanceTextureRef, chrominanceTextureRef;
    
    // y texture
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCacheRef, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
    
    _yDrawable = [[SimpleGLDrawable alloc] initWithTextureRef:luminanceTextureRef identifier:@"yTexture"];
    
    // uv texture
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCacheRef, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, width/2, height/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
    
    _uvDrawable = [[SimpleGLDrawable alloc] initWithTextureRef:chrominanceTextureRef identifier:@"uvTexture"];
    
    CFRelease(luminanceTextureRef);
    CFRelease(chrominanceTextureRef);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (NSArray<SimpleGLDrawable*> *)renderTextures {
    NSMutableArray *array = [NSMutableArray array];
    if (self.yDrawable && self.uvDrawable ) {
        [array addObject:self.yDrawable];
        [array addObject:self.uvDrawable];
    }
    return [array copy];
}

@end


char * const kSimpleGLYuvFilterVertex = STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

char * const kSimpleGLYuvFilterFragment = STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D yTexture;
 uniform sampler2D uvTexture;
 
 const mat3 yuv2rgbMatrix = mat3(1.0, 1.0, 1.0,
                                 0.0, -0.343, 1.765,
                                 1.4, -0.711, 0.0);
 
 const float DEPTH1 = .3;
 const float WIDTH1 = .1;
 const float SPEED1 = .6;
 const float DEPTH2 = .1;
 const float WIDTH2 = .3;
 const float SPEED2 = .1;
 
 vec3 rgbFromYuv(sampler2D yTexture, sampler2D uvTexture, vec2 textureCoordinate) {
     float y = texture2D(yTexture, textureCoordinate).r;
     float u = texture2D(uvTexture, textureCoordinate).r - 0.5;
     float v = texture2D(uvTexture, textureCoordinate).a - 0.5;
     return yuv2rgbMatrix * vec3(y, u, v);
 }
 
 void main() {
     vec3 centralColor = rgbFromYuv(yTexture, uvTexture, textureCoordinate).rgb;
     vec4 tempColor = vec4(centralColor, 1.0);
    
    gl_FragColor = tempColor;
 }
 );
