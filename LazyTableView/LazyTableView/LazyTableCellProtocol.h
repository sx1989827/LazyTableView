//
//  LazyTableCellProtocol.h
//  LazyTable
//
//  Created by 孙昕 on 15/2/2.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LazyTableCellProtocol<NSObject>
/**
 *  获取cell的高度
 *
 *  @param item 绑定的item数据
 *  @param path cell所在的indexpath
 *
 *  @return cell的高度
 */
-(NSNumber*)LazyTableCellHeight:(id)item Path:(NSIndexPath*)path;
/**
 *  填充cell的内容
 *
 *  @param item 绑定的item数据
 *  @param path cell所在的indexpath
 */
-(void)LazyTableCellForRowAtIndexPath:(id)item Path:(NSIndexPath*)path;
/**
 *  cell的点击事件
 *
 *  @param item 绑定的item数据
 *  @param path cell所在的indexpath
 */
-(void)LazyTableCellDidSelect:(id)item Path:(NSIndexPath*)path;
/**
 *  cell的取消点击事件
 *
 *  @param item 绑定的item数据
 *  @param path cell所在的indexpath
 */
-(void)LazyTableCellDidDeselect:(id)item Path:(NSIndexPath*)path;
/**
 *  当前cell是否可编辑
 *
 *  @param item 绑定的item数据
 *  @param path cell所在的indexpath
 *
 *  @return 是否可编辑
 */
-(NSNumber*)LazyTableCellCanEditRowAtIndexPath:(id)item Path:(NSIndexPath*)path;
/**
 *  当cell删除时的操作
 *
 *  @param item 绑定的item数据
 *  @param path cell所在的indexpath
 */
-(void)LazyTableCellDel:(id)item Path:(NSIndexPath*)path;
@end

