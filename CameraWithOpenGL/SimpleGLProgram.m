//
//  SimpleGLProgram.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//


#import "SimpleGLProgram.h"

@interface SimpleGLProgram ()

@property (assign, nonatomic) GLuint program;
@property (assign, nonatomic) GLuint vertexShader;
@property (assign, nonatomic) GLuint fragmentShader;

@end

@implementation SimpleGLProgram

- (instancetype)initWithVertexShader:(const char *)vertexShader
                      fragmentShader:(const char *)fragmentShader {
    if (self = [super init]) {
        _program = glCreateProgram();
        _vertexShader = [self loadShader:GL_VERTEX_SHADER withString:vertexShader];
        _fragmentShader = [self loadShader:GL_FRAGMENT_SHADER withString:fragmentShader];
        [self link];
        [self use];
    }
    return self;
}

- (void)dealloc {
    if (_vertexShader) {
        glDeleteShader(_vertexShader);
    }
        
    if (_fragmentShader) {
        glDeleteShader(_fragmentShader);
    }
    
    if (_program) {
        glDeleteProgram(_program);
    }
}

#pragma mark - Public

- (int)attributeWithName:(const char *)name {
    return glGetAttribLocation(_program, name);
}

- (int)uniformWithName:(const char *)name {
    return glGetUniformLocation(_program, name);
}

- (void)use {
    glUseProgram(_program);
}

#pragma mark - Private

- (GLuint)loadShader:(GLenum)type withString:(const char *)string {
    GLuint shader = glCreateShader(type);
    int length = (int)strlen(string);
    glShaderSource(shader, 1, (const char **)&string, &length);
    glCompileShader(shader);
    
    glAttachShader(_program, shader);
    
    return shader;
}

- (BOOL)link {
    GLint status;
    
    glLinkProgram(_program);
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    
    if (_vertexShader) {
        glDeleteShader(_vertexShader);
        _vertexShader = 0;
    }
    if (_fragmentShader) {
        glDeleteShader(_fragmentShader);
        _fragmentShader = 0;
    }
    
    return status == GL_TRUE;
}

- (int)enableAttributeWithName:(const char *)name {
    int attrId = [self attributeWithName:name];
    glEnableVertexAttribArray(attrId);
    return attrId;
}

- (void)enableAttributeWithId:(GLuint)attributeId {
    glEnableVertexAttribArray(attributeId);
}

- (void)setParameter:(const char *)param intValue:(int)value {
    glUniform1i([self uniformWithName:param], value);
}

- (void)setParameter:(const char *)param floatValue:(float)value {
    glUniform1f([self uniformWithName:param], value);
}

- (void)setParameter:(const char *)param pointValue:(CGPoint)value {
    const GLfloat offset[] = {value.x, value.y};
    glUniform2fv([self uniformWithName:param], 1, offset);
}

@end
