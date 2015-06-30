//
//  ViewController.m
//  LazyTableView
//
//  Created by 孙昕 on 15/6/29.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "ViewController.h"
#import "InfoCell.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_table1 registarCell:@"InfoCell" StrItem:@"InfoItem"];
    [_table1 setDelegateAndDataSource:self];
    //[_table1 setPageParam:@"pi" Page:2];
    [_table1 disablePage];
    [_table1 reloadRequest:@"http://v5.pc.duomi.com/search-ajaxsearch-searchall" Param:@{
                                     @"kw":@"爱情",
                                     @"pz":@10
                                        }];
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
}

-(NSArray*)LazyTableViewDidFinishRequest:(LazyTableView *)tableview Request:(NSDictionary *)dic
{
    if(tableview==_table1)
    {
        return dic[@"albums"];
    }
    else if(tableview==_table3)
    {
        return (NSArray*)dic;
    }
    return nil;
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end




