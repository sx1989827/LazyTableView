# LazyTableView
一个可以最大程度简化uitableview操作的第三方框架

UITableView可谓是ios开发里的重中之重了，熟练掌握tableview的程度很大意义上决定着你对ui界面的熟悉程度，不过当逻辑复杂的时候，操作uitableview还是一件挺麻烦的事情，所以本框架旨在可以最大程度的减轻uitableview的繁琐，让程序员们可以更多的去考虑逻辑问题，而不是界面的调整。

# 它可以做什么
1.自动加载远程url的json数据，对于section的解析也不在话下，让用户用更少的代码获得更高的效率。

2.手工创建本地的静态cell，可以自由的控制section和cell的一切。

3.自定义的hud动画可以在加载数据的时候毫无违和感。

# 为什么要使用它
1.简单方便，将大量繁琐的操作封装起来，用户只需几行代码即可获得一个远程数据抓取的tableview。

2.使用delegate模式，这样可以将cell，viewcontroller和data分离开来，一个cell绑定一个dataitem，使用orm将远程的json数据转化为本地的对象。

3.本地静态cell可以使用block创建，并且设置点击事件。

# 耦合性
我使用了AFNetwoking，MJRefresh，JsonModal三个框架来简化代码的编写，如果用户没有使用cocoapods，无需做任何改动，将LazyTableView文件夹拖入项目即可，如果用户使用了cocoapods，则在podfile里加入以下代码：

pod "AFNetworking"

pod "JSONModel"

pod "MJRefresh",'0.0.1'

并且删除LazyTableView里的lib文件夹。


# 如何使用
1.远程url抓取：

拖入一个uitableview，将custom class改为LazyTableView，连接控件变量为table1，在.h文件里引入LazyTableViewDelegate协议，然后在viewcontroller里写入如下代码：

    [_table1 registarCell:@"InfoCell" StrItem:@"InfoItem"];
    [_table1 setDelegateAndDataSource:self];
    //[_table1 setPageParam:@"pi" Page:2];
    [_table1 disablePage];
    [_table1 reloadRequest:@"http://v5.pc.duomi.com/search-ajaxsearch-searchall" Param:@{
                                     @"kw":@"爱情",
                                     @"pz":@10
                                        }];

    -(NSArray*)LazyTableViewDidFinishRequest:(LazyTableView *)tableview Request:(NSDictionary *)dic
      {
        if(tableview==_table1)
        {
           return dic[@"albums"];
        }
        return nil;
      }

建立InfoCell类，继承LazyTableCell，将InfoCell的重用id设置为InfoCell，写入如下代码：

    -(NSNumber*)LazyTableCellHeight:(id)item Path:(NSIndexPath *)path
    {
     return  @80;
    }

    -(void)LazyTableCellForRowAtIndexPath:(id)item Path:(NSIndexPath *)path
    {
         InfoItem *data=item;
        _lbName.text=data.name;
         _lbType.text=data.type;
        _lbDate.text=data.release_date;
    }

建立InfoItem类，继承自LazyTableBaseItem，在h文件里写入属性（这里的名称要与json数据里字段的名称一致，具体可参考jsonmodal的用法）：

    @property (strong,nonatomic) NSString *name;
    @property (strong,nonatomic) NSString *release_date;
    @property (strong,nonatomic) NSString *type;

2.本地自定义静态cell创建，建立tableview过程如上所示，不用建立LazyTableBaseItem的子类，在viewcontroller里写入如下代码：

     [_table2 setDelegateAndDataSource:self];
        [_table2 registarCell:@"InfoCell" StrItem:nil];
        [_table2 addStaticCell:80 CellBlock:^(id cell) {
            InfoCell *cl=cell;
            cl.lbName.text=@"dsf";
            cl.lbType.text=@"dfwwfew";
        } ClickBlock:^(id cell) {
            NSLog(@"123");
        }];
        LazyTableBaseSection *sec=[[LazyTableBaseSection alloc] init];
        sec.headerHeight=100;
        sec.titleHeader=@"sxsx";
        [_table2 addSection:sec];
        [_table2 addStaticCell:80 CellBlock:^(id cell) {
            InfoCell *cl=cell;
            cl.lbName.text=@"123";
            cl.lbType.text=@"dsfsd234";
        } ClickBlock:^(id cell) {
            NSLog(@"zzz");
        }];
        [_table2 reloadStatic];
    
    
3.本地带section的静态数据源的cell创建，其他参考上面，在viewcontroller里写入如下代码：

    [_table3 setDelegateAndDataSource:self];
        [_table3 registarCell:@"myTableViewCell" StrItem:@"myTableViewItem"];
        NSArray* arr=@[
              @{@"we":@"121312",@"data":@[
                        @{
                            @"scoreRealName":@"水电费水电费的"
                            },
                        @{
                            @"scoreRealName":@"水sad电费水电费的"
                            },
                        @{
                            @"scoreRealName":@"asdas水电费水电费的"
                            }
                        ]},
              @{@"we":@"121dasas312",@"data":@[
                        @{
                            @"scoreRealName":@"水电费的"
                            },
                        @{
                            @"scoreRealName":@"水s费水电费的"
                            },
                        @{
                            @"scoreRealName":@"asdas水"
                            }
                        ]},
              @{@"we":@"123s312",@"data":@[
                        @{
                            @"scoreRealName":@"水3443电费的"
                            },
                        @{
                            @"scoreRealName":@"水s费esrse水电费的"
                            },
                        @{
                            @"scoreRealName":@"asdas水3423"
                            }
                        ]},
              @{@"we":@"12",@"data":@[
                        @{
                            @"scoreRealName":@"水gfhf电费的"
                            },
                        @{
                            @"scoreRealName":@"水s费水电hrt费的"
                            },
                        @{
                            @"scoreRealName":@"asdas水7867j"
                            }
                        ]}
              ];
        NSArray *arr1=@[
                        @"a",
                        @"b",
                        @"c",
                        @"d"
                        ];
        [_table3 addDataSource:arr];
        [_table3 setSectionIndexTitles:arr1];
        [_table3 reloadStatic];
        
    -(LazyTableBaseSection*)LazyTableViewInfoForSection:(LazyTableView *)tableview Request:(NSDictionary *)dic
    {
        if(tableview==_table3)
        {
            LazyTableBaseSection *sec=[[LazyTableBaseSection alloc] init];
            sec.titleHeader=dic[@"we"];
            sec.headerHeight=50;
            sec.data=@"data";
            return sec;
        }
        return nil;
    }

4.抓取远程url数据的带section的cell，具体过程如3所示，不同的是需要在LazyTableViewDidFinishRequest里返回section信息所标示的字段名称，且tableview的初始化参考1的初始化方式。

5.本地自定义静态cell的创建（不用block），文件的建立如1所示，在viewcontroller里写入如下代码：

    [_tableMain setDelegateAndDataSource:self];
    [_tableMain registarCell:@"MemberOptionCell" StrItem:@"MemberOptionItem"];
    CustomTableBaseSection *sec=[[CustomTableBaseSection alloc] init];
    MemberOptionItem *item=[[MemberOptionItem alloc] init];
    item.content=@"缴纳保证金";
    item.image=@"finance";
    [sec addRow:item];
    item=[[MemberOptionItem alloc] init];
    item.content=@"消息";
    item.image=@"message";
    [sec addRow:item];
    item=[[MemberOptionItem alloc] init];
    item.content=@"公告";
    item.image=@"notice";
    [sec addRow:item];
    item=[[MemberOptionItem alloc] init];
    item.content=@"系统设置";
    item.image=@"about";
    [sec addRow:item];
    [_tableMain addSection:sec];
    [_tableMain reloadStatic];

# 综述

大致的用法就如上面所述，大家可以下载demo测试下，代码里都有详细的注释,这个框架我会不断完善，自己的app也在使用，希望大家有什么意见和想法可以与我多多交流，我的qq：395414574


