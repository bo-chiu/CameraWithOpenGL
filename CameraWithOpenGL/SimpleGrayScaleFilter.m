//
//  SimpleGrayScaleFilter.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/5.
//

#import "SimpleGrayScaleFilter.h"
#import "SimpleGLUtils.h"

char * const kSimpleGLGrayScaleFilterVertex;
char * const kSimpleGLGrayScaleFilterFragment;

@implementation SimpleGrayScaleFilter

- (instancetype)init {
    return [self initWithVertexShader:kSimpleGLGrayScaleFilterVertex fragmentShader:kSimpleGLGrayScaleFilterFragment];
}

@end


char * const kSimpleGLGrayScaleFilterVertex = STRING
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

char * const kSimpleGLGrayScaleFilterFragment = STRING
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
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 vec3 rgbFromYuv(sampler2D yTexture, sampler2D uvTexture, vec2 textureCoordinate) {
     float y = texture2D(yTexture, textureCoordinate).r;
     float u = texture2D(uvTexture, textureCoordinate).r - 0.5;
     float v = texture2D(uvTexture, textureCoordinate).a - 0.5;
     return yuv2rgbMatrix * vec3(y, u, v);
 }
 
 void main() {
     vec3 centralColor = rgbFromYuv(yTexture, uvTexture, textureCoordinate).rgb;
     vec4 tempColor = vec4(centralColor, 1.0);
     float luminance = dot(tempColor.rgb, W);
     gl_FragColor = vec4(vec3(luminance), tempColor.a);
 }
 );
