//
//  CustomTableHelp.h
//  CustomTable
//
//  Created by 孙昕 on 15/2/2.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class LazyTableView;
@interface LazyTableHelp : NSObject<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) NSString *reuseId;
@property (strong,nonatomic) NSString *reuseItem;
@property (strong,nonatomic) NSMutableArray *arrData;
@property (strong,nonatomic) NSArray *arrSectionTitleIndex;
@property (assign,nonatomic) NSInteger removeCount;
@property (weak,nonatomic) LazyTableView *delegate;
@end
