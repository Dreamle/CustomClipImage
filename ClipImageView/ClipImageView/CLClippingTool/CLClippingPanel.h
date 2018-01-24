//
//  CLClippingPanel.h
//  ClipTool
//
//  Created by 龙少 on 16/4/30.
//  Copyright © 2016年 龙少. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLClippingPanel : UIView

@property (nonatomic, assign) CGRect clippingRect;
- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame;
- (void)setBgColor:(UIColor*)bgColor;
- (void)setGridColor:(UIColor*)gridColor;

- (void)executeWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *dic))completionBlock;

@end
