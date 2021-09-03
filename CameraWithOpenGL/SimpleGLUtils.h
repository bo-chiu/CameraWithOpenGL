//
//  SimpleGLUtils.h
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/2.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SimpleGLImageRotation) {
    SimpleGLImageRotationNone,
    SimpleGLImageRotationLeft,
    SimpleGLImageRotationRight,
    SimpleGLImageRotationFlipVertical,
    SimpleGLImageRotationFlipHorizonal,
    SimpleGLImageRotationRightFlipVertical,
    SimpleGLImageRotationRightFlipHorizontal,
    SimpleGLImageRotation180,
    SimpleGLImageRotationLeftFlipVertical,
    SimpleGLImageRotationLeftFlipHorizontal,
    SimpleGLImageRotation180FlipVertical,
    SimpleGLImageRotation180FlipHorizontal
};

#define STRING(x) #x

@interface SimpleGLUtils : NSObject

+ (void)bindTexture:(GLuint)textureId;
+ (GLenum)activeTextureFromIndex:(GLuint)index;

@end

static GLfloat const squareVertices[] = {
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f,
};

NS_ASSUME_NONNULL_END
