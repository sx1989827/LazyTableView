//
//  LazyTableCell.h
//  LazyTableView
//
//  Created by 孙昕 on 15/6/29.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LazyTableCellProtocol.h"
@interface LazyTableCell : UITableViewCell<LazyTableCellProtocol>
/**
 *  初始化cell的方法，将xib的awakeFromNib和纯代码创建的initWithStyle整合到一个方法里
 */
-(void)initWithCell;
@end
