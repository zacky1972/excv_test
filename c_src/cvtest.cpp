#include <iostream>
#include <ctime>
#include <cmath>
#include "bits/time.h"

#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>

#include <opencv2/core/cuda.hpp>
#include <opencv2/cudaarithm.hpp>
#include <opencv2/cudaimgproc.hpp>

#include <stdint.h>

#include "cvtest.h"

extern "C" bool cvtest(size_t size, const unsigned char *_filename, double *time, bool is_cuda, uint64_t loop)
{
	std::clock_t begin = std::clock();

	try {
		cv::String filename = cv::String((const char *)_filename, size);
		cv::Mat srcHost = cv::imread(filename, cv::IMREAD_GRAYSCALE);
		if(__builtin_expect(srcHost.empty(), false)) {
			return false;
		}
		cv::Mat resultHost;
		if(is_cuda) {
			cv::cuda::GpuMat src;
			src.upload(srcHost);
			for(uint64_t i = 0; i < loop; i++) {
				cv::cuda::GpuMat dst;
				cv::cuda::bilateralFilter(src, dst, 3, 1, 1);
				src = dst;
			}
			src.download(resultHost);
		} else {
			cv::Mat src = srcHost;
			for(uint64_t i = 0; i < loop; i++) {
				cv::Mat dst;
				cv::bilateralFilter(src, dst, 3, 1, 1);
				src = dst;
			}
			resultHost = src;
		}
	} catch(const cv::Exception& ex) {
		std::cout << "Error: " << ex.what() << std::endl;
		return false;
	}

	std::clock_t end = std::clock();
	*time = double(end - begin) / CLOCKS_PER_SEC * 1000000;
	return true;
}

