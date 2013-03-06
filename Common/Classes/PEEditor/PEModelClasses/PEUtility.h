//
//  PEUtility.h
//  PhotoEditiong
//
//  Created by FuGenX Technologies Pvt. Ltd.
//  Copyright 2012 FuGenX Technologies Pvt. Ltd. All rights reserved.
//

typedef  enum {
    StampTypeStar=1,
    StampTypePen,
    StampTypeBallon,
    StampTypeOriginalStamp,
    StampTypeFrame
    
} StampType;

typedef  enum {
    Normal_Pen=1,
    Special_Pen,
    Errasor
          
} BrushType;

typedef  enum {
   Controller_Type,
    Drawing_Type
} SelectedType;

typedef struct Color {
    float red;
    float green;
    float blue;
}RGBColor;

