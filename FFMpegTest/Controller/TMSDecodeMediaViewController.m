//
//  TMSDecodeMediaViewController.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/8/19.
//

#import "TMSDecodeMediaViewController.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <libavutil/imgutils.h>
#import <libswresample/swresample.h>

@interface TMSDecodeMediaViewController ()
@property (nonatomic, assign) TMSDecodeMediaType decodeType;
@end

@implementation TMSDecodeMediaViewController

- (instancetype)initWithDecodeMediaType:(TMSDecodeMediaType)decodeType {
    
    if (self == [super init]) {
        self.decodeType = decodeType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flutter" ofType:@"mp4"];
    
    if (self.decodeType == TMSDecodeVideoMediaType) {
        NSString *outPath = [NSString stringWithFormat:@"/Users/mahua/Desktop/test.yuv"];
        [self ffpmegDecodeVideoInPath:filePath outPath:outPath];
    } else {
        NSString *pcmPath = [NSString stringWithFormat:@"/Users/mahua/Desktop/test.pcm"];
        [self ffpmegDecodeAudioInPath:filePath outPath:pcmPath];
    }
    
}

- (void)ffpmegDecodeVideoInPath:(NSString *)inPath outPath:(NSString *)outPath{

    /*解码步骤
     1.注册组件(av_register_all());
     2.打开封装格式。也就是打开文件。
     3.查找视频流(视频中包含视频流,音频流，字幕流)
     4.查找解码器
     5.打开解码器
     6.循环每一帧，去解码
     7.解码完成，关闭资源

     */
    int operationResult = 0;

    //第二步:打开文件
    AVFormatContext *avformat_context = avformat_alloc_context();
    const char *url = [inPath UTF8String];
    operationResult = avformat_open_input(&avformat_context, url, NULL, NULL);   //avformatcontext传的是二级指针（可以复习下二级指针的知识)
    if(operationResult != 0){
        //        av_log(NULL, 1, "打开文件失败");
        //nslog(@"打开文件失败");
        return;
    }

    //第三步:查找视频流
     operationResult = avformat_find_stream_info(avformat_context, NULL);
    if(operationResult != 0){
//        av_log(NULL, 1, "查找视频流失败");
        //nslog(@"查找视频流失败");
        return;
    }

    /* 第四步:查找解码器
       * 查找视频流的index
       * 根据视频流的index获取到avCodecContext
       * 根据avCodecContext获取解码器
     */
    int streamIndex = -1;
    for (int i = 0 ; i < avformat_context->nb_streams; i++){
        if(avformat_context -> streams[i] -> codecpar -> codec_type == AVMEDIA_TYPE_VIDEO){
            streamIndex = i;   //拿到视频流的index
            //nslog(@"获取到了视频流");
            break;
        }
    }
    AVCodecParameters *codecParameters = avformat_context -> streams[streamIndex]->codecpar;
    //根据解码器上下文拿到解码器id ,然后得到解码器
    AVCodec *decodeCodec = avcodec_find_decoder(codecParameters->codec_id);
    //根据视频流的index拿到解码器上下文
    AVCodecContext *avcodec_context = avcodec_alloc_context3(decodeCodec);

    //nslog(@"解码器为%s",decodeCodec -> name);
    //第五步:打开解码器
    operationResult = avcodec_open2(avcodec_context, decodeCodec, NULL);
    if(operationResult != 0){
        //        av_log(NULL, 1, "打开解码器失败");
        //nslog(@"打开解码器失败");
        return;
    }

    //第六步:开始解码
    //结构体大小计算：字节对齐原则
    AVPacket *packet = (AVPacket *)av_malloc(sizeof(AVPacket));
    //开辟一块内存空间
    AVFrame *avframe_in = av_frame_alloc();

    //创建一个yuv420视频像素数据格式缓冲区(一帧数据)
    AVFrame *avframe_yuv420 = av_frame_alloc();
    //给缓冲区设置类型->yuv420类型
    //得到YUV420P缓冲区大小
    //参数一：视频像素数据格式类型->YUV420P格式
    //参数二：一帧视频像素数据宽 = 视频宽
    //参数三：一帧视频像素数据高 = 视频高
    //参数四：字节对齐方式->默认是1
    int bufferSize = av_image_get_buffer_size(AV_PIX_FMT_YUV420P, avcodec_context -> width, avcodec_context -> height, 1);
    //开辟一块内存空间
    uint8_t *data = (uint8_t *)av_malloc(bufferSize);
    //向avframe_yuv420p->填充数据
    //参数一：目标->填充数据(avframe_yuv420p)
    //参数二：目标->每一行大小
    //参数三：原始数据
    //参数四：目标->格式类型
    //参数五：宽
    //参数六：高
    //参数七：字节对齐方式
    av_image_fill_arrays(avframe_yuv420 -> data,
                         avframe_yuv420 -> linesize,
                         data, AV_PIX_FMT_YUV420P,
                         avcodec_context -> width,
                         avcodec_context -> height,
                         1);


    //拿到格式转换上下文
    //4、注意：在这里我们不能够保证解码出来的一帧视频像素数据格式是yuv格式
    //参数一：源文件->原始视频像素数据格式宽
    //参数二：源文件->原始视频像素数据格式高
    //参数三：源文件->原始视频像素数据格式类型
    //参数四：目标文件->目标视频像素数据格式宽
    //参数五：目标文件->目标视频像素数据格式高
    //参数六：目标文件->目标视频像素数据格式类型
    struct SwsContext *sws_context = sws_getContext(avcodec_context -> width,
                                             avcodec_context -> height,
                                             avcodec_context -> pix_fmt,
                                             avcodec_context -> width,
                                             avcodec_context -> height,
                                             AV_PIX_FMT_YUV420P,
                                             SWS_BICUBIC,
                                             NULL,
                                             NULL,
                                             NULL);


    int y_size,u_size,v_size;

    long decodeIndex = 0;

    const char *outpath = [outPath UTF8String];
    FILE *yuv420p_file = fopen(outpath, "wb+");
    if (yuv420p_file == NULL){
        //nslog(@"输出文件打开失败");
        return;
    }

    while (av_read_frame(avformat_context, packet) == 0) {
        if(packet -> stream_index == streamIndex){  //如果是视频流
            avcodec_send_packet(avcodec_context, packet);

            operationResult = avcodec_receive_frame(avcodec_context, avframe_in);
            if(operationResult == 0){   //解码成功
                switch (avframe_in->pict_type) {
                    case AV_PICTURE_TYPE_I:
                        //nslog(@"I帧");
                        break;
                    case AV_PICTURE_TYPE_P:
                        //nslog(@"P帧");
                        break;
                    case AV_PICTURE_TYPE_B:
                        //nslog(@"B帧");
                        break;
                    default:
                        break;
                }

                //进行类型转换:将解码出来的原像素数据转成我们需要的yuv420格式
                //4、注意：在这里我们不能够保证解码出来的一帧视频像素数据格式是yuv格式
                //视频像素数据格式很多种类型: yuv420P、yuv422p、yuv444p等等...
                //保证：我的解码后的视频像素数据格式统一为yuv420P->通用的格式
                //进行类型转换: 将解码出来的视频像素点数据格式->统一转类型为yuv420P

                //sws_scale作用：进行类型转换的
                //参数一：视频像素数据格式上下文
                //参数二：原来的视频像素数据格式->输入数据
                //参数三：原来的视频像素数据格式->输入画面每一行大小
                //参数四：原来的视频像素数据格式->输入画面每一行开始位置(填写：0->表示从原点开始读取)
                //参数五：原来的视频像素数据格式->输入数据行数
                //参数六：转换类型后视频像素数据格式->输出数据
                //参数七：转换类型后视频像素数据格式->输出画面每一行大小
                sws_scale(sws_context, (const uint8_t *const *)avframe_in->data, avframe_in ->linesize, 0, avcodec_context -> height, avframe_yuv420 -> data, avframe_yuv420 -> linesize);

                //格式已经转换完成，写入yuv420p文件到本地.
                //  YUV: Y代表亮度,UV代表色度
                // YUV420格式知识: 一个Y代表一个像素点,4个像素点对应一个U和V.  4*Y = U = V
                y_size = avcodec_context -> width * avcodec_context -> height;
                u_size = y_size / 4;
                v_size = y_size / 4;

                //依次写入Y、U、V部分
                fwrite(avframe_yuv420 -> data[0], 1, y_size, yuv420p_file);
                fwrite(avframe_yuv420 -> data[1], 1, u_size, yuv420p_file);
                fwrite(avframe_yuv420 -> data[2], 1, v_size, yuv420p_file);

                decodeIndex++;
                //                av_log(NULL, 1, "解码到第%ld帧了",decodeIndex);
                //nslog(@"解码到第%ld帧了",decodeIndex);
            }
        }
    }

    //第七步:关闭资源
    av_packet_free(&packet);
    fclose(yuv420p_file);
    av_frame_free(&avframe_in);
    av_frame_free(&avframe_yuv420);
    free(data);
    avcodec_close(avcodec_context);
    avformat_free_context(avformat_context);
    //nslog(@"视频解码完成");
}

- (void)ffpmegDecodeAudioInPath:(NSString *)inPath outPath:(NSString *)outPath {
    
    //第一步：组册组件
    //第二步：打开封装格式->打开文件
    //参数一：封装格式上下文
    //作用：保存整个视频信息(解码器、编码器等等...)
    //信息：码率、帧率等...
    AVFormatContext *avformat_context = avformat_alloc_context();
    
    //参数二：视频路径
    const char *url = [inPath UTF8String];
    
    //参数三：指定输入的格式
    
    //参数四：设置默认参数
    int avformat_open_input_result = avformat_open_input(&avformat_context, url,NULL, NULL);
    if (avformat_open_input_result !=0){
        NSLog(@"打开文件失败");
        return;
    }
    
    //第三步：拿到视频基本信息
    
    //参数一：封装格式上下文
    
    //参数二：指定默认配置
    
    int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context,NULL);
    if (avformat_find_stream_info_result < 0){
        NSLog(@"查找失败");
        return;
    }
    
    //第四步：查找音频解码器
    //第一点：查找音频流索引位置
    int streamIndex = -1;
    
    for (int i =0; i < avformat_context->nb_streams; ++i) {
        
        //判断是否是音频流
        if (avformat_context -> streams[i] -> codecpar -> codec_type == AVMEDIA_TYPE_AUDIO){
            
            streamIndex = i;
            break;
        }
    }
    
    //第二点：获取音频解码器上下文
    AVCodecParameters *codecParameters = avformat_context -> streams[streamIndex]->codecpar;
    //根据解码器上下文拿到解码器id ,然后得到解码器
    AVCodec *decodeCodec = avcodec_find_decoder(codecParameters->codec_id);
    //根据视频流的index拿到解码器上下文
    AVCodecContext *avcodec_context = avcodec_alloc_context3(decodeCodec);
    
    //第三点：获得音频解码器
    AVCodec *avcodec = avcodec_find_decoder(avcodec_context->codec_id);
    
    if (avcodec ==NULL){
        
        NSLog(@"查找音频解码器失败");
        return;
    }
    
    //第五步：打开音频解码器
    int avcodec_open2_result = avcodec_open2(avcodec_context, avcodec,NULL);
    
    if (avcodec_open2_result !=0){
        
        NSLog(@"打开音频解码器失败");
        return;
    }
    
    //第六步：读取音频压缩数据->循环读取
    
    //创建音频压缩数据帧
    
    //音频压缩数据->acc格式、mp3格式
    AVPacket* avpacket = (AVPacket*)av_malloc(sizeof(AVPacket));
    
    //创建音频采样数据帧
    AVFrame* avframe = av_frame_alloc();
    
    //音频采样上下文->开辟了一快内存空间->pcm格式等...
    //设置参数
    //参数一：音频采样数据上下文
    //上下文：保存音频信息(记录)->目录
    SwrContext* swr_context = swr_alloc();
    
    //参数二：out_ch_layout->输出声道布局类型(立体声、环绕声、机器人等等...)
    //立体声
    int64_t out_ch_layout = AV_CH_LAYOUT_STEREO;
    
    //    int out_ch_layout = av_get_default_channel_layout(avcodec_context->channels);
    
    //参数三：out_sample_fmt->输出采样精度->编码
    
    //直接指定
    int out_sample_fmt = AV_SAMPLE_FMT_S16;
    
    //例如：采样精度8位 = 1字节，采样精度16位 = 2字节
    
    //参数四：out_sample_rate->输出采样率(44100HZ)
    int out_sample_rate = avcodec_context->sample_rate;
    
    //参数五：in_ch_layout->输入声道布局类型
    int64_t in_ch_layout = av_get_default_channel_layout(avcodec_context->channels);
    
    //参数六：in_sample_fmt->输入采样精度
    enum AVSampleFormat in_sample_fmt = avcodec_context->sample_fmt;
    
    //参数七：in_sample_rate->输入采样率
    int in_sample_rate = avcodec_context->sample_rate;
    
    //参数八：log_offset->log日志->从那里开始统计
    int log_offset =0;
    
    //参数九：log_ctx->log上下文
    swr_alloc_set_opts(swr_context,
                       out_ch_layout,
                       out_sample_fmt,
                       out_sample_rate,
                       in_ch_layout,
                       in_sample_fmt,
                       in_sample_rate,
                       log_offset,
                       NULL);
    
    //初始化音频采样数据上下文
    swr_init(swr_context);
    
    //输出音频采样数据
    //缓冲区大小 = 采样率(44100HZ) * 采样精度(16位 = 2字节)
    int MAX_AUDIO_SIZE =44100 * 2;
    
    uint8_t *out_buffer = (uint8_t *)av_malloc(MAX_AUDIO_SIZE);
    
    //输出声道数量
    int out_nb_channels = av_get_channel_layout_nb_channels(out_ch_layout);
    
    int audio_decode_result =0;
    
    //打开文件
    const char *coutFilePath = [outPath UTF8String];
    
    FILE* out_file_pcm = fopen(coutFilePath,"wb");
    
    if (out_file_pcm == NULL){
        NSLog(@"打开音频输出文件失败");
        return;
    }
    
    int current_index =0;
    //计算：4分钟一首歌曲 = 240ms = 4MB
    //现在音频时间：24ms->pcm格式->8.48MB
    //如果是一首4分钟歌曲->pcm格式->85MB
    
    while (av_read_frame(avformat_context, avpacket) >=0){
        
        //读取一帧音频压缩数据成功
        //判定是否是音频流
        if (avpacket->stream_index == streamIndex){
            
            //第七步：音频解码
            //1、发送一帧音频压缩数据包->音频压缩数据帧
            avcodec_send_packet(avcodec_context, avpacket);
            
            //2、解码一帧音频压缩数据包->得到->一帧音频采样数据->音频采样数据帧
            audio_decode_result = avcodec_receive_frame(avcodec_context, avframe);
            
            if (audio_decode_result == 0){
                
                //表示音频压缩数据解码成功
                //3、类型转换(音频采样数据格式有很多种类型)
                //我希望我们的音频采样数据格式->pcm格式->保证格式统一->输出PCM格式文件
                
                //swr_convert:表示音频采样数据类型格式转换器
                //参数一：音频采样数据上下文
                //参数二：输出音频采样数据
                //参数三：输出音频采样数据->大小
                //参数四：输入音频采样数据
                //参数五：输入音频采样数据->大小
                swr_convert(swr_context,
                            &out_buffer,
                            MAX_AUDIO_SIZE,
                            (const uint8_t **)avframe->data,
                            avframe->nb_samples);
                
                //4、获取缓冲区实际存储大小
                //参数一：行大小
                //参数二：输出声道数量
                //参数三：输入大小
                
                int nb_samples = avframe->nb_samples;
                
                //参数四：输出音频采样数据格式
                
                //参数五：字节对齐方式
                int out_buffer_size = av_samples_get_buffer_size(NULL,
                                                                 out_nb_channels,
                                                                 nb_samples,
                                                                 out_sample_fmt,
                                                                 1);
                
                //5、写入文件(你知道要写多少吗？)
                fwrite(out_buffer,1, out_buffer_size, out_file_pcm);
                
                current_index++;
                
                NSLog(@"当前音频解码第%d帧", current_index);
                
            }
        }
    }
    
    //第八步：释放内存资源，关闭音频解码器
    
    fclose(out_file_pcm);
    
    av_packet_free(&avpacket);
    
    swr_free(&swr_context);
    
    av_free(out_buffer);
    
    av_frame_free(&avframe);
    
    avcodec_close(avcodec_context);
    
    avformat_close_input(&avformat_context);
    
}

@end
