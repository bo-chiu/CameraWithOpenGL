//
//  SimpleGLProgram.h
//  CameraWithOpenGL
//
//  Created by Bo Chiu on 2021/9/1.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimpleGLProgram : NSObject

- (instancetype)initWithVertexShader:(const char *)vertexShader
                      fragmentShader:(const char *)fragmentShader;

- (int)attributeWithName:(const char *)name;

- (int)uniformWithName:(const char *)name;

- (void)use;

/**
 * Attribute id is returned. You can cache this id and call `enableAttributeWithId:` in following usages.
 */
- (int)enableAttributeWithName:(const char *)name;

- (void)enableAttributeWithId:(GLuint)attributeId;

- (void)setParameter:(const char *)param intValue:(int)value;
- (void)setParameter:(const char *)param floatValue:(float)value;
- (void)setParameter:(const char *)param pointValue:(CGPoint)value;

@end

NS_ASSUME_NONNULL_END
