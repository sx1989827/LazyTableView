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
NSArray *arrImgRefreshIdle,*arrImgRefreshPull,*arrImgRefreshRefresh;
NSString *g_EmptyDes,*g_ErrorDes,*g_EmptyImg,*g_ErrorImg;
NSArray *g_arrHudImg;
CGFloat g_ImgHudDuration;
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
    NSInteger maxCount;
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
    _bStatusViewShow=YES;
    _bImgHudShow=YES;
    maxCount=-1;
    viewHud=[[UIView alloc] initWithFrame:self.bounds];
    viewHud.tag=1;
    _viewHud=viewHud;
    viewHud.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    viewHud.layer.zPosition=MAXFLOAT;
    viewHud.backgroundColor=[UIColor whiteColor];
    [self addSubview:viewHud];
    imgLoading=[[UIImageView alloc] initWithFrame:CGRectZero];
    imgLoading.contentMode=UIViewContentModeScaleAspectFill;
    imgLoading.center=viewHud.center;
    imgLoading.translatesAutoresizingMaskIntoConstraints=NO;
    imgLoading.userInteractionEnabled=YES;
    imgLoading.backgroundColor=[UIColor whiteColor];
    imgLoading.layer.zPosition=MAXFLOAT;
    imgLoading.backgroundColor=[UIColor clearColor];
    if(_arrImgHud!=nil)
    {
        imgLoading.animationImages=_arrImgHud;
    }
    else if(g_arrHudImg!=nil)
    {
        imgLoading.animationImages=g_arrHudImg;
    }
    else
    {
        imgLoading.animationImages=@[[UIImage imageNamed:@"HUDLoading1.png"],[UIImage imageNamed:@"HUDLoading2.png"],[UIImage imageNamed:@"HUDLoading3.png"],[UIImage imageNamed:@"HUDLoading4.png"],[UIImage imageNamed:@"HUDLoading5.png"],[UIImage imageNamed:@"HUDLoading6.png"],[UIImage imageNamed:@"HUDLoading7.png"]];
    }
    if(_imgHudDuration!=0)
    {
        imgLoading.animationDuration=_imgHudDuration;
    }
    else if(g_ImgHudDuration!=0)
    {
        imgLoading.animationDuration=g_ImgHudDuration;
    }
    else
    {
        imgLoading.animationDuration=1.0;
    }
    imgLoading.animationRepeatCount=-1;
    [viewHud addSubview:imgLoading];
    [imgLoading addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120]];
    [imgLoading addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:120]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgLoading attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterY multiplier:1 constant:-50]];
    imgStatus=[[UIImageView alloc] initWithFrame:CGRectZero];
    imgStatus.contentMode=UIViewContentModeCenter;
    imgStatus.hidden=YES;
    imgStatus.center=viewHud.center;
    imgStatus.translatesAutoresizingMaskIntoConstraints=NO;
    imgStatus.userInteractionEnabled=YES;
    imgStatus.backgroundColor=[UIColor clearColor];
    [viewHud addSubview:imgStatus];
    [imgStatus addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:110]];
    [imgStatus addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:110]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [viewHud addConstraint:[NSLayoutConstraint constraintWithItem:imgStatus attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewHud attribute:NSLayoutAttributeCenterY multiplier:1 constant:-50]];
    lbStatus=[[UILabel alloc] initWithFrame:CGRectZero];
    lbStatus.textColor=[UIColor grayColor];
    lbStatus.font=[UIFont fontWithName:lbStatus.font.familyName size:14];
    lbStatus.translatesAutoresizingMaskIntoConstraints=NO;
    lbStatus.numberOfLines=2;
    lbStatus.textAlignment=NSTextAlignmentCenter;
    lbStatus.backgroundColor=[UIColor clearColor];
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
    if(!bMore && bFirstHud && !imgLoading.isAnimating && _bImgHudShow)
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
         if(self.mj_header.isRefreshing)
         {
             [self.mj_header endRefreshing];
         }
         if(self.mj_footer.isRefreshing)
         {
             [self.mj_footer endRefreshing];
         }
         [imgLoading stopAnimating];
         imgLoading.hidden=YES;
         imgStatus.hidden=NO;
         viewHud.hidden=NO;
         if(_dataErrorImg!=nil)
         {
             imgStatus.image=[UIImage imageNamed:_dataErrorImg];
         }
         else if(g_ErrorImg!=nil)
         {
             imgStatus.image=[UIImage imageNamed:g_ErrorImg];
         }
         else
         {
             imgStatus.image=[UIImage imageNamed:@"DataError.png"];
         }
         if(_dataErrorDes!=nil)
         {
             lbStatus.text=_dataErrorDes;
         }
         else if(g_ErrorDes!=nil)
         {
             lbStatus.text=g_ErrorDes;
         }
         else
         {
             lbStatus.text=@"亲，网络貌似傲娇了噢！";
         }
         if(!_bStatusViewShow)
         {
             viewHud.hidden=YES;
         }
         else
         {
             viewHud.hidden=NO;
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
        self.mj_header=[MJRefreshGifHeader headerWithRefreshingBlock:^{
            [weakSelf setValue:@NO forKey:@"bFirstHud"];
            [weakSelf reloadRequest:[weakSelf valueForKey:@"requestUrl"] Param:[weakSelf valueForKey:@"dicParam"]];
            [weakSelf setValue:@YES forKey:@"bFirstHud"];
        }];
        if(_arrImgRefreshIdle!=nil || _arrImgRefreshPull!=nil || _arrImgRefreshRefresh!=nil || arrImgRefreshIdle!=nil || arrImgRefreshPull!=nil || arrImgRefreshRefresh!=nil)
        {
            MJRefreshGifHeader *header=(MJRefreshGifHeader*)self.mj_header;
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
            if(_arrImgRefreshIdle!=nil)
            {
                [header setImages:_arrImgRefreshIdle forState:MJRefreshStateIdle];
            }
            else if(arrImgRefreshIdle!=nil)
            {
                [header setImages:arrImgRefreshIdle forState:MJRefreshStateIdle];
            }
            if(_arrImgRefreshPull!=nil)
            {
                [header setImages:_arrImgRefreshPull forState:MJRefreshStatePulling];
            }
            else if(arrImgRefreshPull!=nil)
            {
                [header setImages:arrImgRefreshPull forState:MJRefreshStatePulling];
            }
            if(_arrImgRefreshRefresh!=nil)
            {
                [header setImages:_arrImgRefreshRefresh forState:MJRefreshStateRefreshing];
            }
            else if(arrImgRefreshRefresh!=nil)
            {
                [header setImages:arrImgRefreshRefresh forState:MJRefreshStateRefreshing];
            }
        }
    }
    else
    {
        self.mj_header=nil;
    }
    if(bFooter)
    {
        if(_bAutoRefreshMore)
        {
            self.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [weakSelf reloadMore];
            }];
        }
        else
        {
            self.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weakSelf reloadMore];
            }];
        }
    }
    else
    {
        self.mj_footer=nil;
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
    BOOL bMax=NO;
    for(int i=0;i<arr.count;i++)
    {
        if(customDelegate && [customDelegate respondsToSelector:@selector(LazyTableViewInfoForSection:Request:)])
        {
            section=[customDelegate LazyTableViewInfoForSection:self Request:arr[i]];
        }
        if(maxCount!=-1)
        {
            if([self getRowCount]+1==maxCount)
            {
                bMax=YES;
            }
            else if([self getRowCount]==maxCount)
            {
                break;
            }
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
                iSectionMoreCount+=section.arrItem.count;
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
            [singleSection.arrItem addObject:obj];
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
    if(self.mj_header.isRefreshing)
    {
        [self.mj_header endRefreshing];
    }
    if(self.mj_footer.isRefreshing)
    {
        if(bMore)
        {
            if(arr.count==0)
            {
                [self.mj_footer endRefreshingWithNoMoreData];
            }
            else
            {
                [self.mj_footer endRefreshing];
            }
        }
        else
        {
            [self.mj_footer endRefreshing];
        }
        
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
            for(LazyTableBaseSection *sec in customDataSource.arrData)
            {
                count+=sec.arrItem.count;
            }
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
            else if(g_EmptyImg!=nil)
            {
                imgStatus.image=[UIImage imageNamed:g_EmptyImg];
            }
            else
            {
                imgStatus.image=[UIImage imageNamed:@"DataEmpty.png"];
            }
            if(_dataEmptyDes!=nil)
            {
                lbStatus.text=_dataEmptyDes;
            }
            else if(g_EmptyDes!=nil)
            {
                lbStatus.text=g_EmptyDes;
            }
            else
            {
                lbStatus.text=@"对不起，让您失望了!";
            }
            if(!_bStatusViewShow)
            {
                viewHud.hidden=YES;
            }
            else
            {
                viewHud.hidden=NO;
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
            for(UIView *v in self.subviews)
            {
                if(v.tag==1)
                {
                    v.hidden=YES;
                    break;
                }
            }
        }
    }
    if(bMax)
    {
        self.mj_footer=nil;
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
    for(UIView *v in self.subviews)
    {
        if(v.tag==1)
        {
            v.hidden=YES;
            break;
        }
    }
    self.mj_header=nil;
    self.mj_footer=nil;
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
            if(maxCount!=-1)
            {
                if([self getRowCount]==maxCount)
                {
                    break;
                }
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

-(void)dealloc
{
    if(customDataSource)
    {
        [customDataSource.arrData removeAllObjects];
        [customDataSource.dicCellItem removeAllObjects];
        [customDataSource.dicCacheCell removeAllObjects];
        [customDataSource.dicCellXibExist removeAllObjects];
    }
}

-(void)setMaxCount:(NSInteger)count
{
    maxCount=count;
}

-(void)reload
{
    if(tableType==LazyTableTypeRequest)
    {
        [self setValue:@NO forKey:@"bFirstHud"];
        [self reloadRequest:[self valueForKey:@"requestUrl"] Param:[self valueForKey:@"dicParam"]];
        [self setValue:@YES forKey:@"bFirstHud"];
    }
    else
    {
        [self reloadStatic];
    }
}

+(void)registerImgRefreshIdle:(NSArray*)arr
{
    arrImgRefreshIdle=arr;
}

+(void)registerImgRefreshPull:(NSArray*)arr
{
    arrImgRefreshPull=arr;
}

+(void)registerImgRefreshRefresh:(NSArray*)arr
{
    arrImgRefreshRefresh=arr;
}

+(void)registerDataEmptyDes:(NSString*)str
{
    g_EmptyDes=str;
}

+(void)registerDataErrorDes:(NSString*)str
{
    g_ErrorDes=str;
}

+(void)registerDataEmptyImg:(NSString*)img
{
    g_EmptyImg=img;
}

+(void)registerDataErrorImg:(NSString*)img
{
    g_ErrorImg=img;
}

+(void)registerDataImgHud:(NSArray*)arrImg
{
    g_arrHudImg=arrImg;
}

+(void)registerImgHudDuration:(CGFloat)duration
{
    g_ImgHudDuration=duration;
}
@end







