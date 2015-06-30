//
//  ViewController.h
//  LazyTableView
//
//  Created by 孙昕 on 15/6/29.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LazyTableView.h"
@interface ViewController : UIViewController<LazyTableViewDelegate>
@property (strong, nonatomic) IBOutlet LazyTableView *table1;
@property (strong, nonatomic) IBOutlet LazyTableView *table2;
@property (strong, nonatomic) IBOutlet LazyTableView *table3;


@end

