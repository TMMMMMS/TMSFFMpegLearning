//
//  TMSAudioInformation.h
//  FFMpegTest
//
//  Created by TmmmS on 2021/7/6.
//

#ifndef TMSAudioInformation_h
#define TMSAudioInformation_h
#include <libavformat/avformat.h>

/// 播放器参数
struct TMSAudioInformation {
    /// 解码后一个完整的数据包字节数
    int buffer_size;
    /// 采样数据格式
    enum AVSampleFormat format;
    /// 采样率
    int rate;
    /// 通道
    int channels;
    /// 一个采样每个通道占的位宽
    int bitsPerChannel;
    /// 一个采样的字节数
    int bytesPerSample;
};

#endif /* TMSAudioInformation_h */
