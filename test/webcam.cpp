#include <iostream>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

int main()
{
	VideoCapture cam(0);
	Mat img;

	if(!cam.isOpened())
	{
		cout << "Failed to open webcam!" << endl;
		return -1;
	}

	while(1)
	{
		cam.read(img);
		if(!img.empty())
		{
			imshow("Webcam", img);
			if(waitKey(1) == 27)
			{
				break;
			}
		}
		else
		{
			cout << "Failed to read image from webcam!" << endl;
		}
	}

	return 0;
}
