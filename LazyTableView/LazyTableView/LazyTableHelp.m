//
//  LazyTableDelegate.m
//  LazyTable
//
//  Created by 孙昕 on 15/2/2.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "LazyTableHelp.h"
#import "LazyTableView.h"
#import "LazyTableCellProtocol.h"
#import "LazyTableBaseSection.h"
#import "LazyTableBaseItem.h"
typedef void (^cellBlock)(id cell);
typedef void (^clickBlock)(id cell);
@interface LazyTableHelp()

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
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    CGFloat height=0;
    if([_delegate getTableType]==LazyTableTypeBlockStatic)
    {
        height=[sec.arrItem[indexPath.row][@"height"] floatValue];
    }
    else
    {
        LazyTableBaseItem *item=sec.arrItem[indexPath.row];
        UITableViewCell *rowHeightCell=_dicCacheCell[item.cellClassName];
        if(rowHeightCell==nil)
        {
            if([_dicCellXibExist[item.cellClassName] boolValue])
            {
                NSArray *arr=[[NSBundle mainBundle] loadNibNamed:item.cellClassName owner:nil options:nil];
                if(arr.count!=0)
                {
                    rowHeightCell=[arr lastObject];
                    _dicCacheCell[item.cellClassName]=rowHeightCell;
                }
            }
            else
            {
                Class cls=NSClassFromString(item.cellClassName);
                rowHeightCell=[[cls alloc] initWithStyle:_cellStyle reuseIdentifier:item.cellClassName];
            }
        }
        if([rowHeightCell respondsToSelector:@selector(LazyTableCellHeight:Path:)])
        {
            height=[[rowHeightCell performSelector:@selector(LazyTableCellHeight:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath] floatValue];
        }
    }
    
    return height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    UITableViewCell *cell;
    if([_delegate getTableType]==LazyTableTypeBlockStatic)
    {
        NSString *cellId=[[_dicCellItem allKeys] lastObject];
        cell=[tableView dequeueReusableCellWithIdentifier:cellId];
        if(cell==nil)
        {
            if([_dicCellXibExist[cellId] boolValue])
            {
                NSArray *arr=[[NSBundle mainBundle] loadNibNamed:cellId owner:nil options:nil];
                if([arr count]!=0)
                {
                    cell=[arr lastObject];
                }
            }
            else
            {
                Class cls=NSClassFromString(cellId);
                cell=[[cls alloc] initWithStyle:_cellStyle reuseIdentifier:cellId];
            }
        }
        cellBlock block=sec.arrItem[indexPath.row][@"cellblock"];
        block(cell);
    }
    else
    {
        LazyTableBaseItem *item=sec.arrItem[indexPath.row];
        cell=[tableView dequeueReusableCellWithIdentifier:item.cellClassName];
        if(cell==nil)
        {
            if([_dicCellXibExist[item.cellClassName] boolValue])
            {
                NSArray *arr=[[NSBundle mainBundle] loadNibNamed:item.cellClassName owner:nil options:nil];
                if([arr count]!=0)
                {
                    cell=[arr lastObject];
                }
            }
            else
            {
                Class cls=NSClassFromString(item.cellClassName);
                cell=[[cls alloc] initWithStyle:_cellStyle reuseIdentifier:item.cellClassName];
            }
        }
        if([cell respondsToSelector:@selector(LazyTableCellForRowAtIndexPath:Path:)])
        {
            [cell performSelector:@selector(LazyTableCellForRowAtIndexPath:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath];
        }
    }
    return  cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            if(sec.arrItem.count==0)
            {
                [_arrData removeObject:sec];
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];
            }
            
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    LazyTableBaseSection *sec=_arrData[indexPath.section];
    if([cell respondsToSelector:@selector(LazyTableCellDidDeselect:Path:)])
    {
        [cell performSelector:@selector(LazyTableCellDidDeselect:Path:) withObject:sec.arrItem[indexPath.row] withObject:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewDidZoom:)])
    {
        [delegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
    {
        [delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
    {
        return [delegate viewForZoomingInScrollView:scrollView];
    }
    else
    {
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
         [delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
         [delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
    {
        return [delegate scrollViewShouldScrollToTop:scrollView];
    }
    else
    {
        return YES;
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    id<LazyTableViewDelegate> delegate=[_delegate valueForKey:@"customDelegate"];
    if(delegate && [delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
    {
        [delegate scrollViewDidScrollToTop:scrollView];
    }
}
@end














