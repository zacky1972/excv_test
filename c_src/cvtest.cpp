#include <iostream>
#include <cmath>
#include <chrono>

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
// #include <opencv2/highgui.hpp>

#ifdef EXIST_CUDA
#include <opencv2/core/cuda.hpp>
#include <opencv2/cudaarithm.hpp>
#include <opencv2/cudaimgproc.hpp>
#endif

#include <stdint.h>

#include "cvtest.h"

extern "C" bool cvtest(size_t size1, const unsigned char *_filename1, size_t size2, const unsigned char *_filename2, double *time, bool is_cuda, uint64_t loop)
{
	std::chrono::system_clock::time_point begin = std::chrono::system_clock::now();

	try {
		cv::String filename1 = cv::String((const char *)_filename1, size1);
		cv::String filename2 = cv::String((const char *)_filename2, size2);
		cv::Mat srcHost1 = cv::imread(filename1);
		if(__builtin_expect(srcHost1.empty(), false)) {
			return false;
		}
		cv::Mat srcHost2 = cv::imread(filename2);
		if(__builtin_expect(srcHost2.empty(), false)) {
			return false;
		}
		cv::Mat resultHost;
#ifdef EXIST_CUDA
		if(is_cuda) {
			cv::cuda::GpuMat src1;
			cv::cuda::GpuMat src2;
			src1.upload(srcHost1);
			src2.upload(srcHost2);
			cv::cuda::GpuMat dst;
			for(uint64_t i = 0; i < loop; i++) {
				cv::cuda::GpuMat diff, threshold;
				cv::cuda::absdiff(src1, src2, diff);
				cv::cuda::threshold(diff, threshold, 1, 128, cv::THRESH_BINARY);
				dst = threshold;
			}
			dst.download(resultHost);
		} else {
#endif
			cv::Mat src1 = srcHost1;
			cv::Mat src2 = srcHost2;
			cv::Mat dst;
			for(uint64_t i = 0; i < loop; i++) {
				cv::Mat diff, threshold;
				cv::absdiff(src1, src2, diff);
				cv::threshold(diff, threshold, 1, 128, cv::THRESH_BINARY);
				dst = threshold;
			}
			resultHost = dst;

			/*
			cv::imshow("threshold", resultHost);
			cv::waitKey();
			*/
#ifdef EXIST_CUDA
		}
#endif
	} catch(const cv::Exception& ex) {
		std::cout << "Error: " << ex.what() << std::endl;
		return false;
	}

	std::chrono::system_clock::time_point end = std::chrono::system_clock::now();
	*time = static_cast<double>(std::chrono::duration_cast<std::chrono::microseconds>(end - begin).count());
	return true;
}

