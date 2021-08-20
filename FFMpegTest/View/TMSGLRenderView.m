//
//  TMSGLRenderView.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import "TMSGLRenderView.h"
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>
#import "TMSMediaVideoContext.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

enum {
    ATTRIBUTE_VERTEX,
    ATTRIBUTE_TEXCOORD,
};

static NSData * copyFrameData(UInt8 *src, int linesize, int width, int height)
{
    width = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength: width * height];
    Byte *dst = md.mutableBytes;
    for (NSUInteger i = 0; i < height; ++i) {
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

//static BOOL validateProgram(GLuint prog)
//{
//    GLint status;
//
//    glValidateProgram(prog);
//
//#ifdef DEBUG
//    GLint logLength;
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0)
//    {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program validate log:\n%s", log);
//        free(log);
//    }
//#endif
//
//    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
//    if (status == GL_FALSE) {
//        NSLog(@"Failed to validate program %d", prog);
//        return NO;
//    }
//
//    return YES;
//}
//
//static GLuint compileShader(GLenum type, NSString *shaderString)
//{
//    GLint status;
//    const GLchar *sources = (GLchar *)shaderString.UTF8String;
//
//    GLuint shader = glCreateShader(type);
//    if (shader == 0 || shader == GL_INVALID_ENUM) {
//        NSLog(@"Failed to create shader %d", type);
//        return 0;
//    }
//
//    glShaderSource(shader, 1, &sources, NULL);
//    glCompileShader(shader);
//
//#ifdef DEBUG
//    GLint logLength;
//    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0)
//    {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetShaderInfoLog(shader, logLength, &logLength, log);
//        NSLog(@"Shader compile log:\n%s", log);
//        free(log);
//    }
//#endif
//
//    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
//    if (status == GL_FALSE) {
//        glDeleteShader(shader);
//        NSLog(@"Failed to compile shader:\n");
//        return 0;
//    }
//
//    return shader;
//}
//
//NSString *const vertexShaderString = SHADER_STRING
//(
// attribute vec4 position;
// attribute vec2 texcoord;
// uniform mat4 modelViewProjectionMatrix;
// varying vec2 v_texcoord;
//
// void main()
// {
//     gl_Position = modelViewProjectionMatrix * position;
//     v_texcoord = texcoord.xy;
// }
//);
//
//NSString *const yuvFragmentShaderString = SHADER_STRING
//(
// varying highp vec2 v_texcoord;
// uniform sampler2D s_texture_y;
// uniform sampler2D s_texture_u;
// uniform sampler2D s_texture_v;
//
// void main()
// {
//     highp float y = texture2D(s_texture_y, v_texcoord).r;
//     highp float u = texture2D(s_texture_u, v_texcoord).r - 0.5;
//     highp float v = texture2D(s_texture_v, v_texcoord).r - 0.5;
//
//     highp float r = y +             1.402 * v;
//     highp float g = y - 0.344 * u - 0.714 * v;
//     highp float b = y + 1.772 * u;
//
//     gl_FragColor = vec4(r,g,b,1.0);
// }
//);
//
//static void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout)
//{
//    float r_l = right - left;
//    float t_b = top - bottom;
//    float f_n = far - near;
//    float tx = - (right + left) / (right - left);
//    float ty = - (top + bottom) / (top - bottom);
//    float tz = - (far + near) / (far - near);
//
//    mout[0] = 2.0f / r_l;
//    mout[1] = 0.0f;
//    mout[2] = 0.0f;
//    mout[3] = 0.0f;
//
//    mout[4] = 0.0f;
//    mout[5] = 2.0f / t_b;
//    mout[6] = 0.0f;
//    mout[7] = 0.0f;
//
//    mout[8] = 0.0f;
//    mout[9] = 0.0f;
//    mout[10] = -2.0f / f_n;
//    mout[11] = 0.0f;
//
//    mout[12] = tx;
//    mout[13] = ty;
//    mout[14] = tz;
//    mout[15] = 1.0f;
//}
//
//@interface KxMovieGLRenderer_YUV : NSObject {
//
//    GLint _uniformSamplers[3];
//    GLuint _textures[3];
//}
//- (BOOL) prepareRender;
//- (BOOL)isValid;
//- (void) resolveUniforms: (GLuint) program;
//- (void)setFrame: (AVFrame *)frame videoContext:(TMSMediaVideoContext *)videoContext;
//@end
//
//@implementation KxMovieGLRenderer_YUV
//
//- (BOOL) isValid
//{
//    return (_textures[0] != 0);
//}
//
//- (void) resolveUniforms: (GLuint) program
//{
//    _uniformSamplers[0] = glGetUniformLocation(program, "s_texture_y");
//    _uniformSamplers[1] = glGetUniformLocation(program, "s_texture_u");
//    _uniformSamplers[2] = glGetUniformLocation(program, "s_texture_v");
//}
//
//- (void)setFrame: (AVFrame *)frame videoContext:(TMSMediaVideoContext *)videoContext
//{
//    NSData *yData = copyFrameData(frame->data[0],
//                                  frame->linesize[0],
//                                  videoContext.codecContext->width,
//                                  videoContext.codecContext->height);
//    NSData *uData = copyFrameData(frame->data[1],
//                                  frame->linesize[1],
//                                  videoContext.codecContext->width / 2,
//                                  videoContext.codecContext->height / 2);
//    NSData *vData = copyFrameData(frame->data[2],
//                                  frame->linesize[2],
//                                  videoContext.codecContext->width / 2,
//                                  videoContext.codecContext->height / 2);
//
//    assert(yData.length == frame->width * frame->height);
//    assert(uData.length == (frame->width * frame->height) / 4);
//    assert(vData.length == (frame->width * frame->height) / 4);
//
//    const NSUInteger frameWidth = videoContext.codecContext->width;
//    const NSUInteger frameHeight = videoContext.codecContext->height;
//
//    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//
//    if (0 == _textures[0])
//        glGenTextures(3, _textures);
//
//    const UInt8 *pixels[3] = { yData.bytes, uData.bytes, vData.bytes };
//    const NSUInteger widths[3]  = { frameWidth, frameWidth / 2, frameWidth / 2 };
//    const NSUInteger heights[3] = { frameHeight, frameHeight / 2, frameHeight / 2 };
//
//    for (int i = 0; i < 3; ++i) {
//
//        glBindTexture(GL_TEXTURE_2D, _textures[i]);
//
//        glTexImage2D(GL_TEXTURE_2D,
//                     0,
//                     GL_LUMINANCE,
//                     widths[i],
//                     heights[i],
//                     0,
//                     GL_LUMINANCE,
//                     GL_UNSIGNED_BYTE,
//                     pixels[i]);
//
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//    }
//}
//
//- (BOOL) prepareRender
//{
//    if (_textures[0] == 0)
//        return NO;
//
//    for (int i = 0; i < 3; ++i) {
//        glActiveTexture(GL_TEXTURE0 + i);
//        glBindTexture(GL_TEXTURE_2D, _textures[i]);
//        glUniform1i(_uniformSamplers[i], i);
//    }
//
//    return YES;
//}
//
//- (void) dealloc
//{
//    if (_textures[0])
//        glDeleteTextures(3, _textures);
//}
//
//@end
//
//@implementation TMSGLRenderView {
//
//    EAGLContext     *_context;
//    GLuint          _framebuffer;
//    GLuint          _renderbuffer;
//    GLint           _backingWidth;
//    GLint           _backingHeight;
//    GLuint          _program;
//    GLint           _uniformMatrix;
//    GLfloat         _vertices[8];
//
//    TMSMediaVideoContext *_videoContext;
//    KxMovieGLRenderer_YUV *_renderer;
//}
//
//+ (Class) layerClass
//{
//    return [CAEAGLLayer class];
//}
//
//- (id)initWithFrame:(CGRect)frame videoContext:(TMSMediaVideoContext *)videoContext {
//
//    self = [super initWithFrame:frame];
//    if (self) {
//
//        _videoContext = videoContext;
//
//        _renderer = [[KxMovieGLRenderer_YUV alloc] init];
//        NSLog( @"OK use YUV GL renderer");
//
//        CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
//        eaglLayer.opaque = YES;
//        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
//                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
//                                        nil];
//
//        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//
//        if (!_context ||
//            ![EAGLContext setCurrentContext:_context]) {
//            return nil;
//        }
//
//        glGenFramebuffers(1, &_framebuffer);
//        glGenRenderbuffers(1, &_renderbuffer);
//        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
//        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
//        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
//        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
//        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
//        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
//
//        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//        if (status != GL_FRAMEBUFFER_COMPLETE) {
//
//            NSLog(@"failed to make complete framebuffer object %x", status);
//            self = nil;
//            return nil;
//        }
//
//        GLenum glError = glGetError();
//        if (GL_NO_ERROR != glError) {
//
//            NSLog(@"failed to setup GL %x", glError);
//            self = nil;
//            return nil;
//        }
//
//        if (![self loadShaders]) {
//
//            self = nil;
//            return nil;
//        }
//
//        _vertices[0] = -1.0f;  // x0
//        _vertices[1] = -1.0f;  // y0
//        _vertices[2] =  1.0f;  // ..
//        _vertices[3] = -1.0f;
//        _vertices[4] = -1.0f;
//        _vertices[5] =  1.0f;
//        _vertices[6] =  1.0f;  // x3
//        _vertices[7] =  1.0f;  // y3
//
//        NSLog(@"OK setup GL");
//    }
//
//    return self;
//}
//
//- (void)dealloc
//{
//    _renderer = nil;
//
//    if (_framebuffer) {
//        glDeleteFramebuffers(1, &_framebuffer);
//        _framebuffer = 0;
//    }
//
//    if (_renderbuffer) {
//        glDeleteRenderbuffers(1, &_renderbuffer);
//        _renderbuffer = 0;
//    }
//
//    if (_program) {
//        glDeleteProgram(_program);
//        _program = 0;
//    }
//
//    if ([EAGLContext currentContext] == _context) {
//        [EAGLContext setCurrentContext:nil];
//    }
//
//    _context = nil;
//}
//
//- (void)layoutSubviews
//{
//    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
//    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
//
//    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//    if (status != GL_FRAMEBUFFER_COMPLETE) {
//
//        NSLog(@"failed to make complete framebuffer object %x", status);
//
//    } else {
//
//        NSLog(@"OK setup GL framebuffer %d:%d", _backingWidth, _backingHeight);
//    }
//
//    [self updateVertices];
//    [self render: nil];
//}
//
//- (void)setContentMode:(UIViewContentMode)contentMode
//{
//    [super setContentMode:contentMode];
//    [self updateVertices];
//    if (_renderer.isValid) {
//        [self render:nil];
//    }
//}
//
//- (BOOL)loadShaders
//{
//    BOOL result = NO;
//    GLuint vertShader = 0, fragShader = 0;
//
//    _program = glCreateProgram();
//
//    vertShader = compileShader(GL_VERTEX_SHADER, vertexShaderString);
//    if (!vertShader)
//        goto exit;
//
//    fragShader = compileShader(GL_FRAGMENT_SHADER, yuvFragmentShaderString);
//    if (!fragShader)
//        goto exit;
//
//    glAttachShader(_program, vertShader);
//    glAttachShader(_program, fragShader);
//    glBindAttribLocation(_program, ATTRIBUTE_VERTEX, "position");
//    glBindAttribLocation(_program, ATTRIBUTE_TEXCOORD, "texcoord");
//
//    glLinkProgram(_program);
//
//    GLint status;
//    glGetProgramiv(_program, GL_LINK_STATUS, &status);
//    if (status == GL_FALSE) {
//        NSLog(@"Failed to link program %d", _program);
//        goto exit;
//    }
//
//    result = validateProgram(_program);
//
//    _uniformMatrix = glGetUniformLocation(_program, "modelViewProjectionMatrix");
//    [_renderer resolveUniforms:_program];
//
//exit:
//
//    if (vertShader)
//        glDeleteShader(vertShader);
//    if (fragShader)
//        glDeleteShader(fragShader);
//
//    if (result) {
//
//        NSLog(@"OK setup GL programm");
//
//    } else {
//
//        glDeleteProgram(_program);
//        _program = 0;
//    }
//
//    return result;
//}
//
//- (void)updateVertices
//{
//    const BOOL fit      = (self.contentMode == UIViewContentModeScaleAspectFit);
//    const float width   = _videoContext.codecContext->width;
//    const float height  = _videoContext.codecContext->height;
//    const float dH      = (float)_backingHeight / height;
//    const float dW      = (float)_backingWidth      / width;
//    const float dd      = fit ? MIN(dH, dW) : MAX(dH, dW);
//    const float h       = (height * dd / (float)_backingHeight);
//    const float w       = (width  * dd / (float)_backingWidth );
//
//    _vertices[0] = - w;
//    _vertices[1] = - h;
//    _vertices[2] =   w;
//    _vertices[3] = - h;
//    _vertices[4] = - w;
//    _vertices[5] =   h;
//    _vertices[6] =   w;
//    _vertices[7] =   h;
//}
//
//- (void)render: (AVFrame *) frame {
//
//    static const GLfloat texCoords[] = {
//        0.0f, 1.0f,
//        1.0f, 1.0f,
//        0.0f, 0.0f,
//        1.0f, 0.0f,
//    };
//
//    [EAGLContext setCurrentContext:_context];
//
//    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
//    glViewport(0, 0, _backingWidth, _backingHeight);
//    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT);
//    glUseProgram(_program);
//
//    if (frame) {
//        [_renderer setFrame:frame videoContext:_videoContext];
//    }
//
//    if ([_renderer prepareRender]) {
//
//        GLfloat modelviewProj[16];
//        mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);
//        glUniformMatrix4fv(_uniformMatrix, 1, GL_FALSE, modelviewProj);
//
//        glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, _vertices);
//        glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
//        glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, texCoords);
//        glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
//
//    #if 0
//        if (!validateProgram(_program))
//        {
//            LoggerVideo(0, @"Failed to validate program");
//            return;
//        }
//    #endif
//
//        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    }
//
//    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
//    [_context presentRenderbuffer:GL_RENDERBUFFER];
//}
//
//- (void)displayWithFrame:(AVFrame *)yuvFrame {
//
//    [self render:yuvFrame];
//}
//
//@end

@interface TMSGLRenderView ()
@property(nonatomic,strong)EAGLContext* context;

@property(nonatomic,assign)GLuint frameBuffer;

@property(nonatomic,assign)GLuint renderBuffer;

@property(nonatomic,assign)NSInteger viewWidth;

@property(nonatomic,assign)NSInteger viewHeight;

//================================================================rgb
@property(nonatomic,assign)GLuint texture;

@property(nonatomic,assign)GLuint mGLProgId;

@property(nonatomic,assign)GLuint mGLTextureCoords;

@property(nonatomic,assign)GLuint mGLPosition;

@property(nonatomic,assign)GLuint mGLUniformTexture;

//================================================================

@property(nonatomic,strong)dispatch_queue_t openglesQueue;

//================================================================yuv

@property(nonatomic,assign)GLuint ytexture;

@property(nonatomic,assign)GLuint utexture;

@property(nonatomic,assign)GLuint vtexture;


@property(nonatomic,assign)GLuint mYUVGLProgId;

@property(nonatomic,assign)GLuint mYUVGLTextureCoords;

@property(nonatomic,assign)GLuint mYUVGLPosition;

@property(nonatomic,assign)GLuint s_texture_y;

@property(nonatomic,assign)GLuint s_texture_u;

@property(nonatomic,assign)GLuint s_texture_v;

@property(nonatomic,strong)NSFileHandle* readFileHandle;

@property(nonatomic,weak)NSTimer* readTimer;
@end

@implementation TMSGLRenderView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupOPENGLES];
        [self setupYUVGPUProgram];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%@====%s",self,__FUNCTION__);

    [self destroy];
}

- (void)destroy {
    if(self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (self.mYUVGLProgId) {
        glDeleteProgram(self.mYUVGLProgId);
    }
    if (self.mGLProgId) {
        glDeleteProgram(self.mGLProgId);
    }
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
    }
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
    }
    if (_texture) {
        glDeleteTextures(1, &_texture);
    }
    if (_ytexture) {
        glDeleteTextures(1, &_ytexture);
    }
    if (_utexture) {
        glDeleteTextures(1, &_utexture);
    }
    if (_vtexture) {
        glDeleteTextures(1, &_vtexture);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    NSInteger width = self.frame.size.width;
    NSInteger height = self.frame.size.height;
    dispatch_sync(self.openglesQueue, ^{
        if (self.viewHeight != height || self.viewWidth != width) {
            //创建缓冲区buffer
            [self setupBuffers];
        }
    });
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupOPENGLES];
    [self setupYUVGPUProgram];
}

- (void)setupOPENGLES {
    self.openglesQueue = dispatch_queue_create("openglesqueue", DISPATCH_QUEUE_SERIAL);
    //设置layer属性
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    NSDictionary *dict = @{kEAGLDrawablePropertyRetainedBacking:@(NO),
                           kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
                           };

    [eaglLayer setDrawableProperties:dict];

    [eaglLayer setOpaque:YES];

    [eaglLayer setContentsScale:[[UIScreen mainScreen] scale]];
    //创建上下文
    [self setupContext];

}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (self.context == nil) {
        NSLog(@"create context failed!");
        return;
    }
    BOOL result = [EAGLContext setCurrentContext:self.context];
    if (result == NO) {
        NSLog(@"set context failed!");
    }
}

- (void)setupBuffers {
    //检测缓存区
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
    }
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
    }
    [EAGLContext setCurrentContext:self.context];
    //创建帧缓冲区
    glGenFramebuffers(1, &_frameBuffer);
    //绑定缓冲区
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);

    //创建绘制缓冲区
    glGenRenderbuffers(1, &_renderBuffer);
    //绑定缓冲区
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

    //为绘制缓冲区分配内存
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];

    //获取绘制缓冲区像素高度/宽度
    GLint width;
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    NSLog(@"%d==%d",width,height);
    self.viewWidth = width;
    self.viewHeight = height;
    //将绘制缓冲区绑定到帧缓冲区
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //检查状态
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete frame buffer object!");
        return;
    }
    GLenum glError = glGetError();
    if (GL_NO_ERROR != glError) {
        NSLog(@"failed to setup GL %x", glError);
    }
}

#pragma mark - 编译YUV_GPU程序
- (void)setupYUVGPUProgram {
    //编译顶点着色器、纹理着色器
    GLuint vertexShader = [self compileShaderWithName:@"vertex" type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:@"yuv_fragment" type:GL_FRAGMENT_SHADER];
    //绑定链接程序
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);

    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, &message[0]);
        NSString *messageStr = [NSString stringWithUTF8String:message];
        NSLog(@"messageStr:%@", messageStr);
        return;
    }
    //使用程序
    glUseProgram(programHandle);
    self.mYUVGLProgId = programHandle;
    //绑定变量
    _mYUVGLPosition = glGetAttribLocation(programHandle, "position");
    glEnableVertexAttribArray(_mYUVGLPosition);

    _mYUVGLTextureCoords = glGetAttribLocation(programHandle, "texcoord");
    glEnableVertexAttribArray(_mYUVGLTextureCoords);

    _s_texture_y = glGetUniformLocation(programHandle, "s_texture_y");
    _s_texture_u = glGetUniformLocation(programHandle, "s_texture_u");
    _s_texture_v = glGetUniformLocation(programHandle, "s_texture_v");

    glUniform1i(_s_texture_y, 0);
    glUniform1i(_s_texture_u, 1);
    glUniform1i(_s_texture_v, 2);

}

- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    
    GLuint shader = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shader);
    
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@", messageString);
        exit(1);
    }
    
    return shader;
}

#pragma mark - 创建纹理
- (void)displayWithFrame:(AVFrame *)yuvFrame {

    NSData *yData = copyFrameData(yuvFrame->data[0],
                                  yuvFrame->linesize[0],
                                  yuvFrame->width,
                                  yuvFrame->height);
    NSData *uData = copyFrameData(yuvFrame->data[1],
                                  yuvFrame->linesize[1],
                                  yuvFrame->width / 2,
                                  yuvFrame->height / 2);
    NSData *vData = copyFrameData(yuvFrame->data[2],
                                  yuvFrame->linesize[2],
                                  yuvFrame->width / 2,
                                  yuvFrame->height / 2);
    

    [self loadYUV420PDataWithYData:yData uData:uData vData:vData width:yuvFrame->width height:yuvFrame->height];
    
//    NSString *yuvFile = [[NSBundle mainBundle] pathForResource:@"yuv_1920_1080" ofType:nil];
//
//    [self showYUVDataWithRate:20
//                        width:1920
//                       height:1080
//                     filePath:yuvFile];
}

- (void)showYUVDataWithRate:(int)rate width:(int)width height:(int)height filePath:(NSString *)filePath {
    
    self.readFileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    
//    self.readTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / rate repeats:YES block:^(NSTimer * _Nonnull timer) {
//
//
//    }];
    unsigned long long  l =  [self.readFileHandle offsetInFile];
//    if (l >= fileSize) {
//        [timer invalidate];
//        [self.readFileHandle closeFile];
//        return ;
//    }
    NSData *yData = [self.readFileHandle readDataOfLength:width * height];
    NSData *uData = [self.readFileHandle readDataOfLength:width * height / 4];
    NSData *vData = [self.readFileHandle readDataOfLength:width * height / 4];
    
    [self loadYUV420PDataWithYData:yData uData:uData vData:vData width:width height:height];
    
}

- (void)createTexWithYUVDataWithYData:(NSData *)YData uData:(NSData *)uData vData:(NSData *)vData width:(int)width height:(int)height {

    void *ydata = (void *)[YData bytes];

    //传递纹理对象
    //创建纹理
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &_ytexture);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, _ytexture);
    [self createYUVTextureWithData:ydata width:width height:height texture:&_ytexture];
    //纹理过滤函数
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);//放大过滤
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);//缩小过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//水平方向
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//垂直方向

    void *udata = (void *)[uData bytes];
    //创建纹理
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_utexture);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, _utexture);
    [self createYUVTextureWithData:udata width:width / 2 height:height / 2 texture:&_utexture];
    //纹理过滤函数
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);//放大过滤
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);//缩小过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//水平方向
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//垂直方向

    void *vdata = (void *)[vData bytes];

    //创建纹理
    glActiveTexture(GL_TEXTURE2);
    glGenTextures(1, &_vtexture);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, _vtexture);
    [self createYUVTextureWithData:vdata width:width / 2 height:height / 2 texture:&_vtexture];
    //纹理过滤函数
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);//放大过滤
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);//缩小过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//水平方向
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//垂直方向
    if (!_ytexture || !_ytexture || !_vtexture)
    {
        NSLog(@"glGenTextures faild.");
        return;
    }
}

- (void)createYUVTextureWithData:(void *)data  width:(int)width height:(int)height  texture:(GLuint *)texture {

    //设置过滤参数
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    //设置映射规则
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);


    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width , height , 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);

}

- (void)loadYUV420PDataWithYData:(NSData *)yData uData:(NSData *)uData vData:(NSData *)vData width:(NSInteger)width height:(NSInteger)height {
    dispatch_sync(self.openglesQueue, ^{

        BOOL result = [EAGLContext setCurrentContext:self.context];
        if (result == NO) {
            NSLog(@"set context failed!");
        }
        if (self.ytexture) {
            glDeleteTextures(1, &_ytexture);
        }
        if (self.utexture) {
            glDeleteTextures(1, &_utexture);
        }
        if (self.vtexture) {
            glDeleteTextures(1, &_vtexture);
        }

        glClearColor(0, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        //创建纹理
        [self createTexWithYUVDataWithYData:yData uData:uData vData:vData width:(int)width height:(int)height];

        //调整画面宽度
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat w = 0;
        CGFloat h = 0;

        //获取控件宽高比，与视频宽高比
        if (self.viewWidth / self.viewHeight * 1.0 > width / height) {
            h = self.viewHeight;
            w = width * h / height;
            x = (self.viewWidth - w) / 2;
            glViewport(x, y, w, h);
        }else {
            w = self.viewWidth;
            h = height * w / width;
            y = (self.viewHeight - h) / 2;
            glViewport(x, y, w, h);
        }


        //设置物体坐标
        GLfloat vertices[] = {
            -1.0,-1.0,
            1.0,-1.0,
            -1.0,1.0,
            1.0,1.0
        };
//        glEnableVertexAttribArray(_mYUVGLPosition);
        glVertexAttribPointer(_mYUVGLPosition, 2, GL_FLOAT, 0, 0, vertices);
        //设置纹理坐标
        GLfloat texCoords2[] = {
            0,1,
            1,1,
            0,0,
            1,0
        };
//        glEnableVertexAttribArray(_mYUVGLTextureCoords);
        glVertexAttribPointer(_mYUVGLTextureCoords, 2, GL_FLOAT, 0, 0, texCoords2);
        //执行绘制操作
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        [self.context presentRenderbuffer:GL_RENDERBUFFER];

        //删除不使用纹理
        glDeleteTextures(1, &_ytexture);
        glDeleteTextures(1, &_utexture);
        glDeleteTextures(1, &_vtexture);
        //解绑纹理
        glBindTexture(GL_TEXTURE_2D, 0);

    });
}

@end

