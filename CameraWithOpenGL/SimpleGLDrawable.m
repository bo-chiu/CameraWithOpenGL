//
//  SimpleGLDrawable.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/2.
//

#import "SimpleGLDrawable.h"
#import "SimpleGLProgram.h"
#import "SimpleGLUtils.h"

@implementation SimpleGLDrawable

- (instancetype)initWithTextureRef:(CVOpenGLESTextureRef)textureRef identifier:(NSString *)identifier {
    if (self = [super init]) {
        _identifier = identifier;
        _textureId = CVOpenGLESTextureGetName(textureRef);
        [SimpleGLUtils bindTexture:_textureId];
    }
    return self;
}

- (instancetype)initWithTextureId:(GLuint)textureId identifier:(NSString *)identifier {
    if (self = [super init]) {
        _identifier = identifier;
        _textureId = textureId;
        [SimpleGLUtils bindTexture:textureId];
    }
    return self;
}

- (void)deleteTexture {
    glDeleteTextures(1, &_textureId);
}

- (GLuint)prepareToDrawAtTextureIndex:(GLuint)index program:(SimpleGLProgram *)program {
    glActiveTexture([SimpleGLUtils activeTextureFromIndex:index]);
    glBindTexture(GL_TEXTURE_2D, _textureId);
    glUniform1i([program uniformWithName:_identifier.UTF8String], index);
    
    return index + 1;
}

@end
