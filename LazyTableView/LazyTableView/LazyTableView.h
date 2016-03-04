//
//  CustomTableView.h
//  CustomTable
//
//  Created by 孙昕 on 15/2/2.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LazyTableCellProtocol.h"
#import "LazyTableBaseSection.h"
@class LazyTableView;
typedef enum
{
    LazyTableTypeRequest,  //远程数据抓取的类型，使用reloadRequest
    LazyTableTypeManualStatic, //本地手工创建静态cell，需要addSection和reloadStatic结合使用
    LazyTableTypeArrayStatic,  //本地手工加载array的静态cell，需要addDataSource和reloadStatic结合使用
    LazyTableTypeBlockStatic   //本地手工使用block加载处理静态cell，需要addStaticCell和reloadStatic结合使用
}LazyTableType;
@protocol LazyTableViewDelegate<UITableViewDelegate,UITableViewDataSource>
/**
 *  即将开始远程抓取
 *
 *  @param tableview 当前的tableview
 *  @param bFirst    是否为初始加载还是加载更多
 */
-(void)LazyTableViewWillStartRequest:(LazyTableView*)tableview First:(BOOL)bFirst;
/**
 *  完成了远程抓取
 *
 *  @param tableview 当前的tableview
 *  @param dic       抓取到的dictionary类型数据
 *
 *  @return 返回一个array类型数据以供加载
 */
-(NSArray*)LazyTableViewDidFinishRequest:(LazyTableView*)tableview Request:(NSDictionary*)dic;
/**
 *  完成了加载
 *
 *  @param tableview 当前的tableview
 *  @param count     当前row的数量
 *  @param bFirst    是否为初始加载还是加载更多
 */
-(void)LazyTableViewDidFinishLoadData:(LazyTableView*)tableview Count:(NSInteger)count First:(BOOL)bFirst;
/**
 *  当加载出现错误时或者网络异常时
 *
 *  @param tableview 当前的tableview
 *  @param err       错误描述
 */
-(void)LazyTableViewLoadError:(LazyTableView*)tableview Error:(NSError*)err;
/**
 *  需要section时，通过dic的数据创建section并且返回
 *
 *  @param tableview 当前的tableview
 *  @param dic       抓取到的dictionary类型数据
 *
 *  @return 返回section
 */
-(LazyTableBaseSection*)LazyTableViewInfoForSection:(LazyTableView*)tableview Request:(NSDictionary*)dic;
/**
 *  在多个cell间切换，根据当前的item字典数据和section以及row来决定加载哪一个cell。
 *
 *  @param tableview 当前的tableview
 *  @param item      当前的item字典数据
 *  @param section   当前的section
 *  @param row       当前的row
 *
 *  @return 返回cell的类名称
 */
-(NSString*)LazyTableViewSwitchCell:(LazyTableView*)tableview Request:(NSDictionary*)item Section:(NSInteger)section Row:(NSInteger)row;
@end
@interface LazyTableView : UITableView
/**
 *  注册cell和item，cell为自定义cell类的名称，item为绑定的数据的类
 *
 *  @param strCell cell为继承LazyTableCell的cell
 *  @param strItem item为继承LazyTableBaseItem的item
 */
-(void)registarCell:(NSString*)strCell StrItem:(NSString*)strItem;
/**
 *  设置分页字段的名称和起始数值
 *
 *  @param page      分页字段的名称
 *  @param indexPage 起始值
 */
-(void)setPageParam:(NSString*)page Page:(NSInteger)indexPage;
/**
 *  设置每页的数据的个数，如果设置了这个字段，则start=page，page变为起始位置，每次抓取按照start=start+count来抓取
 *
 *  @param countName  每页个数的字段名称
 *  @param countValue 每页个数的数值
 */
-(void)setCountParam:(NSString*)countName Count:(NSInteger)countValue;
/**
 *  抓取远程数据并加载，目前只支持get抓取
 *
 *  @param url url地址
 *  @param dic url的参数
 */
-(void)reloadRequest:(NSString*)url Param:(NSDictionary*)dic;
/**
 *  加载本地静态数据
 */
-(void)reloadStatic;
/**
 *  设置LazyTableView的delegate
 *
 *  @param delegate LazyTableView的delegate
 */
-(void)setDelegateAndDataSource:(id<LazyTableViewDelegate>)delegate;
/**
 *  添加一个section
 *
 *  @param section
 */
-(void)addSection:(LazyTableBaseSection*)section;
/**
 *  添加本地的静态array
 *
 *  @param arr
 */
-(void)addDataSource:(NSArray*)arr;
/**
 *  设置SectionIndexTitles
 *
 *  @param arr
 */
-(void)setSectionIndexTitles:(NSArray*)arr;
/**
 *  获取当前section的个数
 *
 *  @return section的个数
 */
-(NSInteger)getSectionCount;
/**
 *  获取当前row的个数
 *
 *  @return row的个数
 */
-(NSInteger)getRowCount;
/**
 *  当前网络抓取为一次性抓取全部数据，没有分页
 */
-(void)disablePage;
/**
 *  获取当前的DataSource
 *
 *  @return 当前的DataSource
 */
-(NSMutableArray*)getDataSource;
/**
 *  获取当前远程抓取的url的参数
 *
 *  @return 远程抓取的url的参数
 */
-(NSMutableDictionary*)getParam;
/**
 *  添加静态cell，无需添加item，在registarCell时将item设为nil，采用block的方式，注意循环引用
 *
 *  @param height    cell的高度
 *  @param cellBlock cell内容的赋值
 *  @param cellClick cell点击的处理
 */
-(void)addStaticCell:(CGFloat)height  CellBlock:(void (^)(id cell))cellBlock ClickBlock:(void (^)(id cell))cellClick;
/**
 *  获取当前tableview的类型
 *
 *  @return tableview的类型
 */
-(LazyTableType)getTableType;
/**
 *  当cell由代码创建的时候，设置cell的style
 *
 *  @param style cell的style
 */
-(void)setCellStyle:(UITableViewCellStyle)style;
/**
 *  清空当前tableview的cell和数据
 */
-(void)empty;
/**
 *  设置最多显示的cell数
 *
 *  @param count 最多显示的cell数
 */
-(void)setMaxCount:(NSInteger)count;
/**
 *  按照初始化的数据重新加载
 */
-(void)reload;
/**
 *  加载完成或者错误时提示的view是否显示
 */
@property (assign,nonatomic) BOOL bStatusViewShow;
/**
 *  加载动画是否显示
 */
@property (assign,nonatomic) BOOL bImgHudShow;
/**
 *  当tableview数据为空的时候显示的文字描述
 */
@property (strong,nonatomic) NSString* dataEmptyDes;
/**
 *  当网络发生错误的时候显示的文字描述
 */
@property (strong,nonatomic) NSString* dataErrorDes;
/**
 *  当tableview数据为空的时候显示的图片
 */
@property (strong,nonatomic) NSString* dataEmptyImg;
/**
 *  当网络发生错误的时候显示的图片
 */
@property (strong,nonatomic) NSString* dataErrorImg;
/**
 *  设置自定义hud图片数组
 */
@property (strong,nonatomic) NSArray* arrImgHud;
/**
 *  自定义hud图片动画间隔时间
 */
@property (assign,nonatomic) CGFloat imgHudDuration;
/**
 *  hud View
 */
@property (strong,nonatomic) UIView* viewHud;
/**
 *  设置下拉刷新普通状态的动画图片
 */
@property (strong,nonatomic) NSArray* arrImgRefreshIdle;
/**
 *  设置即将刷新状态的动画图片
 */
@property (strong,nonatomic) NSArray* arrImgRefreshPull;
/**
 *  设置正在刷新状态的动画图片
 */
@property (strong,nonatomic) NSArray* arrImgRefreshRefresh;
/**
 *  列表滚动到尾部是否自动加载更多
 */
@property (assign,nonatomic) BOOL bAutoRefreshMore;
/**
 *  设置全局即将刷新状态的动画图片
 *
 *  @param arr 图片数组
 */
+(void)registerImgRefreshIdle:(NSArray*)arr;
/**
 *  设置全局即将刷新状态的动画图片
 *
 *  @param arr 图片数组
 */
+(void)registerImgRefreshPull:(NSArray*)arr;
/**
 *  设置全局正在刷新状态的动画图片
 *
 *  @param arr 图片数组
 */
+(void)registerImgRefreshRefresh:(NSArray*)arr;
+(void)registerDataEmptyDes:(NSString*)str;
+(void)registerDataErrorDes:(NSString*)str;
+(void)registerDataEmptyImg:(NSString*)img;
+(void)registerDataErrorImg:(NSString*)img;
+(void)registerDataImgHud:(NSArray*)arrImg;
+(void)registerImgHudDuration:(CGFloat)duration;
@end






