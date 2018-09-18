//
//  XYYVoiceUtil.m
//  XYYVoice
//
//  Created by 陈荣航 on 2018/9/18.
//  Copyright © 2018年 leslie. All rights reserved.
//

#import "XYYVoiceUtil.h"


float voiceLevelForDecibels(float decibels, float silentDecibels)
{
    float level;
    float minDecibels = silentDecibels;
    
    if (decibels < minDecibels) {
        level = 0.0f;
    } else if (decibels >= 0.0f) {
        level = 1.0f;
    } else {
        
        float root            = 2.0f;
        float minAmp          = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp             = powf(10.0f, 0.05f * decibels);
        float adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    
    return level;
}

float voiceLevelForDecibels_default(float decibels) {
    return voiceLevelForDecibels(decibels,-80.f);
}
