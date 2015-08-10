//
//  LazyTableView.m
//  LazyTable
//
//  Created by 孙昕 on 15/2/2.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "LazyTableView.h"
#import "AFNetworking.h"
#import "JSONModel.h"
#import "LazyTableHelp.h"
#import "MJRefresh.h"
#import <objc/runtime.h>
@interface LazyTableView()<UITableViewDataSource,UITableViewDelegate>
{
    __weak id<LazyTableViewDelegate> customDelegate;
    LazyTableHelp *customDataSource;
    NSString* pageParam;
    BOOL bMore;
    NSInteger pageInitIndex;
    NSInteger pageIndex;
    NSMutableDictionary *dicParam;
    NSString *requestUrl;
    LazyTableType tableType;
    NSArray *arrTemp;
    NSDictionary *dicCount;
    BOOL bDisablePage;
    UIView *viewHud;
    UIImageView *imgLoading;
    UIImageView *imgStatus;
    UILabel *lbStatus;
    BOOL bFirstHud;
    UIView *viewParallax;
    NSInteger loadCount;
    NSInteger finishCount;
}
@end
@interface LazyTableBaseSection (WriteItem)
@property  (strong,nonatomic,readwrite) NSMutableArray *arrItem;
@end
@implementation LazyTableView

-(void)setup
{
    customDataSource=[[LazyTableHelp alloc] init];
    customDataSource.delegate=self;
    bDisablePage=NO;
    loadCount=0;
    finishCount=0;
    viewHud=[[UIView alloc] initWithFrame:self.bounds];
    viewHud.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    viewHud.layer.zPosition=MAXFLOAT;
    viewHud.backgroundColor=[UIColor whiteColor];
    [self addSubview:viewHud];
    imgLoading=[[UIImageView alloc] initWithFrame:CGRectZero];
    imgLoading.center=viewHud.center;
    imgLoading.translatesAutoresizingMaskIntoConstraints=NO;
    imgLoading.userInteractionEnabled=YES;
    imgLoading.backgroundColor=[UIColor whiteColor];
    imgLoading.layer.zPosition=MAXFLOAT;
    if(_arrImgHud!=nil)
    {
        imgLoading.animationImages=_arrImgHud;
    }
    else
    {
        imgLoading.animationImages=@[[UIImage imageNamed:@"HUDLoading1.png"],[UIImage imageNamed:@"HUDLoading2.png"],[UIImage imageNamed:@"HUDLoading3.png"],[UIImage imageNamed:@"HUDLoading4.png"],[UIImage imageNamed:@"HUDLoading5.png"],[UIImage imageNamed:@"HUDLoading6.png"],[UIImage imageNamed:@"HUDLoading7.png"]];
    }
    imgLoading.animationDuration=1.0;
    imgLoading.animationRepeatCount=-1;
    [viewHud addSubview:imgLoading];
    [imgLoading addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120]];
    [imgLoading addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterY multiplier:1 constant:-50]];
    imgStatus=[[UIImageView alloc] initWithFrame:CGRectZero];
    imgStatus.hidden=YES;
    imgStatus.center=viewHud.center;
    imgStatus.translatesAutoresizingMaskIntoConstraints=NO;
    imgStatus.userInteractionEnabled=YES;
    imgStatus.backgroundColor=[UIColor whiteColor];
    [viewHud addSubview:imgStatus];
    [imgStatus addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    [imgStatus addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:110]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterY multiplier:1 constant:-50]];
    lbStatus=[[UILabel alloc] initWithFrame:CGRectZero];
    lbStatus.textColor=[UIColor grayColor];
    lbStatus.font=[UIFont fontWithName:lbStatus.font.familyName size:14];
    lbStatus.translatesAutoresizingMaskIntoConstraints=NO;
    lbStatus.numberOfLines=2;
    lbStatus.textAlignment=NSTextAlignmentCenter;
    [viewHud addSubview:lbStatus];
    [lbStatus addConstraint:[NSLayoutConstraint constraintWithItem:lbStatus attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:lbStatus attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:lbStatus attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imgLoading attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
    bFirstHud=YES;
}


-(id)init
{
    if(self=[super init])
    {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if(self=[super initWithFrame:frame style:style])
    {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self=[super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}


-(void)setDelegateAndDataSource:(id<LazyTableViewDelegate>)delegate
{
    self.delegate=customDataSource;
    self.dataSource=customDataSource;
    if([delegate conformsToProtocol:@protocol(LazyTableViewDelegate) ])
    {
        customDelegate=delegate;
    }
}


-(void)registarCell:(NSString*)strCell StrItem:(NSString*)strItem
{
    if(customDataSource.dicCellItem==nil)
    {
        customDataSource.dicCellItem=[[NSMutableDictionary alloc] initWithCapacity:30];
    }
    customDataSource.dicCellItem[strCell]=strItem!=nil?strItem:[NSNull null];
    if(customDataSource.dicCacheCell==nil)
    {
        customDataSource.dicCacheCell=[[NSMutableDictionary alloc] initWithCapacity:30];
    }
    if(customDataSource.dicCellXibExist==nil)
    {
        customDataSource.dicCellXibExist=[[NSMutableDictionary alloc] initWithCapacity:30];
    }
    if([[NSBundle mainBundle] pathForResource:strCell ofType:@"nib"] != nil)
    {
        customDataSource.dicCellXibExist[strCell]=@YES;
    }
    else
    {
        customDataSource.dicCellXibExist[strCell]=@NO;
    }
}

-(void)setPageParam:(NSString*)page Page:(NSInteger)indexPage
{
    pageParam=page;
    pageIndex=indexPage;
    pageInitIndex=indexPage;
}

-(void)reloadRequest:(NSString*)url Param:(NSDictionary*)dic
{
    [self setContentOffset:CGPointMake(0, 0)];
    tableType=LazyTableTypeRequest;
    bMore=NO;
    requestUrl=url;
    dicParam=[[NSMutableDictionary alloc] initWithDictionary:dic];
    if(!bDisablePage)
    {
        dicParam[pageParam]=@(pageInitIndex);
    }
    if(dicCount!=nil)
    {
        dicParam[dicCount[@"name"]]=dicCount[@"value"];
    }
    pageIndex=pageInitIndex;
    [self reload:url Param:dicParam];
}

-(void)reloadMore
{
    bMore=YES;
    if(dicCount==nil)
    {
        if(!bDisablePage)
        {
            dicParam[pageParam]=@(++pageIndex);
        }
    }
    else
    {
        if(!bDisablePage)
        {
            dicParam[pageParam]=@((++pageIndex*[dicCount[@"value"] integerValue])-customDataSource.removeCount);
        }
    }
    [self reload:requestUrl Param:dicParam];
    
}

-(void)reload:(NSString*)url Param:(NSDictionary*)dic
{
    loadCount++;
    customDataSource.removeCount=0;
    if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewWillStartRequest:First:)])
    {
        [customDelegate LazyTableViewWillStartRequest:self First:!bMore];
    }
    if(!bMore && bFirstHud && !imgLoading.isAnimating)
    {
        viewHud.hidden=NO;
        imgLoading.hidden=NO;
        imgStatus.hidden=YES;
        lbStatus.text=@"";
        [imgLoading startAnimating];
    }
    AFHTTPRequestOperationManager *manage=[AFHTTPRequestOperationManager manager];
    manage.requestSerializer = [AFJSONRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manage GET:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         finishCount++;
         if(finishCount!=loadCount)
         {
             return;
         }
         NSString *requestTmp = [NSString stringWithString:operation.responseString];
         NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableContainers error:nil];
         [self initData:dic];
         
     }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         finishCount++;
         if(finishCount!=loadCount)
         {
             return;
         }
         if(self.isHeaderRefreshing)
         {
             [self headerEndRefreshing];
         }
         if(self.isFooterRefreshing)
         {
             [self footerEndRefreshing];
         }
         [imgLoading stopAnimating];
         imgLoading.hidden=YES;
         imgStatus.hidden=NO;
         viewHud.hidden=NO;
         if(_dataErrorImg!=nil)
         {
             imgStatus.image=[UIImage imageNamed:_dataErrorImg];
         }
         else
         {
             imgStatus.image=[UIImage imageNamed:@"DataError.png"];
         }
         if(_dataErrorDes!=nil)
         {
             lbStatus.text=_dataErrorDes;
         }
         else
         {
             lbStatus.text=@"亲，网络貌似傲娇了噢！";
         }
         [self setRefreshShow:YES Footer:NO];
         if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewLoadError:Error:)])
         {
             [customDelegate LazyTableViewLoadError:self Error:error];
         }
     }];
}

-(void)setRefreshShow:(BOOL)bHeader Footer:(BOOL)bFooter
{
    __weak typeof(self) weakSelf=self;
    if(bHeader)
    {
        [self addHeaderWithCallback:^{
            bFirstHud=NO;
            [weakSelf reloadRequest:[weakSelf valueForKey:@"requestUrl"] Param:[weakSelf valueForKey:@"dicParam"]];
            bFirstHud=YES;
        }];
    }
    else
    {
        [self removeHeader];
    }
    if(bFooter)
    {
        [self addFooterWithCallback:^{
            [weakSelf reloadMore];
        }];
    }
    else
    {
        [self removeFooter];
    }
}

-(void)initData:(NSDictionary*)dic
{
    NSArray *arr;
    if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewDidFinishRequest:Request:)])
    {
        arr=[customDelegate LazyTableViewDidFinishRequest:self Request:dic];
    }
    else
    {
        return;
    }
    if(!bMore)
    {
        customDataSource.arrData=[[NSMutableArray alloc] initWithCapacity:30];
    }
    NSMutableArray *arrPath=[[NSMutableArray alloc] initWithCapacity:30];
    LazyTableBaseSection *singleSection=[[LazyTableBaseSection alloc] init];
    LazyTableBaseSection *section=nil;
    int iSectionMoreCount=0;
    for(int i=0;i<arr.count;i++)
    {
        if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewInfoForSection:Request:)])
        {
            section=[customDelegate LazyTableViewInfoForSection:self Request:arr[i]];
        }
        if(section!=nil)
        {
            NSArray *arrData=arr[i][section.data];
            for(int j=0;j<arrData.count;j++)
            {
                NSString *cellId,*itemId;
                if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewSwitchCell:Request:Section:Row:)])
                {
                    cellId=[customDelegate LazyTableViewSwitchCell:self Request:arrData[j] Section:i Row:j];
                }
                if(cellId!=nil)
                {
                    itemId=customDataSource.dicCellItem[cellId];
                }
                else
                {
                    itemId=[[customDataSource.dicCellItem allValues] lastObject];
                    cellId=[[customDataSource.dicCellItem allKeys] lastObject];
                }
                NSError* err=nil;
                Class cls=NSClassFromString( itemId);
                id obj=[[cls alloc] initWithDictionary:arrData[j] error:&err];
                [obj performSelector:@selector(setViewControllerDelegate:) withObject:customDelegate];
                [obj performSelector:@selector(setTableViewDelegate:) withObject:self];
                [obj performSelector:@selector(setSectionDelegate:) withObject:section];
                [obj performSelector:@selector(setCellClassName:) withObject:cellId];
                [ section.arrItem addObject:obj];
            }
            [customDataSource.arrData addObject:section];
            if(bMore)
            {
                iSectionMoreCount++;
                [self insertSections:[NSIndexSet indexSetWithIndex:customDataSource.arrData.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        else
        {
            if(bMore)
            {
                singleSection=customDataSource.arrData[0];
            }
            NSString *cellId,*itemId;
            if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewSwitchCell:Request:Section:Row:)])
            {
                cellId=[customDelegate LazyTableViewSwitchCell:self Request:arr[i] Section:0 Row:i];
            }
            if(cellId!=nil)
            {
                itemId=customDataSource.dicCellItem[cellId];
            }
            else
            {
                itemId=[[customDataSource.dicCellItem allValues] lastObject];
                cellId=[[customDataSource.dicCellItem allKeys] lastObject];
            }
            NSError* err=nil;
            Class cls=NSClassFromString( itemId);
            id obj=[[cls alloc] initWithDictionary:arr[i] error:&err];
            [obj performSelector:@selector(setViewControllerDelegate:) withObject:customDelegate];
            [obj performSelector:@selector(setTableViewDelegate:) withObject:self];
            [obj performSelector:@selector(setSectionDelegate:) withObject:section];
            [obj performSelector:@selector(setCellClassName:) withObject:cellId];
            [ singleSection.arrItem addObject:obj];
            if(bMore)
            {
                NSIndexPath    *newPath =  [NSIndexPath indexPathForRow:singleSection.arrItem.count-1 inSection:0];
                [arrPath addObject:newPath];
            }
            else
            {
                if(i==0)
                {
                    [customDataSource.arrData addObject:singleSection];
                }
            }
        }
    }
    if(!bMore)
    {
        [self reloadData];
    }
    else
    {
        if(section==nil)
        {
            [self insertRowsAtIndexPaths:arrPath withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    self.tableFooterView=[[UIView alloc] init];
    if(self.isHeaderRefreshing)
    {
        [self headerEndRefreshing];
    }
    if(self.isFooterRefreshing)
    {
        [self footerEndRefreshing];
    }
    
    NSInteger count=0;
    if(section==nil)
    {
        if(bMore)
        {
            count=arrPath.count;
        }
        else
        {
            if(customDataSource.arrData.count==0)
            {
                count=0;
            }
            else
            {
                LazyTableBaseSection *sec=customDataSource.arrData[0];
                count=sec.arrItem.count;
            }
        }
    }
    else
    {
        if(bMore)
        {
            count=iSectionMoreCount;
        }
        else
        {
            count=customDataSource.arrData.count;
        }
    }
    if(!bMore)
    {
        if(count==0)
        {
            [self setRefreshShow:YES Footer:NO];
            [imgLoading stopAnimating];
            imgLoading.hidden=YES;
            imgStatus.hidden=NO;
            viewHud.hidden=NO;
            if(_dataEmptyImg!=nil)
            {
                imgStatus.image=[UIImage imageNamed:_dataEmptyImg];
            }
            else
            {
                imgStatus.image=[UIImage imageNamed:@"DataEmpty.png"];
            }
            if(_dataEmptyDes!=nil)
            {
                lbStatus.text=_dataEmptyDes;
            }
            else
            {
                lbStatus.text=@"对不起，让您失望了!";
            }
            
        }
        else
        {
            if(bDisablePage)
            {
                [self setRefreshShow:YES Footer:NO];
            }
            else
            {
                [self setRefreshShow:YES Footer:YES];
            }
            [imgLoading stopAnimating];
            viewHud.hidden=YES;
            if([(UIView*)self.subviews[1] isMemberOfClass:[UIView class]])
            {
                ((UIView*)self.subviews[1]).hidden=YES;
            }
            
        }
    }
    if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewDidFinishLoadData:Count:First:)])
    {
        [customDelegate LazyTableViewDidFinishLoadData:self Count:count First:!bMore];
    }
}

-(void)addSection:(LazyTableBaseSection*)section
{
    tableType=LazyTableTypeManualStatic;
    if(customDataSource.arrData==nil)
    {
        customDataSource.arrData=[[NSMutableArray alloc] initWithCapacity:30];
    }
    [customDataSource.arrData addObject:section];
    
}

-(void)reloadStatic
{
    [imgLoading stopAnimating];
    viewHud.hidden=YES;
    if([(UIView*)self.subviews[1] isMemberOfClass:[UIView class]])
    {
        ((UIView*)self.subviews[1]).hidden=YES;
    }
    [self removeHeader];
    [self removeFooter];
    if(tableType==LazyTableTypeManualStatic)
    {
        for(int i=0;i< customDataSource.arrData.count;i++)
        {
            LazyTableBaseSection *sec=customDataSource.arrData[i];
            for(int j=0;j<sec.arrItem.count;j++)
            {
                id item=sec.arrItem[j];
                NSString *cellId,*itemId;
                if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewSwitchCell:Request:Section:Row:)])
                {
                    cellId=[customDelegate LazyTableViewSwitchCell:self Request:[self getObjectData:item] Section:i Row:j];
                }
                if(cellId!=nil)
                {
                    itemId=customDataSource.dicCellItem[cellId];
                }
                else
                {
                    itemId=[[customDataSource.dicCellItem allValues] lastObject];
                    cellId=[[customDataSource.dicCellItem allKeys] lastObject];
                }
                [item performSelector:@selector(setViewControllerDelegate:) withObject:  customDelegate];
                [item performSelector:@selector(setTableViewDelegate:) withObject:self];
                [item performSelector:@selector(setSectionDelegate:) withObject:sec];
                [item performSelector:@selector(setCellClassName:) withObject:cellId];
            }
        }
        [self reloadData];
        self.tableFooterView=[[UIView alloc] init];
        if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewDidFinishLoadData:Count:First:)])
        {
            [customDelegate LazyTableViewDidFinishLoadData:self Count:customDataSource.arrData.count First:YES];
        }
        
    }
    else if (tableType==LazyTableTypeArrayStatic)
    {
        customDataSource.arrData=[[NSMutableArray alloc] initWithCapacity:30];
        LazyTableBaseSection *singleSection=[[LazyTableBaseSection alloc] init];
        LazyTableBaseSection *section=nil;
        for(int i=0;i<arrTemp.count;i++)
        {
            if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewInfoForSection:Request:)])
            {
                section=[customDelegate LazyTableViewInfoForSection:self Request:arrTemp[i]];
            }
            if(section!=nil)
            {
                NSArray *arrData=arrTemp[i][section.data];
                for(int j=0;j<arrData.count;j++)
                {
                    NSString *cellId,*itemId;
                    if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewSwitchCell:Request:Section:Row:)])
                    {
                        cellId=[customDelegate LazyTableViewSwitchCell:self Request:arrData[j] Section:i Row:j];
                    }
                    if(cellId!=nil)
                    {
                        itemId=customDataSource.dicCellItem[cellId];
                    }
                    else
                    {
                        itemId=[[customDataSource.dicCellItem allValues] lastObject];
                        cellId=[[customDataSource.dicCellItem allKeys] lastObject];
                    }
                    NSError* err=nil;
                    Class cls=NSClassFromString( itemId);
                    id obj=[[cls alloc] initWithDictionary:arrData[j] error:&err];
                    [obj performSelector:@selector(setViewControllerDelegate:) withObject:customDelegate];
                    [obj performSelector:@selector(setTableViewDelegate:) withObject:self];
                    [obj performSelector:@selector(setSectionDelegate:) withObject:section];
                    [obj performSelector:@selector(setCellClassName:) withObject:cellId];
                    [ section.arrItem addObject:obj];
                }
                [customDataSource.arrData addObject:section];
            }
            else
            {
                NSString *cellId,*itemId;
                if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewSwitchCell:Request:Section:Row:)])
                {
                    cellId=[customDelegate LazyTableViewSwitchCell:self Request:arrTemp[i] Section:0 Row:i];
                }
                if(cellId!=nil)
                {
                    itemId=customDataSource.dicCellItem[cellId];
                }
                else
                {
                    itemId=[[customDataSource.dicCellItem allValues] lastObject];
                    cellId=[[customDataSource.dicCellItem allKeys] lastObject];
                }
                NSError* err=nil;
                Class cls=NSClassFromString( itemId);
                id obj=[[cls alloc] initWithDictionary:arrTemp[i] error:&err];
                [obj performSelector:@selector(setViewControllerDelegate:) withObject:customDelegate];
                [obj performSelector:@selector(setTableViewDelegate:) withObject:self];
                [obj performSelector:@selector(setSectionDelegate:) withObject:section];
                [obj performSelector:@selector(setCellClassName:) withObject:cellId];
                [ singleSection.arrItem addObject:obj];
                if(i==0)
                {
                    [customDataSource.arrData addObject:singleSection];
                }
            }
        }
        [self reloadData];
        self.tableFooterView=[[UIView alloc] init];
        if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewDidFinishLoadData:Count:First:)])
        {
            NSInteger count=0;
            if(section==nil)
            {
                LazyTableBaseSection *sec=customDataSource.arrData[0];
                count=sec.arrItem.count;
            }
            else
            {
                count=customDataSource.arrData.count;
            }
            [customDelegate LazyTableViewDidFinishLoadData:self Count:count First:YES];
        }
        
    }
    else if(tableType==LazyTableTypeBlockStatic)
    {
        [self reloadData];
        self.tableFooterView=[[UIView alloc] init];
        if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewDidFinishLoadData:Count:First:)])
        {
            [customDelegate LazyTableViewDidFinishLoadData:self Count:customDataSource.arrData.count First:YES];
        }
        
    }
}

-(void)addDataSource:(NSArray*)arr
{
    tableType=LazyTableTypeArrayStatic;
    arrTemp=arr;
}

-(void)setSectionIndexTitles:(NSArray*)arr
{
    customDataSource.arrSectionTitleIndex=arr;
}

-(NSInteger)getSectionCount
{
    return customDataSource.arrData.count;
}

-(NSInteger)getRowCount
{
    return [[customDataSource.arrData valueForKeyPath:@"@sum.arrItem.@count"] integerValue];
}

-(void)setCountParam:(NSString*)countName Count:(NSInteger)countValue
{
    dicCount=@{
               @"name":countName,
               @"value":@(countValue)
               };
}


-(void)disablePage
{
    bDisablePage=YES;
}

-(NSMutableArray*)getDataSource
{
    return customDataSource.arrData;
}

-(NSMutableDictionary*)getParam
{
    return dicParam;
}

-(void)addStaticCell:(CGFloat)height  CellBlock:(void (^)(id cell))cellBlock ClickBlock:(void (^)(id cell))cellClick
{
    tableType=LazyTableTypeBlockStatic;
    if(customDataSource.arrData==nil)
    {
        customDataSource.arrData=[[NSMutableArray alloc] initWithCapacity:30];
    }
    if(customDataSource.arrData.count==0)
    {
        LazyTableBaseSection *singleSection=[[LazyTableBaseSection alloc] init];
        [customDataSource.arrData addObject:singleSection];
    }
    [((LazyTableBaseSection*)[customDataSource.arrData lastObject]).arrItem addObject:@{
                                                                                        @"height":@(height),
                                                                                        @"cellblock":cellBlock,
                                                                                        @"clickblock":cellClick
                                                                                        }];
}

-(LazyTableType)getTableType
{
    return tableType;
}

-(void)setCellStyle:(UITableViewCellStyle)style
{
    customDataSource.cellStyle=style;
}

-(void)empty
{
    [customDataSource.arrData removeAllObjects];
    [self setRefreshShow:YES Footer:NO];
    [self reloadData];
}

- (NSDictionary*)getObjectData:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

- (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}
@end







