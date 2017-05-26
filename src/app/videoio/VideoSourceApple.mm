#include "VideoSourceApple.h"

#import "MIMovieVideoSampleAccessor.h"
#import "MICMSampleBuffer.h"

#import <CoreVideo/CVPixelBuffer.h>

#include "drishti/core/make_unique.h"

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>

#include <iomanip>

class VideoSourceApple::Impl
{
public:
    Impl(const std::string &filename) : filename(filename)
    {

    }

    ~Impl()
    {
        
    }

    void init()
    {
        NSString *path = [NSString stringWithUTF8String:filename.c_str()];
        NSURL *url = [NSURL fileURLWithPath:path];
    
        NSError *err;
        if ([url checkResourceIsReachableAndReturnError:&err] == NO)
        {
            NSLog(@"Not reachable!");
        }
    
        AVURLAsset *videoAsset = [AVURLAsset assetWithURL:url];
        sampleAccessor = [[MIMovieVideoSampleAccessor alloc] initWithMovie:videoAsset firstSampleTime:kCMTimeZero];
    }

    cv::Mat operator()(int i)
    {
        cv::Mat image; // BGR
        
        if(MICMSampleBuffer *sample = [sampleAccessor nextSampleBuffer])
        {
            CMSampleBufferRef buffer = [sample CMSampleBuffer];
            CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
            
            // Begin processing:
            CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
            
            //int format = CVPixelBufferGetPixelFormatType(pixelBuffer);
            
            int cols = CVPixelBufferGetWidth(pixelBuffer);
            int rows = CVPixelBufferGetHeight(pixelBuffer);
            unsigned char *pixels = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
            cv::Mat argb(rows, cols, CV_8UC4, pixels);
            
            switch(m_format)
            {
                case VideoSourceCV::ANY:
                case VideoSourceCV::ARGB:
                {
                    image = argb;
                    break;
                }
                case VideoSourceCV::BGR:
                {
                    cv::Mat bgra(rows, cols, CV_8UC4);
                    cv::mixChannels(argb, bgra, {0,3, 1,2, 2,1, 3,0 });
                    cv::cvtColor(bgra, image, cv::COLOR_BGRA2BGR);
                    break;
                }
                default:
                    CV_Assert(false);
                    break;
            }
            
            //End processing
            CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
        }

        return m_frame = image;
    }
    
    void setOutputFormat(VideoSourceCV::PixelFormat format) { m_format = format; }
    
    bool good() const { return !m_frame.empty(); }
    
    cv::Mat m_frame; // assume sequential access
    VideoSourceCV::PixelFormat m_format = VideoSourceCV::ANY;
    MIMovieVideoSampleAccessor *sampleAccessor;
    std::string filename;
};

VideoSourceApple::VideoSourceApple(const std::string &filename)
{
    m_impl = drishti::core::make_unique<Impl>(filename);
    m_impl->init();
}

VideoSourceApple::~VideoSourceApple()
{
    
}

VideoSourceCV::Frame VideoSourceApple::operator()(int i)
{
    std::stringstream ss;
    ss << std::setw(4) << std::setfill('0') << i;
    return Frame((*m_impl)(i), i, ss.str());
}

bool VideoSourceApple::good() const
{
    return m_impl->good();
}

std::size_t VideoSourceApple::count() const
{
    // TODO?
    return static_cast<std::size_t>(std::numeric_limits<int>::max());
}

void VideoSourceApple::setOutputFormat(VideoSourceCV::PixelFormat format)
{
    m_impl->setOutputFormat(format);
}
