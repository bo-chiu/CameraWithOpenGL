//
//  SimpleFilter.m
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/2.
//

#import "SimpleFilter.h"

char * const kSimpleNoFilterVertex;
char * const kSimpleNoFilterFragment;

@interface SimpleFilter ()

@property (assign, nonatomic) int attrPosition;
@property (assign, nonatomic) int attrInputTextureCoordinate;

@property (strong, nonatomic) SimpleGLDrawable *inputImageDrawable;

@property (assign, nonatomic) GLuint outputFrameBuffer;

@end

@implementation SimpleFilter

+ (const GLfloat *)textureCoordinatesForRotation:(SimpleGLImageRotation)rotation {
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] = {
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
    };
    
    // vertical flip first and then rotate right
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    // horizontal flip first and then rotate right
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    // vertical flip first and then rotate left
    static const GLfloat rotateLeftVerticalFlipTextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };
    
    // horizontal flip first and then rotate left
    static const GLfloat rotateLeftHorizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    // vertical flip first and then rotate 180
    static const GLfloat rotate180VerticalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
    };
    
    // horizontal flip first and then rotate 180
    static const GLfloat rotate180HorizontalFlipTextureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    switch(rotation) {
        case SimpleGLImageRotationNone:
            return noRotationTextureCoordinates;
        case SimpleGLImageRotationLeft:
            return rotateLeftTextureCoordinates;
        case SimpleGLImageRotationRight:
            return rotateRightTextureCoordinates;
        case SimpleGLImageRotationFlipVertical:
            return verticalFlipTextureCoordinates;
        case SimpleGLImageRotationFlipHorizonal:
            return horizontalFlipTextureCoordinates;
        case SimpleGLImageRotationRightFlipVertical:
            return rotateRightVerticalFlipTextureCoordinates;
        case SimpleGLImageRotationRightFlipHorizontal:
            return rotateRightHorizontalFlipTextureCoordinates;
        case SimpleGLImageRotation180:
            return rotate180TextureCoordinates;
        case SimpleGLImageRotationLeftFlipVertical:
            return rotateLeftVerticalFlipTextureCoordinates;
        case SimpleGLImageRotationLeftFlipHorizontal:
            return rotateLeftHorizontalFlipTextureCoordinates;
        case SimpleGLImageRotation180FlipVertical:
            return rotate180VerticalFlipTextureCoordinates;
        case SimpleGLImageRotation180FlipHorizontal:
            return rotate180HorizontalFlipTextureCoordinates;
    }
}

- (instancetype)init {
    return [self initWithVertexShader:kSimpleNoFilterVertex fragmentShader:kSimpleNoFilterFragment];
}

- (instancetype)initWithVertexShader:(const char *)vertexShader
                      fragmentShader:(const char *)fragmentShader {
    if (self = [super init]) {
        _program = [[SimpleGLProgram alloc] initWithVertexShader:vertexShader fragmentShader:fragmentShader];
        _attrPosition = [_program attributeWithName:"position"];
        _attrInputTextureCoordinate = [_program attributeWithName:"inputTextureCoordinate"];
        _textureScaleFactor = CGPointMake(1.0, 1.0);
    }
    return self;
}

- (void)dealloc {
    [self deleteTextures];
    [self unloadOutputBuffer];
}

- (void)setOutputSize:(CGSize)outputSize {
    if (CGSizeEqualToSize(outputSize, _outputSize))
        return;
    _outputSize = outputSize;
    
    [self unloadOutputBuffer];
    [self loadOutputBuffer];
}

- (void)setTextureScaleFactor:(CGPoint)textureScaleFactor {
    if (CGPointEqualToPoint(textureScaleFactor, _textureScaleFactor)) {
        return;
    }
    _textureScaleFactor = textureScaleFactor;
}

- (void)loadTextures {
    // do nothing
}

- (void)deleteTextures {
    for (SimpleGLDrawable *drawable in [self renderTextures]) {
        [drawable deleteTexture];
    }
}

- (void)loadTexture:(GLuint)textureId {
    _inputImageDrawable = [[SimpleGLDrawable alloc] initWithTextureId:textureId identifier:@"inputImageTexture"];
}

- (NSArray<SimpleGLDrawable *> *)renderTextures {
    // to be overrided
    return nil;
}

- (void)setAdditionalUniformVarsForRender {
    [self.program setParameter:"textureScaleFactor" pointValue:self.textureScaleFactor];
}

- (void)renderDrawable:(SimpleGLDrawable *)drawable {
    if (!drawable) {
        return;
    }
    
    [self bindDrawable];
    
    [_program use];
    [_program enableAttributeWithId:_attrPosition];
    [_program enableAttributeWithId:_attrInputTextureCoordinate];
    
    glVertexAttribPointer(_attrPosition, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(_attrInputTextureCoordinate, 2, GL_FLOAT, 0, 0, [self.class textureCoordinatesForRotation:_inputRotation]);
    
    [self setAdditionalUniformVarsForRender];
    
    [drawable prepareToDrawAtTextureIndex:0 program:_program];
}

- (GLuint)render {
    [_program use];
    glEnableVertexAttribArray(_attrPosition);
    glEnableVertexAttribArray(_attrInputTextureCoordinate);
    glVertexAttribPointer(_attrPosition, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(_attrInputTextureCoordinate, 2, GL_FLOAT, 0, 0, [self.class textureCoordinatesForRotation:_inputRotation]);
    
    [self setAdditionalUniformVarsForRender];
    
    GLuint index = 0;
    if (_inputImageDrawable) {
        index = [_inputImageDrawable prepareToDrawAtTextureIndex:index program:_program];
    }
    for (SimpleGLDrawable *drawable in [self renderTextures]) {
        index = [drawable prepareToDrawAtTextureIndex:index program:_program];
    }
    return index;
}

- (void)bindDrawable {
    glBindFramebuffer(GL_FRAMEBUFFER, _outputFrameBuffer);
}

- (void)draw {
    glViewport(0, 0, self.viewPortSize.width, self.viewPortSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)loadOutputBuffer {
    NSDictionary* attrs = @{(__bridge NSString*) kCVPixelBufferIOSurfacePropertiesKey: @{}};
    CVPixelBufferCreate(kCFAllocatorDefault, _outputSize.width, _outputSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) attrs, &_outputPixelBuffer);
    
    CVOpenGLESTextureRef outputTextureRef;
    CVReturn error = kCVReturnSuccess;
    error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                 _textureCacheRef,
                                                 _outputPixelBuffer,
                                                 NULL,
                                                 GL_TEXTURE_2D,
                                                 GL_RGBA,
                                                 _outputSize.width,
                                                 _outputSize.height,
                                                 GL_BGRA,
                                                 GL_UNSIGNED_BYTE,
                                                 0,
                                                 &outputTextureRef);
    if (error) {
        NSLog(@"Fail to create output texture!");
        return;
    }
    
    _outputTextureId = CVOpenGLESTextureGetName(outputTextureRef);
    [SimpleGLUtils bindTexture:_outputTextureId];
    CFRelease(outputTextureRef);
    
    // create output frame buffer
    glGenFramebuffers(1, &_outputFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _outputFrameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _outputTextureId, 0);
}

- (void)unloadOutputBuffer {
    if (_outputTextureId) {
        glDeleteTextures(1, &_outputTextureId);
    }
    if (_outputPixelBuffer) {
        CFRelease(_outputPixelBuffer);
        _outputPixelBuffer = NULL;
    }
    if (_outputFrameBuffer) {
        glDeleteFramebuffers(1, &_outputFrameBuffer);
    }
}

@end


char * const kSimpleNoFilterVertex = STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 uniform vec2 textureScaleFactor;
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = textureScaleFactor * (inputTextureCoordinate.xy - 0.5) + 0.5;
 }
);

char * const kSimpleNoFilterFragment = STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     // make "aspect fit" content type be filled with black background
     if (textureCoordinate.x < 0.0 || textureCoordinate.x > 1.0 ||
         textureCoordinate.y < 0.0 || textureCoordinate.y > 1.0) {
          discard;
     }
    
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
);
