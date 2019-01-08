//
//  DynamicString.m
//
//  Created by Matt on 2018/12/20.
//  Copyright © 2018 Matt. All rights reserved.
//

#import "DynamicString.h"

@implementation UILabel (DynamicDigital)
- (CGFloat)dynamicDigitalAnimation {
    return ((NSNumber *)objc_getAssociatedObject(self, _cmd)).doubleValue;
}
- (void)setDynamicDigitalAnimation:(CGFloat)dynamicDigitalAnimation {
    objc_setAssociatedObject(self, @selector(dynamicDigitalAnimation), @(dynamicDigitalAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (dynamicDigitalAnimation > 0) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Method orgin = class_getInstanceMethod([self class], @selector(setText:));
            Method new = class_getInstanceMethod([self class], @selector(sw_setText:));
            method_exchangeImplementations(orgin, new);
        });
    }
}

- (dispatch_source_t)dynamicTimer {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setDynamicTimer:(dispatch_source_t)dynamicTimer {
    objc_setAssociatedObject(self, @selector(dynamicTimer), dynamicTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)sw_setText:(NSString *)text {
    if (self.dynamicTimer) {
        dispatch_source_cancel(self.dynamicTimer);
        self.dynamicTimer = nil;
    }
    
    if (self.dynamicDigitalAnimation <= 0) {
        [self sw_setText:text];
        return;
    }
    
    NSString *startDigitalString = self.text, *endDigitalString = text;
    if ((!startDigitalString.isPureInteger && !startDigitalString.isPureDouble) ||
        (!endDigitalString.isPureInteger && !endDigitalString.isPureDouble) ||
        [endDigitalString isEqualToString:startDigitalString]) {
        [self sw_setText:text];
        return;
    }
    
    if (endDigitalString.isPureInteger) {
        [self sw_setTextIntergerWithStart:startDigitalString end:endDigitalString];
    }else {
        [self sw_setTextDoubleWithStart:startDigitalString end:endDigitalString];
    }
    
    

}

- (void)sw_setTextIntergerWithStart:(NSString *)startDigitalString end:(NSString *)endDigitalString {
    NSInteger start = startDigitalString.integerValue;
    NSInteger end = endDigitalString.integerValue;
    NSInteger offset = end - start;
    int count = labs(offset) <= 60 * self.dynamicDigitalAnimation ? labs(offset) : 60 * self.dynamicDigitalAnimation;

    double rate = (double)labs(offset) / (double)count;
    double littleDecimal = rate - (int)rate;
    int bigPart = nearbyint(littleDecimal * count);
    int smallSegment = (int)rate;
    int bigSegment = smallSegment + 1;

    double time = self.dynamicDigitalAnimation / count;
    self.dynamicTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.dynamicTimer, DISPATCH_TIME_NOW, time * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    __block int index = 0;
    __block NSInteger current = start;
    dispatch_source_set_event_handler(self.dynamicTimer, ^{
        index++;
        static int segment;
        segment = index <= bigPart ? bigSegment : smallSegment;
        current = offset > 0 ? current + segment : current - segment;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sw_setText:[NSString stringWithFormat:@"%d",current]];
        });
        if (index >= count) {
            dispatch_source_cancel(self.dynamicTimer);
            objc_setAssociatedObject(self, _cmd, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    dispatch_resume(self.dynamicTimer);
}

- (void)sw_setTextDoubleWithStart:(NSString *)startDigitalString end:(NSString *)endDigitalString {
    int decimalNum = [endDigitalString componentsSeparatedByString:@"."][1].length;
    NSInteger powNum = pow(10, [endDigitalString componentsSeparatedByString:@"."][1].length);
    NSInteger start = startDigitalString.doubleValue * powNum;
    NSInteger end = endDigitalString.doubleValue * powNum;
    NSInteger offset = end - start;
    int count = labs(offset) <= 60 * self.dynamicDigitalAnimation ? labs(offset) : 60 * self.dynamicDigitalAnimation;
    
    double rate = (double)labs(offset) / (double)count;
    double littleDecimal = rate - (int)rate;
    int bigPart = nearbyint(littleDecimal * count);
    int smallSegment = (int)rate;
    int bigSegment = smallSegment + 1;
    
    double time = self.dynamicDigitalAnimation / count;
    self.dynamicTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.dynamicTimer, DISPATCH_TIME_NOW, time * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    __block int index = 0;
    __block double current = start;
    dispatch_source_set_event_handler(self.dynamicTimer, ^{
        index++;
        static int segment;
        segment = index <= bigPart ? bigSegment : smallSegment;
        current = offset > 0 ? current + segment : current - segment;
        NSString *formatText = [NSString stringWithFormat:@"%%.%df",decimalNum];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sw_setText:[NSString stringWithFormat:formatText,current/powNum]];
        });
        if (index >= count) {
            dispatch_source_cancel(self.dynamicTimer);
            objc_setAssociatedObject(self, _cmd, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    dispatch_resume(self.dynamicTimer);
}




@end
