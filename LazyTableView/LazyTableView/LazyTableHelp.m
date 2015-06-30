//
//  CustomTableDelegate.m
//  CustomTable
//
//  Created by 孙昕 on 15/2/2.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "LazyTableHelp.h"
#import "LazyTableView.h"
#import "LazyTableCellProtocol.h"
#import "LazyTableBaseSection.h"
typedef void (^cellBlock)(id cell);
typedef void (^clickBlock)(id cell);
@interface LazyTableHelp()
{
    id rowHeightCell;
    
}
@end
@implementation LazyTableHelp


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LazyTableBaseSection *sec=_arrData[section];
    return sec.arrItem.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    LazyTableBaseSection *sec=_arrData[section];
    return sec.headerHeight;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrData.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    LazyTableBaseSection *sec=_arrData[section];
    return sec.titleHeader;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LazyTableBaseSection *sec=_arrData[section];
    return sec.viewHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(rowHeightCell==nil)
    {
        NSArray *arr=[[NSBundle mainBundle] loadNibNamed:_reuseId owner:nil options:nil];
        if(arr.count!=0)
        {
            rowHeightCell=[arr lastObject];
        }
    }
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    CGFloat height=0;
    if([_delegate getTableType]==LazyTableTypeBlockStatic)
    {
        height=[sec.arrItem[indexPath.row][@"height"] floatValue];
    }
    else
    {
        if([rowHeightCell respondsToSelector:@selector(LazyTableCellHeight:Path:)])
        {
            height=[[rowHeightCell performSelector:@selector(LazyTableCellHeight:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath] floatValue];
        }
    }
    return height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:_reuseId];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:_reuseId owner:nil options:nil] lastObject];
    }
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    if([_delegate getTableType]==LazyTableTypeBlockStatic)
    {
        cellBlock block=sec.arrItem[indexPath.row][@"cellblock"];
        block(cell);
    }
    else
    {
        if([cell respondsToSelector:@selector(LazyTableCellForRowAtIndexPath:Path:)])
        {
            [cell performSelector:@selector(LazyTableCellForRowAtIndexPath:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath];
        }
    }
    
    return  cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    if([_delegate getTableType]==LazyTableTypeBlockStatic)
    {
        clickBlock block=sec.arrItem[indexPath.row][@"clickblock"];
        block(cell);
    }
    else
    {
        if([cell respondsToSelector:@selector(LazyTableCellDidSelect:Path:)])
        {
            [cell performSelector:@selector(LazyTableCellDidSelect:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath];
        }
    }
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    if([cell respondsToSelector:@selector(LazyTableCellCanEditRowAtIndexPath:Path:)])
    {
        return [[cell performSelector:@selector(LazyTableCellCanEditRowAtIndexPath:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath] boolValue];
    }
    else
    {
        return NO;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        LazyTableBaseSection *sec=_arrData[indexPath.section];
        if([cell respondsToSelector:@selector(LazyTableCellDel:Path:)])
        {
            [cell performSelector:@selector(LazyTableCellDel:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath];
            [sec.arrItem removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];
        }
        _removeCount++;
    }
    
}

-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _arrSectionTitleIndex;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    LazyTableBaseSection *sec=_arrData[section];
    return sec.footerHeight;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    LazyTableBaseSection *sec=_arrData[section];
    return sec.titleFooter;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    LazyTableBaseSection *sec=_arrData[section];
    return sec.viewFooter;
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    if([cell respondsToSelector:@selector(LazyTableCellDidDeselect:Path:)])
    {
        [cell performSelector:@selector(LazyTableCellDidDeselect:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollViewDidScroll" object:nil];
}
@end














