//
//  TMSH264Encoder.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/7/14.
//

#import "TMSSoftH264Encoder.h"
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavutil/avstring.h>
#import <libavutil/imgutils.h>
#import <libavutil/error.h>
#import <libswscale/swscale.h>

static TMSSoftH264Encoder *encoderInstance = nil;

@interface TMSSoftH264Encoder ()
{
    AVFormatContext                     *pFormatCtx;
    AVOutputFormat                      *fmt;
    AVStream                            *video_st;
    AVCodecContext                      *pCodecCtx;
    AVCodec                             *pCodec;
    AVPacket                             pkt;
    uint8_t                             *picture_buf;
    AVFrame                             *pFrame;
    int                                  picture_size;
    int                                  y_size;
    int                                  framecnt;
    char                                *out_file;
    
    int                                  encoder_h264_frame_width; // 编码的图像宽度
    int                                  encoder_h264_frame_height; // 编码的图像高度
}
@end

@implementation TMSSoftH264Encoder

+ (instancetype)getInstance
{
    if (encoderInstance == NULL) {
        encoderInstance = [[TMSSoftH264Encoder alloc] init];
    }
    return encoderInstance;
}

- (void)setFileSavedPath:(NSString *)path
{
    NSUInteger len = [path length];
    char *filepath = (char*)malloc(sizeof(char) * (len + 1));
    [path getCString:filepath maxLength:len + 1 encoding:[NSString defaultCStringEncoding]];
    out_file = filepath;
}

/*
 *  设置X264
 */
- (int)setEncoderVideoWidth:(int)width height:(int)height bitrate:(int)bitrate
{
    // 1.默认从第0帧开始(记录当前的帧数)
    framecnt = 0;
    
    // 2.记录传入的宽度&高度
    encoder_h264_frame_width = width;
    encoder_h264_frame_height = height;
    
    // 4.初始化AVFormatContext: 用作之后写入视频帧并编码成 h264，贯穿整个工程当中(释放资源时需要销毁)
    pFormatCtx = avformat_alloc_context();
    
    // 5.设置输出文件的路径，fmt初始化的时候根据传入的参数猜出video_codec、mime_type、extensions等等信息。
    fmt = av_guess_format(NULL, out_file, NULL);
    pFormatCtx->oformat = fmt;
    
    // 6.打开文件的缓冲区输入输出，flags 标识为  AVIO_FLAG_READ_WRITE ，可读写
    if (avio_open(&pFormatCtx->pb, out_file, AVIO_FLAG_READ_WRITE) < 0){
        printf("Failed to open output file! \n");
    }
    
    // 7.创建新的输出流, 用于写入文件
    video_st = avformat_new_stream(pFormatCtx, 0);
    
    if (video_st==NULL){ printf("Failed to setup stream! \n"); return -1; }
    
    // 8.pCodecCtx 用户存储编码所需的参数格式等等
    // 8.1.从媒体流中获取到编码结构体，他们是一一对应的关系，一个 AVStream 对应一个  AVCodecContext
    AVCodec *codec = avcodec_find_encoder(pFormatCtx->oformat->video_codec);
    pCodecCtx = avcodec_alloc_context3(codec);
    
    // 8.2.设置编码器的编码格式(是一个id)，每一个编码器都对应着自己的 id，例如 h264 的编码 id 就是 AV_CODEC_ID_H264
    pCodecCtx->codec_id = fmt->video_codec;
    
    // 8.3.设置编码类型为 视频编码
    pCodecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
    
    // 8.4.设置像素格式为 yuv 格式
    pCodecCtx->pix_fmt = AV_PIX_FMT_YUV420P;
    
    // 8.5.设置视频的宽高
    pCodecCtx->width = encoder_h264_frame_width;
    pCodecCtx->height = encoder_h264_frame_height;
    
    // 8.6.设置帧率
    pCodecCtx->time_base.num = 1;
    pCodecCtx->time_base.den = 25;
    
    // 8.7.设置码率（比特率）
    pCodecCtx->bit_rate = bitrate;
    
    // 8.8.视频质量度量标准(常见qmin=10, qmax=51)
    pCodecCtx->qmin = 10;
    pCodecCtx->qmax = 51;
    
    // 8.9.设置图像组层的大小(GOP-->两个I帧之间的间隔)
    pCodecCtx->gop_size = 30;
    
    // 8.10.设置 B 帧最大的数量，B帧为视频图片空间的前后预测帧， B 帧相对于 I、P 帧来说，压缩率比较大，也就是说相同码率的情况下，
    // 越多 B 帧的视频，越清晰，现在很多打视频网站的高清视频，就是采用多编码 B 帧去提高清晰度，
    // 但同时对于编解码的复杂度比较高，比较消耗性能与时间
    pCodecCtx->max_b_frames = 5;
    
    // 9.可选设置
    AVDictionary *param = 0;
    // H.264
    if(pCodecCtx->codec_id == AV_CODEC_ID_H264) {
        // 通过--preset的参数调节编码速度和质量的平衡。
        av_dict_set(&param, "preset", "slow", 0);
        
        // 通过--tune的参数值指定片子的类型，是和视觉优化的参数，或有特别的情况。
        // zerolatency: 零延迟，用在需要非常低的延迟的情况下，比如视频直播的编码
        av_dict_set(&param, "tune", "zerolatency", 0);
    }
    
    // 10.输出打印信息，内部是通过printf函数输出（不需要输出可以注释掉）
    av_dump_format(pFormatCtx, 0, out_file, 1);
    
    // 11.通过 codec_id 找到对应的编码器
    pCodec = avcodec_find_encoder(pCodecCtx->codec_id);
    if (!pCodec) {
        printf("Can not find encoder! \n");
    }
    
    // 12.打开编码器，并设置参数 param
    if (avcodec_open2(pCodecCtx, pCodec,&param) < 0) {
        printf("Failed to open encoder! \n");
    }
    
    // 13.将AVCodecContext的成员复制到AVCodecParameters结构体
    avcodec_parameters_from_context(video_st->codecpar, pCodecCtx);
    
    // 14.真实帧率
    AVRational rational = {1, 25};
    av_stream_set_r_frame_rate(video_st, rational);
    
    // 15.初始化原始数据对象: AVFrame
    pFrame = av_frame_alloc();
    
    // 16.通过像素格式(这里为 YUV)获取图片的真实大小，例如将 480 * 720 转换成 int 类型
    av_image_fill_arrays(pFrame->data, pFrame->linesize, picture_buf, pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height, 1);
    
    // 17.h264 封装格式的文件头部，基本上每种编码都有着自己的格式的头部。
    if (avformat_write_header(pFormatCtx, NULL) < 0) { printf("Failed to write! \n"); return -1; }
    
    // 18.创建编码后的数据 AVPacket 结构体来存储 AVFrame 编码后生成的数据
    av_new_packet(&pkt, picture_size);
    
    // 19.设置 yuv 数据中 y 图的宽高
    y_size = pCodecCtx->width * pCodecCtx->height;
    
    return 0;
}

/*
 * 将CMSampleBufferRef格式的数据编码成h264并写入文件
 *
 */
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer
{
    // 1.通过CMSampleBufferRef对象获取CVPixelBufferRef对象
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // 2.锁定imageBuffer内存地址开始进行编码
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
        // 3.从CVPixelBufferRef读取YUV的值
        // NV12和NV21属于YUV格式，是一种two-plane模式，即Y和UV分为两个Plane，但是UV（CbCr）为交错存储，而不是分为三个plane
        // 3.1.获取Y分量的地址
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,0);
        // 3.2.获取UV分量的地址
        UInt8 *bufferPtr1 = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,1);
        
        // 3.3.根据像素获取图片的真实宽度&高度
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        // 获取Y分量长度
        size_t bytesrow0 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        size_t bytesrow1  = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,1);
        UInt8 *yuv420_data = (UInt8 *)malloc(width * height * 3 / 2);
        
        // 3.4.将NV12数据转成YUV420P(I420)数据
        UInt8 *pY = bufferPtr;
        UInt8 *pUV = bufferPtr1;
        UInt8 *pU = yuv420_data + width * height;
        UInt8 *pV = pU + width * height / 4;
        for(int i =0;i<height;i++)
        {
            memcpy(yuv420_data+i*width,pY+i*bytesrow0,width);
        }
        for(int j = 0;j<height/2;j++)
        {
            for(int i =0;i<width/2;i++)
            {
                *(pU++) = pUV[i<<1];
                *(pV++) = pUV[(i<<1) + 1];
            }
            pUV += bytesrow1;
        }
        
        // 3.5.分别读取YUV的数据
        picture_buf = yuv420_data;
        pFrame->data[0] = picture_buf;                   // Y
        pFrame->data[1] = picture_buf + y_size;          // U
        pFrame->data[2] = picture_buf + y_size * 5 / 4;  // V
        
        // 4.设置当前帧
        pFrame->pts = framecnt;
        
        // 4.设置宽度高度以及YUV格式
        pFrame->width = encoder_h264_frame_width;
        pFrame->height = encoder_h264_frame_height;
        pFrame->format = AV_PIX_FMT_YUV420P;
        
        // 5.对编码前的原始数据(AVFormat)利用编码器进行编码，将 pFrame 编码后的数据传入pkt 中
        int ret = avcodec_send_frame(pCodecCtx, pFrame);
        if (ret != 0) {
            printf("Failed to encode! \n");
            return;
        }
        
        while (avcodec_receive_packet(pCodecCtx, &pkt) == 0) {
            framecnt++;
            pkt.stream_index = video_st->index;
            //也可以使用C语言函数：fwrite()、fflush()写文件和清空文件写入缓冲区。
            ret = av_write_frame(pFormatCtx, &pkt);
            if (ret < 0) {
                printf("Failed write to file！\n");
            }
            //释放packet
            av_packet_unref(&pkt);
        }
        
        // 7.释放yuv数据
        free(yuv420_data);
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

/*
 * 释放资源
 */
- (void)freeH264Resource
{
    // 1.释放AVFormatContext
    int ret = [self flush_encoder];
    if (ret < 0) {
        printf("Flushing encoder failed\n");
    }
    
    // 1.将还未输出的AVPacket输出出来
    av_write_trailer(pFormatCtx);
    
    // 2.关闭资源
    avcodec_close(pCodecCtx);
    av_free(pFrame);
    
    avio_close(pFormatCtx->pb);
    avformat_free_context(pFormatCtx);
    
    NSLog(@"h264写入成功");
}

- (int)flush_encoder {
    
    int ret;
    AVPacket packet;
    if (pCodec->capabilities & AV_CODEC_CAP_DELAY) {
        return 0;
    }
    
    ret = avcodec_send_frame(pCodecCtx, NULL);
    if (ret < 0) {
        return ret;
    }
    while (true) {
        packet.data = NULL;
        packet.size = 0;
        ret = avcodec_receive_packet(pCodecCtx, &packet);
        if (ret < 0) {
            break;
        }
        av_packet_unref(&packet);
    }
    
    return ret;
}

@end
