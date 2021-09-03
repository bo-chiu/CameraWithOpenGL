//
//  SimpleGLDrawable.h
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/2.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "SimpleGLProgram.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimpleGLDrawable : NSObject
/**
 * Identifier mapping to GLSL variables.
 */
@property (strong, nonatomic) NSString *identifier;

/**
 * Texture id registered to GL space. Automatically generated when texture loaded.
 */
@property (readonly) GLuint textureId;

- (instancetype)initWithTextureRef:(CVOpenGLESTextureRef)textureRef identifier:(NSString *)identifier;

- (instancetype)initWithTextureId:(GLuint)textureId identifier:(NSString *)identifier;

- (void)deleteTexture;

/**
 * Prepare drawing with active texture index.
 * Call `glActiveTexture()` and return the next available active texture index.
 */
- (GLuint)prepareToDrawAtTextureIndex:(GLuint)index program:(SimpleGLProgram *)program;

@end

NS_ASSUME_NONNULL_END
