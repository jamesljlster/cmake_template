#include <iostream>
#include <string>
#include <dirent.h>
#include <sys/stat.h>

#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

int main(int argc, char* argv[])
{
	// Checking
	if(argc < 3)
	{
		cout << "Usage: video_extrace <video_file> <output_folder>" << endl;
		return -1;
	}

	// Open video
	VideoCapture video(argv[1]);
	if(!video.isOpened())
	{
		cout << "Failed to open " << argv[1] << endl;
		return -1;
	}

	// Check output folder
	DIR* fs = NULL;
	fs = opendir(argv[2]);
	if(fs == NULL)
	{
		if(mkdir(argv[2], ACCESSPERMS & (~S_IWOTH)) < 0)
		{
			cout << "Failed to create directory " << argv[2] << endl;
			return -1;
		}
		else
		{
			cout << "Folder " << argv[2] << " created" << endl;
		}
	}

	// Grab frames
	Mat tmpImg;
	string pathBase = argv[2];
	for(int i = 0; video.read(tmpImg); i++)
	{
		string fName = pathBase + "/" + to_string(i) + ".bmp";
		imwrite(fName.c_str(), tmpImg);
	}

	return 0;
}
