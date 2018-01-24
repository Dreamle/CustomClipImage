//
//  ViewController.m
//  ClipImageView
//
//  Created by limeng on 2018/1/25.
//  Copyright © 2018年 limeng. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Frame.h"
#import "CLClippingPanel.h"
#import "SecondViewController.h"

#import "UIImage+Utility.h"

@interface ViewController ()
{
    CLClippingPanel *_gridView;

}

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *clipBtn;

@end

@implementation ViewController


- (UIButton *)clipBtn {
    if (!_clipBtn) {
        self.clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clipBtn.frame = CGRectMake((self.view.width - 100) * 0.5, self.view.height - 100, 100, 50);
        _clipBtn.backgroundColor = [UIColor orangeColor];
        [_clipBtn setTitle:@"截取" forState:UIControlStateNormal];
        [_clipBtn addTarget:self action:@selector(clipAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clipBtn;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, self.view.width - 50 * 2, self.view.height - 100 * 2)];
        _imageView.image = [UIImage imageNamed:@"default.jpg"];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.imageView];

    [self.view addSubview:self.clipBtn];


    //加载网格视图

    //将网格视图放在self.view上，防止四个点越界后局部拖拽无效的问题
    _gridView = [[CLClippingPanel alloc] initWithSuperview:self.view frame:self.imageView.frame];
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.bgColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];//网格视图的背景颜色
    _gridView.gridColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8]; //网线及点的颜色
    _gridView.clipsToBounds = YES;


}

- (void)clipAction {


    __weak __typeof(self) weakSelf = self;

    [_gridView executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *dic) {


        SecondViewController *secondVC = [SecondViewController new];
        secondVC.image = image;
        [weakSelf presentViewController:secondVC animated:YES completion:nil];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
