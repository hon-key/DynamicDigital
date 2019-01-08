//
//  DynamicString.h
//
//  Created by Matt on 2018/12/20.
//  Copyright © 2018 Matt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UILabel (DynamicDigital)
@property (nonatomic,assign) CGFloat dynamicDigitalAnimation;
@property (nonatomic,strong) dispatch_source_t dynamicTimer;
@end
