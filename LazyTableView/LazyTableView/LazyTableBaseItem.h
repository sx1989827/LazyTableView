//
//  LazyTableBaseItem.h
//  LazyTable
//
//  Created by 孙昕 on 15/2/3.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "JSONModel.h"
#import <UIKit/UIKit.h>
#import "LazyTableBaseSection.h"
@interface LazyTableBaseItem : JSONModel
/**
 *  当前调用setDelegateAndDataSource的view或者viewcontroller
 */
@property (weak,nonatomic) id<Ignore> viewControllerDelegate;
/**
 *  当前的tableview
 */
@property (weak,nonatomic) UITableView<Ignore>* tableViewDelegate;
/**
 *  当前所处的section
 */
@property (weak,nonatomic) LazyTableBaseSection<Ignore>* sectionDelegate;
/**
 *  当前item所对应的cell
 */
@property (strong,nonatomic) NSString<Ignore> *cellClassName;
@end









