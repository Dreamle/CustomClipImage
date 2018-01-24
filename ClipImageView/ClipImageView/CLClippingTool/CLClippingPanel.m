//
//  CLClippingPanel.m
//  ClipTool
//
//  Created by 龙少 on 16/4/30.
//  Copyright © 2016年 龙少. All rights reserved.
//

#import "CLClippingPanel.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utility.h"
#import "UIView+Frame.h"

#pragma mark- UI components

@interface CLClippingCircle : UIView

@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation CLClippingCircle

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.x = rct.size.width/2-rct.size.width/6;
    rct.origin.y = rct.size.height/2-rct.size.height/6;
    rct.size.width /= 3;
    rct.size.height /= 3;
    
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillEllipseInRect(context, rct);
}

@end



//网格图
@interface CLGridLayar : CALayer
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;
@end

@implementation CLGridLayar

+ (BOOL)needsDisplayForKey:(NSString*)key
{
    if ([key isEqualToString:@"clippingRect"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if(self && [layer isKindOfClass:[CLGridLayar class]]){
        self.bgColor   = ((CLGridLayar*)layer).bgColor;
        self.gridColor = ((CLGridLayar*)layer).gridColor;
        self.clippingRect = ((CLGridLayar*)layer).clippingRect;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rct = self.bounds;
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, rct);
    
    CGContextClearRect(context, _clippingRect);
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, 1);
    
    rct = self.clippingRect;
    
    CGContextBeginPath(context);
    CGFloat dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x+dW, rct.origin.y);
        CGContextAddLineToPoint(context, rct.origin.x+dW, rct.origin.y+rct.size.height);
        dW += _clippingRect.size.width/3;
    }
    
    dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW);
        CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW);
        dW += rct.size.height/3;
    }
    CGContextStrokePath(context);
}

@end



@implementation CLClippingPanel
{
    CLGridLayar *_gridLayer;
    CLClippingCircle *_ltView;
    CLClippingCircle *_lbView;
    CLClippingCircle *_rtView;
    CLClippingCircle *_rbView;
}


- (CLClippingCircle *)clippingCircleWithTag:(NSInteger)tag
{
    CLClippingCircle *view = [[CLClippingCircle alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    view.backgroundColor = [UIColor clearColor];
    view.bgColor = [UIColor blackColor];
    view.tag = tag;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    [view addGestureRecognizer:panGesture];
    
    [self.superview addSubview:view];
    
    return view;
}

- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        //将自己添加进父视图
        [superview addSubview:self];
        
        
        //绘画网格layer
        _gridLayer = [[CLGridLayar alloc] init];
        _gridLayer.frame = self.bounds;
        _gridLayer.bgColor   = [UIColor colorWithWhite:1 alpha:0.6];
        _gridLayer.gridColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self.layer addSublayer:_gridLayer];
        
        //四个圆点的添加
        _ltView = [self clippingCircleWithTag:0];
        _lbView = [self clippingCircleWithTag:1];
        _rtView = [self clippingCircleWithTag:2];
        _rbView = [self clippingCircleWithTag:3];
        
        //给自身添加平移手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
        [self addGestureRecognizer:panGesture];
        
        self.clippingRect = self.bounds;
    }
    return self;
}


- (void)setBgColor:(UIColor *)bgColor
{
    _gridLayer.bgColor = bgColor;
}

- (void)setGridColor:(UIColor *)gridColor
{
    _gridLayer.gridColor = gridColor;
    _ltView.bgColor = _lbView.bgColor = _rtView.bgColor = _rbView.bgColor = [gridColor colorWithAlphaComponent:1];
}



- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    
    _ltView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:self];
    _lbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    _rtView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:self];
    _rbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    
    _gridLayer.clippingRect = clippingRect;
    [self setNeedsDisplay];
}




- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    [_gridLayer setNeedsDisplay];
}



- (void)panCircleView:(UIPanGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self];
    CGPoint dp = [sender translationInView:self];
    
    CGRect rct = self.clippingRect;
    
    const CGFloat W = self.frame.size.width;
    const CGFloat H = self.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    //
    CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -0 : 0;
    
    switch (sender.view.tag) {
        case 0: // upper left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case 1: // lower left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case 2: // upper right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case 3: // lower right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:
            break;
    }
    self.clippingRect = rct;
}



- (void)panGridView:(UIPanGestureRecognizer*)sender
{
    static BOOL dragging = NO;
    static CGRect initialRect;
    
    if(sender.state==UIGestureRecognizerStateBegan){
        CGPoint point = [sender locationInView:self];
        dragging = CGRectContainsPoint(_clippingRect, point);
        initialRect = self.clippingRect;
    }
    else if(dragging){
        CGPoint point = [sender translationInView:self];
        CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), self.frame.size.width-initialRect.size.width);
        CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), self.frame.size.height-initialRect.size.height);
        
        CGRect rct = self.clippingRect;
        rct.origin.x = left;
        rct.origin.y = top;
        self.clippingRect = rct;
    }
}



//点击 OK 之后，截图
- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    
    UIView *fatherView = self.superview;
    
    //找出父视图中的图片，将图片裁剪
    for (UIView *aView in fatherView.subviews) {
        
        if ([aView isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView = (UIImageView *)aView;
            
            NSLog(@"%s %d ----%@ %@", __FUNCTION__, __LINE__,NSStringFromCGRect(imageView.frame),NSStringFromCGSize(imageView.image.size));
            
            CGFloat zoomScaleX = self.width / imageView.image.size.width ;
            CGFloat zoomScaleY = self.height / imageView.image.size.height ;
            
            CGRect rct = self.clippingRect;
            rct.size.width  /= zoomScaleX;
            rct.size.height /= zoomScaleY;
            rct.origin.x    /= zoomScaleX;
            rct.origin.y    /= zoomScaleY;
            
            //此处的rect和图片自身的rect代表不同的意义，所以截取图片需要根据比例转化坐标系
            UIImage *result = [imageView.image cropImageInRect:rct];
            completionBlock(result, nil, nil);
            
            [[NSUserDefaults standardUserDefaults] setValue:@(zoomScaleX) forKey:@"zoomScaleX"];
            [[NSUserDefaults standardUserDefaults] setValue:@(zoomScaleY) forKey:@"zoomScaleY"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
    }
    
   
}

@end
