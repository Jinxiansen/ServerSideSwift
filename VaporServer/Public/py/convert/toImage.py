
from PIL import Image
import sys
import os
import getopt
from optparse import OptionParser  

import argparse
parser = argparse.ArgumentParser(description="请指定图片输出名称")
parser.add_argument('key')
parser.add_argument('d')
parser.add_argument('imgPath')
parser.add_argument('bgPath')
args = parser.parse_args()
key = args.key
d = args.d

imgPath = args.imgPath
bgPath = args.bgPath

imgName = key + '.jpg'

print('args = ',imgName,d,imgPath,bgPath,' count = ',len(sys.argv[1:])) # 

def convertImage():

	if (len(imgPath) < 1) | (len(bgPath) < 1):
		print("Error: the picture doesn't exist")
		exit(0)
	
	file1 = imgPath
	fileleft = 'plus/plus.png'
	filebg = bgPath

	toImage = Image.new('RGBA',(1242,2208))

	imgbg = Image.open(filebg)

	locbg = (0, 0)
	imgbg = imgbg.resize((1242,2208),Image.BILINEAR)
	toImage.paste(imgbg,locbg)

	# left 
	imgleft = Image.open(fileleft)

	imgleft = imgleft.resize((853,1718),Image.BILINEAR)
	imgleft = imgleft.rotate(41, expand=1)
	r,g,b,a = imgleft.split()
	# print("img 是 ",imgleft)
	if d == '1':
		toImage.paste(imgleft,(356,175),mask = a)
	else:
		toImage.paste(imgleft,(-910,115),mask = a)

	# 1
	img1 = Image.open(file1)

	img1 = img1.convert("RGBA")

	img1 = img1.resize((750,1336),Image.BILINEAR)
	img1 = img1.rotate(41,expand=1)
	rr,gg,bb,aa = img1.split()
 
	if d == '1':
		toImage.paste(img1, (519, 353),mask = aa)
	else:
		toImage.paste(img1, (-755,283),mask = aa)

	# toImage.show()

	filePath = 'out/'

	if not os.path.exists(filePath):
		print('creat the path',filePath)
		os.makedirs(filePath,0777)
	else:
		print('path is exist')

	namePath = filePath + imgName

	toImage = toImage.convert("RGB")
	toImage.save(namePath)
	print('save success!')


convertImage()








