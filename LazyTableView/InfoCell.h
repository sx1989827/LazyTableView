//
//  InfoCell.h
//  LazyTableView
//
//  Created by 孙昕 on 15/6/29.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LazyTableCell.h"
@interface InfoCell : LazyTableCell
@property (strong, nonatomic) IBOutlet UILabel *lbName;
@property (strong, nonatomic) IBOutlet UILabel *lbType;
@property (strong, nonatomic) IBOutlet UILabel *lbDate;

@end
