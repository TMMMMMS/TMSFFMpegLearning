//
//  TMSMuxingViewController.m
//  FFMpegTest
//
//  Created by santian_mac on 2021/8/31.
//

#import "TMSMuxingViewController.h"
#import <libavformat/avformat.h>

@interface TMSMuxingViewController ()
{
    AVFormatContext *ifmt_ctx_v;
    AVFormatContext *ifmt_ctx_a;
    AVFormatContext *ofmt_ctx;
    
    AVOutputFormat *ofmt;
    
    AVPacket pkt;
}
@end

@implementation TMSMuxingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self muxingVideo];
}

- (void)muxingVideo {
    
    int ret;
    
    int videoindex_v = -1, videoindex_out = -1;
    int audioindex_a = -1, audioindex_out = -1;
    
    int frame_index = 0;
    
    int64_t cur_pts_v = 0, cur_pts_a = 0;
    int writing_v = 1, writing_a = 1;
    
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"h264"];
    if (videoPath.length == 0) {
        printf("Could not find video file");
        return;
    }
    
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"aac"];
    if (audioPath.length == 0) {
        printf("Could not find audio file");
        return;
    }
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"muxing"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:documentPath]) {
        [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fullFileName = @"abc.flv";
    NSString *outputPath = [documentPath stringByAppendingPathComponent:fullFileName];
    
    if ((ret = avformat_open_input(&ifmt_ctx_v, [videoPath UTF8String], NULL, NULL)) < 0) {
        printf("Could not open input file.");
        goto end;
    }
    
    if ((ret = avformat_find_stream_info(ifmt_ctx_v, NULL)) < 0) {
        printf("Failed to retrieve input stream information");
        goto end;
    }
    
    if ((ret = avformat_open_input(&ifmt_ctx_a, [audioPath UTF8String], NULL, NULL)) < 0) {
        printf("Could not open input file.");
        goto end;
    }
    
    if ((ret = avformat_find_stream_info(ifmt_ctx_a, NULL)) < 0) {
        printf("Failed to retrieve input stream information");
        goto end;
    }
    
    //Output
    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, [outputPath UTF8String]);
    if (!ofmt_ctx) {
        printf("Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    ofmt = ofmt_ctx->oformat;
    
    for (int i = 0; i < ifmt_ctx_v->nb_streams; i++) {

        //Create output AVStream according to input AVStream
        AVStream *in_stream = ifmt_ctx_v->streams[i];
        enum AVMediaType mediaType = in_stream->codecpar->codec_type;

        if(mediaType == AVMEDIA_TYPE_VIDEO) {

            AVCodec *codec = avcodec_find_decoder(in_stream->codecpar->codec_id);
            AVStream *out_stream = avformat_new_stream(ofmt_ctx, codec);
            
            videoindex_v = i;
            
            if (!out_stream) {
                printf("Failed allocating output stream\n");
                ret = AVERROR_UNKNOWN;
                goto end;
            }
            videoindex_out = out_stream->index;

            //Copy the settings of AVCodecContext
            AVCodecContext *codec_ctx = avcodec_alloc_context3(codec);
            if ((ret = avcodec_parameters_to_context(codec_ctx, in_stream->codecpar)) < 0) {
                printf("Failed to copy in_stream to codec context\n");
                goto end;
            }

            codec_ctx->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER) {
                codec_ctx->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
            }

            if ((ret = avcodec_parameters_from_context(out_stream->codecpar, codec_ctx)) < 0) {
                printf("Failed to copy codec context to out_stream codecpar context\n");
                goto end;
            }

            break;
        }
    }
    
    for (int i = 0; i < ifmt_ctx_a->nb_streams; i++) {

        //Create output AVStream according to input AVStream
        AVStream *in_stream = ifmt_ctx_a->streams[i];
        enum AVMediaType mediaType = in_stream->codecpar->codec_type;

        if(mediaType == AVMEDIA_TYPE_AUDIO) {

            AVCodec *codec = avcodec_find_decoder(in_stream->codecpar->codec_id);
            AVStream *out_stream = avformat_new_stream(ofmt_ctx, codec);
            
            audioindex_a = i;
            
            if (!out_stream) {
                printf("Failed allocating output stream\n");
                ret = AVERROR_UNKNOWN;
                goto end;
            }
            audioindex_out = out_stream->index;

            //Copy the settings of AVCodecContext
            AVCodecContext *codec_ctx = avcodec_alloc_context3(codec);
            if ((ret = avcodec_parameters_to_context(codec_ctx, in_stream->codecpar)) < 0) {
                printf("Failed to copy in_stream to codec context\n");
                goto end;
            }

            codec_ctx->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER) {
                codec_ctx->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
            }

            if ((ret = avcodec_parameters_from_context(out_stream->codecpar, codec_ctx)) < 0) {
                printf("Failed to copy codec context to out_stream codecpar context\n");
                goto end;
            }

            break;
        }
    }
    
    /* open the output file, if needed */
    if (!(ofmt->flags & AVFMT_NOFILE)) {
        if ((ret = avio_open(&ofmt_ctx->pb, [outputPath UTF8String], AVIO_FLAG_WRITE)) < 0) {
            fprintf(stderr, "Could not open '%s': %s\n", [outputPath UTF8String],
                    av_err2str(ret));
            goto end;
        }
    }
    
    //Write file header
    if ((ret = avformat_write_header(ofmt_ctx, NULL)) < 0) {
        fprintf(stderr, "Error occurred when opening output file: %s\n",
                av_err2str(ret));
        goto end;
    }
    
    NSLog(@"video_index:%d, audio_index:%d", videoindex_out, audioindex_out);
    
    while (writing_v || writing_a) {
        AVFormatContext *ifmt_ctx;
        int stream_index = 0;
        AVStream *in_stream, *out_stream;
        // 比较音视频pts，大于0表示视频帧在前，音频需要连续编码。小于0表示，音频帧在前，应该至少编码一帧视频
        if (writing_v && (!writing_a || av_compare_ts(cur_pts_v, ifmt_ctx_v->streams[videoindex_v]->time_base,
                                                      cur_pts_a, ifmt_ctx_a->streams[audioindex_a]->time_base) <= 0)) {
            ifmt_ctx = ifmt_ctx_v;
            stream_index = videoindex_out;
            if (av_read_frame(ifmt_ctx, &pkt) >= 0) {
                do {
                    in_stream = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if (pkt.stream_index == videoindex_v) {
                        //Simple Write PTS
                        if (pkt.pts == AV_NOPTS_VALUE) {
                            //Write PTS
                            AVRational time_base1 = in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration = (double) AV_TIME_BASE / av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts = (double) (frame_index * calc_duration) /
                            (double) (av_q2d(time_base1) * AV_TIME_BASE);
                            pkt.dts = pkt.pts;
                            pkt.duration = (double) calc_duration / (double) (av_q2d(time_base1) * AV_TIME_BASE);
                            frame_index++;
                        }
                        
                        cur_pts_v = pkt.pts;
                        break;
                    }
                } while (av_read_frame(ifmt_ctx, &pkt) >= 0);
            } else {
                writing_v = 0;
                continue;
            }
        } else {
            ifmt_ctx = ifmt_ctx_a;
            stream_index = audioindex_out;
            if (av_read_frame(ifmt_ctx, &pkt) >= 0) {
                do {
                    in_stream = ifmt_ctx->streams[pkt.stream_index];
                    out_stream = ofmt_ctx->streams[stream_index];
                    
                    if (pkt.stream_index == audioindex_a) {
                        
                        //Simple Write PTS
                        if (pkt.pts == AV_NOPTS_VALUE) {
                            //Write PTS
                            AVRational time_base1 = in_stream->time_base;
                            //Duration between 2 frames (us)
                            int64_t calc_duration = (double) AV_TIME_BASE / av_q2d(in_stream->r_frame_rate);
                            //Parameters
                            pkt.pts = (double) (frame_index * calc_duration) /
                            (double) (av_q2d(time_base1) * AV_TIME_BASE);
                            pkt.dts = pkt.pts;
                            pkt.duration = (double) calc_duration / (double) (av_q2d(time_base1) * AV_TIME_BASE);
                            frame_index++;
                        }
                        cur_pts_a = pkt.pts;
                        break;
                    }
                } while (av_read_frame(ifmt_ctx, &pkt) >= 0);
            } else {
                writing_a = 0;
                continue;
            }
        }
        
        //Convert PTS/DTS
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
        pkt.duration = av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        pkt.stream_index = stream_index;
        
        printf("Write 1 Packet. size:%5d\tpts:%lld\tstream_index:%d\n", pkt.size, pkt.pts, pkt.stream_index);
        //Write
        if (av_interleaved_write_frame(ofmt_ctx, &pkt) < 0) {
            printf("Error muxing packet\n");
            break;
        }
        av_packet_unref(&pkt);
    }
    
    printf("Write file trailer.\n");
    
    //Write file trailer
    av_write_trailer(ofmt_ctx);
    
end:
    avformat_close_input(&ifmt_ctx_v);
    avformat_close_input(&ifmt_ctx_a);
    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_close(ofmt_ctx->pb);
    avformat_free_context(ofmt_ctx);
    if (ret < 0 && ret != AVERROR_EOF) {
        printf("Error occurred.\n");
    }
}

@end
