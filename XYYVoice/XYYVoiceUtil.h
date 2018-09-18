//
//  XYYVoiceUtil.h
//  XYYVoice
//
//  Created by 陈荣航 on 2018/9/18.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import <Foundation/Foundation.h>

//声音水平
float voiceLevelForDecibels(float decibels, float silentDecibels);
//默认silentDecibels为-80db
float voiceLevelForDecibels_default(float decibels);

