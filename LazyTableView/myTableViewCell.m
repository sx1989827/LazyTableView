//
//  myTableViewCell.m
//  CustomTable
//
//  Created by 孙昕 on 15/2/2.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "myTableViewCell.h"
#import "myTableViewItem.h"
@implementation myTableViewCell




-(NSNumber*)LazyTableCellHeight:(id)item Path:(NSIndexPath *)path
{
    myTableViewItem *thItem=item;
    self.lbName.text=[NSString stringWithFormat:@"%@%@%@%@",thItem.scoreRealName,thItem.scoreRealName,thItem.scoreRealName,thItem.scoreRealName];
    self.lbName.preferredMaxLayoutWidth=thItem.tableViewDelegate.frame.size.width-30-67;
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return @(1+ size.height);
}

-(void)LazyTableCellForRowAtIndexPath:(id)item Path:(NSIndexPath *)path
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    myTableViewItem *tbItem=item;
    _lbName.text=[NSString stringWithFormat:@"%@%@%@%@",tbItem.scoreRealName,tbItem.scoreRealName,tbItem.scoreRealName,tbItem.scoreRealName];
    //[_imagePhoto sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.myhuiding.com/%@",tbItem.image]]];
}

-(void)LazyTableCellDidSelect:(id)item Path:(NSIndexPath *)path
{
    myTableViewItem *tbItem=item;
    NSLog(@"%@",tbItem.viewControllerDelegate);
    tbItem.scoreRealName=@"select";
    //_lbName.text=@"select";
    [tbItem.tableViewDelegate reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSNumber*)LazyTableCellCanEditRowAtIndexPath:(id)item Path:(NSIndexPath *)path
{
    return @(YES);
}

-(void)LazyTableCellDel:(id)item Path:(NSIndexPath *)path
{
    NSLog(@"%ld",path.row);
}
@end









