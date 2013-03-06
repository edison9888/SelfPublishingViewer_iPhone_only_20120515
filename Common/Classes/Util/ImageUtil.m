//
//  ImageUtil.m
//  ForIphone
//
//  Created by 藤田正訓 on 11/07/28.
//  Copyright 2011 SAT. All rights reserved.
//

#import "ImageUtil.h"
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/calib3d/calib3d.hpp>

@implementation ImageUtil

#pragma mark - OpenCV support

// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
+ (IplImage *)IplImageFromUIImage:(UIImage *)image {
	CGImageRef imageRef = image.CGImage;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
    
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
    
	return ret;
}

//+ (IplImage*)convertToGrayscale:(

// NOTE You should convert color mode as RGB before passing to this function
+ (UIImage *)UIImageFromIplImage:(IplImage *)image {
	NSLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s", image->width, image->height, image->depth, image->nChannels, image->widthStep, image->channelSeq);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
    cvReleaseImage(&image);

	return ret;
}

// cosを求める
double angle(CvPoint* pt1, CvPoint* pt2, CvPoint* pt0) {
    double dx1 = pt1->x - pt0->x;
    double dy1 = pt1->y - pt0->y;
    double dx2 = pt2->x - pt0->x;
    double dy2 = pt2->y - pt0->y;
    return (dx1 * dx2 + dy1 * dy2) / sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}

// 右上を返す
CvPoint ne(const CvPoint* sq) {
    double max = 0;
    CvPoint ret;
    for (int i = 0; i < 4; i++) {
        CvPoint p = sq[i];
        double mean = ((double)p.x) / ((double)p.y);
        if (max < mean) {
            max = mean;
            ret = p;
        }
    }
    return ret;
}
// 左上を返す
CvPoint nw(const CvPoint* sq) {
    int min = INT_MAX;
    CvPoint ret;
    for (int i = 0; i < 4; i++) {
        CvPoint p = sq[i];
        int mean = p.x + p.y;
        if (min > mean) {
            min = mean;
            ret = p;
        }
    }
    return ret;
}
// 右下を返す
CvPoint se(const CvPoint* sq) {
    int max = 0;
    CvPoint ret;
    for (int i = 0; i < 4; i++) {
        CvPoint p = sq[i];
        int mean = p.x + p.y;
        if (max < mean) {
            max = mean;
            ret = p;
        }
    }
    return ret;
}
// 左下を返す
CvPoint sw(const CvPoint* sq) {
    double max = 0;
    CvPoint ret;
    for (int i = 0; i < 4; i++) {
        CvPoint p = sq[i];
        double mean = ((double)p.y) / ((double)p.x);
        if (max < mean) {
            max = mean;
            ret = p;
        }
    }
    return ret;
}


#pragma mark - public methods


// 画像を比率で切り抜く
+ (UIImage*)clip: (UIImage*)img rect:(CGRect)rect {
    if (1 > rect.size.width || 1 > rect.size.height) {
        CGSize imgSize = CGSizeMake(img.size.width * rect.size.width,
                                    img.size.height * rect.size.height);
        CGPoint imgPoint = CGPointMake(-img.size.width * rect.origin.x,
                                       -img.size.height * rect.origin.y);

        UIGraphicsBeginImageContext(imgSize);
        [img drawAtPoint:imgPoint];
        UIImage* newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImg;
    } else {
        return img;
    }
}

// 画像を縮小する
+ (UIImage*)shrink: (UIImage*)img toSize:(CGSize)size {
    if (img.size.width > size.width || img.size.height > size.height) {
        UIGraphicsBeginImageContext(size);
        [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return ret;
    } else {
        return img;
    }
}

// アスペクト比を保ったまま枠に入るように画像を縮小する
+ (UIImage*)shrinkAspect:(UIImage*)img toSize:(CGSize)size {
    CGFloat mag = fminf(size.width / img.size.width, size.height / img.size.height);
    CGSize toSize = CGSizeMake(img.size.width * mag, img.size.height * mag);
    return [self shrink:img toSize:toSize];
}

// 画像を縮小する。横長の画像であれば半分に切り取る。
+ (UIImage*)shrinkClip:(UIImage*)img toSize:(CGSize)size left:(BOOL)left {
    if (!left && img.size.width > img.size.height) {
        size.width *= 2;
    }
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}



// 
+ (BOOL)findMaxSquare: (UIImage*)uiimg result:(CGPoint*)ret {
    cvSetErrMode(CV_ErrModeParent);
    // 元画像
    IplImage* img = [self IplImageFromUIImage:uiimg];
    // ストレージ
    CvMemStorage* storage = cvCreateMemStorage(0);
    cvClearMemStorage(storage);
    
    CvSeq* contours;
    const int N = 11;
    const int FMAX = 10;
    const int thresh = 50;
    CvSize sz = cvSize(img->width & -2, img->height & -2);
    
    IplImage* timg = cvCloneImage(img); // 作業用
    IplImage* gray = cvCreateImage(sz, IPL_DEPTH_8U, 1); // グレースケール
    IplImage* pyr = cvCreateImage(cvSize(sz.width / 2, sz.height / 2), IPL_DEPTH_8U, 3);
    
    // 結果を格納する配列
    CvSeq* squares = cvCreateSeq(0, sizeof(CvSeq), sizeof(CvPoint), storage);
    
    // 最大のROI
    cvSetImageROI(timg, cvRect(0, 0, sz.width, sz.height));
    
    // ノイズ除去
    cvPyrDown(timg, pyr, 7);
    cvPyrUp(pyr, timg, 7);
    IplImage* tgray = cvCreateImage(sz, IPL_DEPTH_8U, 1);
    
    // 各色について四角形を検出
    int found = 0;
    for (int c = 0; c < 3; c++) {
        cvSetImageCOI(timg, c + 1);
        cvCopy(timg, tgray, 0);
        
        // thresholdを変えていろいろ試す
        for (int l = 0; l < N; l++) {
            if (l == 0) {
                // hack:threshold=0のときはCannyを使うらしい
                cvCanny(tgray, gray, 0, thresh, 5);
                // わからないけど
                cvDilate(gray, gray, 0, 1);
            } else {
                // 二値にする
                cvThreshold(tgray, gray, (l + 1) * 255 / N, 255, CV_THRESH_BINARY);
            }
            // 輪郭検出
            cvFindContours(gray, storage, &contours, sizeof(CvContour), 
                           CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
            
            // 見つかった輪郭についてループ
            for (; contours; contours = contours->h_next) {
                // えっと・・？
                CvSeq* result = cvApproxPoly(contours, sizeof(CvContour), storage, 
                                             CV_POLY_APPROX_DP, cvContourPerimeter(contours) * 0.02, 0);
                // 四角形は4辺があり比較的大きい面積。areaは輪郭の向きによって負値が返る場合があるので絶対値を使う
                // 画像の面積の半分以上のものに限る。
                double area = fabs(cvContourArea(result, CV_WHOLE_SEQ, 0));
                if (result->total == 4 
                    && area > (sz.width * sz.height * 0.5)
                    && area < (sz.width * sz.height * 0.95)
                    && cvCheckContourConvexity(result)) {
                    // 最小の角度のcosを求める
                    double s = 0;
                    for (int i = 2; i < 5; i++) {
                        double t = fabs(angle(
                                              (CvPoint*)cvGetSeqElem(result, i),
                                              (CvPoint*)cvGetSeqElem(result, i - 2),
                                              (CvPoint*)cvGetSeqElem(result, i - 1)
                                              ));
                        s = s > t ? s : t;
                    }
                    
                    // すべての角のcosがそこそこ小さければ90度ぐらいとみなして結果配列に加える
                    if (s < 0.3) {
                        for (int i = 0; i < 4; i++) {
                            cvSeqPush(squares, (CvPoint*)cvGetSeqElem(result, i));
                        }
                        if (++found > FMAX) {
                            // break loop
                            l = N;
                            c = 3;
                            break;
                        }
                    }
                }
            }
            
        }
        
    }
    cvReleaseImage(&gray);
    cvReleaseImage(&pyr);
    cvReleaseImage(&tgray);
    cvReleaseImage(&timg);
    cvReleaseImage(&img);
    
    // 結果を作る
    CvSeqReader reader;
    cvStartReadSeq(squares, &reader, 0);
    
    // 最大の四角形を保存する
    CvPoint maxsq[] = {
        cvPoint(0, 0),
        cvPoint(0, 0),
        cvPoint(0, 0),
        cvPoint(0, 0)
    };
    double maxArea = 0;
    CvSeq* pts = cvCreateSeq(CV_SEQ_POLYLINE, sizeof(CvSeq), sizeof(CvPoint), storage);
    
    // 4点ずつ読み込む
    BOOL retval = NO;
    for (int i = 0; i < squares->total; i += 4) {
        retval = YES;
        CvPoint pt[4];
        CV_READ_SEQ_ELEM(pt[0], reader);
        CV_READ_SEQ_ELEM(pt[1], reader);
        CV_READ_SEQ_ELEM(pt[2], reader);
        CV_READ_SEQ_ELEM(pt[3], reader);
        cvClearSeq(pts);
        cvSeqPush(pts, &pt[0]);
        cvSeqPush(pts, &pt[1]);
        cvSeqPush(pts, &pt[2]);
        cvSeqPush(pts, &pt[3]);
        
        double area = fabs(cvContourArea(pts, CV_WHOLE_SEQ, 0));
        
        NSLog(@"(%d,%d)(%d,%d)(%d,%d)(%d,%d) %0.1f",
              pt[0].x, pt[0].y,
              pt[1].x, pt[1].y,
              pt[2].x, pt[2].y,
              pt[3].x, pt[3].y, area);
        
        if (maxArea < area) {
            maxsq[0] = ne(pt);
            maxsq[1] = se(pt);
            maxsq[2] = sw(pt);
            maxsq[3] = nw(pt);
            maxArea = area;
        }
    }
    cvReleaseMemStorage(&storage);
    
    NSLog(@"max:(%d,%d)(%d,%d)(%d,%d)(%d,%d) %0.1f",
          maxsq[0].x, maxsq[0].y,
          maxsq[1].x, maxsq[1].y,
          maxsq[2].x, maxsq[2].y,
          maxsq[3].x, maxsq[3].y, maxArea);
    
    
    for (int i = 0; i < 4; i++) {
        ret[i] = CGPointMake(((double)maxsq[i].x) / sz.width, ((double)maxsq[i].y) / sz.height);
    }
    return retval;
}



// グレイスケール画像に変換する
+ (UIImage*)grayscale:(UIImage*)origImage {
    if (!origImage) {
        return nil;
    }
    cvSetErrMode(CV_ErrModeParent);
    
    // Create grayscale IplImage from UIImage
    IplImage *img_color = [self IplImageFromUIImage:origImage];
    IplImage *img = cvCreateImage(cvGetSize(img_color), IPL_DEPTH_8U, 1);
    cvCvtColor(img_color, img, CV_BGR2GRAY);
    cvReleaseImage(&img_color);
    
    // グレイスケールからカラーにする
    IplImage *cimg = cvCreateImage(cvGetSize(img), IPL_DEPTH_8U, 3);
    for(int y=0; y<img->height; y++) {
        for(int x=0; x<img->width; x++) {
            char *p = cimg->imageData + y * cimg->widthStep + x * 3;
            *p = *(p+1) = *(p+2) = img->imageData[y * img->widthStep + x];
        }
    }
    cvReleaseImage(&img);
    
    return [self UIImageFromIplImage:cimg];
}

// 射影変換
+ (UIImage*)homography:(UIImage*)origImage 
                    nw:(CGPoint)nw
                    ne:(CGPoint)ne
                    sw:(CGPoint)sw
                    se:(CGPoint)se {
    cvSetErrMode(CV_ErrModeParent);
    // 四隅を含む矩形
    int minx = fminf(CGFLOAT_MAX, fminf(ne.x, fminf(nw.x, fminf(se.x, sw.x))));
    int miny = fminf(CGFLOAT_MAX, fminf(ne.y, fminf(nw.y, fminf(se.y, sw.y))));
    int maxx = fmaxf(CGFLOAT_MIN, fmaxf(ne.x, fmaxf(nw.x, fmaxf(se.x, sw.x))));
    int maxy = fmaxf(CGFLOAT_MIN, fmaxf(ne.y, fmaxf(nw.y, fmaxf(se.y, sw.y))));
    IplImage* src = [self IplImageFromUIImage:origImage];
#if 0
    return [self UIImageFromIplImage:src];
#endif
    
    CvSize dstSize = cvSize(maxx - minx, maxy - miny);
    IplImage* dst = cvCreateImage(dstSize, IPL_DEPTH_8U, 3);
    
    // 変換前の画像での座標データ型
    double srcparray[] = {
        nw.x, nw.y,
        sw.x, sw.y,
        se.x, se.y,
        ne.x, ne.y,
    };
    CvMat srcPoint = cvMat(4, 2, CV_64FC1, srcparray);
    
    // 変換後の画像での座標データ
    double dstparray[] = {
        0, 0,
        0, dstSize.height,
        dstSize.width, dstSize.height,
        dstSize.width, 0,
    };
    CvMat dstPoint = cvMat(4, 2, CV_64FC1, dstparray);
    
    // homography行列を計算
    CvMat *h = cvCreateMat(3, 3, CV_64FC1);
    // （第4引数以降はデフォルト）
    cvFindHomography(&srcPoint, &dstPoint, h, 0, 3, NULL);
    
    // 変換（第３引数以降はデフォルト）
    cvWarpPerspective(src, dst, h, CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS, cvScalarAll(0));
    cvReleaseImage(&src);
    
    // BGRからRGBAに変換する
    IplImage* cimg = cvCreateImage(cvGetSize(dst), IPL_DEPTH_8U, 3);
    cvCvtColor(dst, cimg, CV_BGR2RGB);
    cvReleaseImage(&dst);
    
    return [self UIImageFromIplImage:cimg];
}



// イメージからARGB形式のビットマップコンテキストを作る
+ (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage {
	CGContextRef    ctx = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL) {
		return NULL;
	}
	
	bitmapData = malloc (bitmapByteCount);
	if (bitmapData == NULL) {
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
	
	ctx = CGBitmapContextCreate (bitmapData,
                                 pixelsWide,
                                 pixelsHigh,
                                 8,
                                 bitmapBytesPerRow,
                                 colorSpace,
                                 kCGImageAlphaPremultipliedFirst);
	if (ctx == NULL) {
		free (bitmapData);
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease(colorSpace);
    CGRect rect = CGRectMake(0, 0, pixelsWide, pixelsHigh);
	CGContextDrawImage(ctx, rect, inImage);
	
	return ctx;
}



// 指定ピクセルの色を取得する
// 指定ポイントの色を取得する
+ (UIColor*)getColorAtPoint:(CGPoint)point image:(UIImage*)image {
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (!cgctx) {
        return nil;
    }
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
	unsigned char* data = CGBitmapContextGetData(cgctx);
    CGContextRelease(cgctx);
	if (data != NULL) {
		int offset = 4 * ((w * round(point.y)) + round(point.x));
		if(offset < 0 || offset > w * h * 4 || point.x < 0 || point.x > w) {
            free(data);
			return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
		} else {
            int alpha =  data[offset] % 256;
            int red = data[offset+1] % 256;
            int green = data[offset+2] % 256;
            int blue = data[offset+3] % 256;
            free(data);
            return [UIColor colorWithRed:(red / 255.0f) 
                                    green:(green / 255.0f) 
                                     blue:(blue / 255.0f) 
                                    alpha:(alpha / 255.0f)];
        }
	}
    return nil;

}

@end
