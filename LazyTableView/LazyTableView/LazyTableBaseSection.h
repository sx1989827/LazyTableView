//
//  LazyTableBaseSection.h
//  LazyTable
//
//  Created by 孙昕 on 15/2/5.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LazyTableBaseSection : NSObject
/**
 *  section的头部文字
 */
@property (strong,nonatomic) NSString *titleHeader;
/**
 *  section的底部文字
 */
@property (strong,nonatomic) NSString *titleFooter;
/**
 *  section的头部高度
 */
@property (assign,nonatomic)  CGFloat  headerHeight;
/**
 *  section的底部高度
 */
@property (assign,nonatomic)  CGFloat  footerHeight;
/**
 *  section的头部自定义view
 */
@property (strong,nonatomic) UIView *viewHeader;
/**
 *  section的底部自定义view
 */
@property (strong,nonatomic) UIView *viewFooter;
/**
 *  section用于加载row的字段名称
 */
@property (strong,nonatomic)  NSString *data;
/**
 *  section附加的用户数据信息
 */
@property  (strong,nonatomic) id info;
/**
 *  section的row的数据
 */
@property  (strong,nonatomic,readonly) NSMutableArray *arrItem;
/**
 *  添加一个item，这个item继承LazyTableBaseItem，与对应的cell绑定
 *
 *  @param item 
 */
-(void)addRow:(id)item;
@end
