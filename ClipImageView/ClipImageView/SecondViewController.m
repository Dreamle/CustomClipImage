//
//  SecondViewController.m
//  ClipTool
//
//  Created by 龙少 on 16/4/30.
//  Copyright © 2016年 龙少. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];

   NSNumber *zoomX = [[NSUserDefaults standardUserDefaults] objectForKey:@"zoomScaleX"];
   NSNumber *zoomY = [[NSUserDefaults standardUserDefaults] objectForKey:@"zoomScaleY"];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.image.size.width * [zoomX floatValue] , self.image.size.height * [zoomY floatValue])];
    imageView.image = self.image;
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
