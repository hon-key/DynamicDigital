//
//  DynamicString.m
//  ShouYinTong
//
//  Created by Ruite Chen on 2018/12/20.
//  Copyright © 2018 乐刷. All rights reserved.
//

#import "DynamicString.h"
#import <objc/runtime.h>

@interface NSString (DynamicDigital)
- (BOOL)isPureInteger;
- (BOOL)isPureDouble;
@end

@implementation NSString (DynamicDigital)
- (BOOL)isPureInteger {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSInteger val;
    return [scanner scanInteger:&val] && [scanner isAtEnd];
}
- (BOOL)isPureDouble {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    double val;
    return [scanner scanDouble:&val] && [scanner isAtEnd];
}

@end

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
    NSInteger count = labs(offset) <= 60 * self.dynamicDigitalAnimation ? labs(offset) : 60 * self.dynamicDigitalAnimation;

    CGFloat rate = (CGFloat)labs(offset) / (CGFloat)count;
    CGFloat littleDecimal = rate - (NSInteger)rate;
    NSInteger bigPart = nearbyint(littleDecimal * count);
    NSInteger smallSegment = (NSInteger)rate;
    NSInteger bigSegment = smallSegment + 1;

    CGFloat time = self.dynamicDigitalAnimation / count;
    self.dynamicTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.dynamicTimer, DISPATCH_TIME_NOW, time * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    __block NSInteger index = 0;
    __block NSInteger current = start;
    dispatch_source_set_event_handler(self.dynamicTimer, ^{
        index++;
        static NSInteger segment;
        segment = index <= bigPart ? bigSegment : smallSegment;
        current = offset > 0 ? current + segment : current - segment;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sw_setText:[NSString stringWithFormat:@"%ld",current]];
        });
        if (index >= count) {
            dispatch_source_cancel(self.dynamicTimer);
            objc_setAssociatedObject(self, _cmd, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    dispatch_resume(self.dynamicTimer);
}

- (void)sw_setTextDoubleWithStart:(NSString *)startDigitalString end:(NSString *)endDigitalString {
    CGFloat decimalNum = [endDigitalString componentsSeparatedByString:@"."][1].length;
    CGFloat powNum = pow(10, [endDigitalString componentsSeparatedByString:@"."][1].length);
    CGFloat start = startDigitalString.doubleValue * powNum;
    CGFloat end = endDigitalString.doubleValue * powNum;
    CGFloat offset = end - start;
    CGFloat count = fabs(offset) <= 60 * self.dynamicDigitalAnimation ? fabs(offset) : 60 * self.dynamicDigitalAnimation;
    
    CGFloat rate = fabs(offset) / count;
    CGFloat littleDecimal = rate - rate;
    CGFloat bigPart = nearbyint(littleDecimal * count);
    CGFloat smallSegment = rate;
    CGFloat bigSegment = smallSegment + 1;
    
    CGFloat time = self.dynamicDigitalAnimation / count;
    self.dynamicTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.dynamicTimer, DISPATCH_TIME_NOW, time * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    __block CGFloat index = 0;
    __block CGFloat current = start;
    dispatch_source_set_event_handler(self.dynamicTimer, ^{
        index++;
        static CGFloat segment;
        segment = index <= bigPart ? bigSegment : smallSegment;
        current = offset > 0 ? current + segment : current - segment;
        NSLog(@"%lf,%lf/%lf",current,index,count);
        NSString *formatText = [NSString stringWithFormat:@"%%.%.0lflf",decimalNum];
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
