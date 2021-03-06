//
//  TMSGLRenderView.m
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/10.
//

#import "TMSGLRenderView.h"
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>

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
            //???????????????buffer
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
    //??????layer??????
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    NSDictionary *dict = @{kEAGLDrawablePropertyRetainedBacking:@(NO),
                           kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
                           };

    [eaglLayer setDrawableProperties:dict];

    [eaglLayer setOpaque:YES];

    [eaglLayer setContentsScale:[[UIScreen mainScreen] scale]];
    //???????????????
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
    //???????????????
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
    }
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
    }
    [EAGLContext setCurrentContext:self.context];
    //??????????????????
    glGenFramebuffers(1, &_frameBuffer);
    //???????????????
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);

    //?????????????????????
    glGenRenderbuffers(1, &_renderBuffer);
    //???????????????
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

    //??????????????????????????????
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];

    //?????????????????????????????????/??????
    GLint width;
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    NSLog(@"%d==%d",width,height);
    self.viewWidth = width;
    self.viewHeight = height;
    //???????????????????????????????????????
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //????????????
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

#pragma mark - ??????YUV_GPU??????
- (void)setupYUVGPUProgram {
    //???????????????????????????????????????
    GLuint vertexShader = [self compileShaderWithName:@"vertex" type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:@"yuv_fragment" type:GL_FRAGMENT_SHADER];
    //??????????????????
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
    //????????????
    glUseProgram(programHandle);
    self.mYUVGLProgId = programHandle;
    //????????????
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
        NSAssert(NO, @"??????shader??????");
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
        NSAssert(NO, @"shader???????????????%@", messageString);
        exit(1);
    }
    
    return shader;
}

#pragma mark - ????????????
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
}

- (void)createTexWithYUVDataWithYData:(NSData *)YData uData:(NSData *)uData vData:(NSData *)vData width:(int)width height:(int)height {

    void *ydata = (void *)[YData bytes];

    //??????????????????
    //????????????
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &_ytexture);
    //????????????
    glBindTexture(GL_TEXTURE_2D, _ytexture);
    [self createYUVTextureWithData:ydata width:width height:height texture:&_ytexture];
    //??????????????????
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);//????????????
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);//????????????
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//????????????
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//????????????

    void *udata = (void *)[uData bytes];
    //????????????
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_utexture);
    //????????????
    glBindTexture(GL_TEXTURE_2D, _utexture);
    [self createYUVTextureWithData:udata width:width / 2 height:height / 2 texture:&_utexture];
    //??????????????????
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);//????????????
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);//????????????
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//????????????
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//????????????

    void *vdata = (void *)[vData bytes];

    //????????????
    glActiveTexture(GL_TEXTURE2);
    glGenTextures(1, &_vtexture);
    //????????????
    glBindTexture(GL_TEXTURE_2D, _vtexture);
    [self createYUVTextureWithData:vdata width:width / 2 height:height / 2 texture:&_vtexture];
    //??????????????????
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);//????????????
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);//????????????
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//????????????
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//????????????
    if (!_ytexture || !_ytexture || !_vtexture)
    {
        NSLog(@"glGenTextures faild.");
        return;
    }
}

- (void)createYUVTextureWithData:(void *)data  width:(int)width height:(int)height  texture:(GLuint *)texture {

    //??????????????????
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    //??????????????????
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

        //????????????
        [self createTexWithYUVDataWithYData:yData uData:uData vData:vData width:(int)width height:(int)height];

        //??????????????????
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat w = 0;
        CGFloat h = 0;

        //??????????????????????????????????????????
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


        //??????????????????
        GLfloat vertices[] = {
            -1.0,-1.0,
            1.0,-1.0,
            -1.0,1.0,
            1.0,1.0
        };
//        glEnableVertexAttribArray(_mYUVGLPosition);
        glVertexAttribPointer(_mYUVGLPosition, 2, GL_FLOAT, 0, 0, vertices);
        //??????????????????
        GLfloat texCoords2[] = {
            0,1,
            1,1,
            0,0,
            1,0
        };
//        glEnableVertexAttribArray(_mYUVGLTextureCoords);
        glVertexAttribPointer(_mYUVGLTextureCoords, 2, GL_FLOAT, 0, 0, texCoords2);
        //??????????????????
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        [self.context presentRenderbuffer:GL_RENDERBUFFER];

        //?????????????????????
        glDeleteTextures(1, &_ytexture);
        glDeleteTextures(1, &_utexture);
        glDeleteTextures(1, &_vtexture);
        //????????????
        glBindTexture(GL_TEXTURE_2D, 0);

    });
}

@end

