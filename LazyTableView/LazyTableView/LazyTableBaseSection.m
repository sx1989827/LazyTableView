//
//  LazyTableBaseSection.m
//  LazyTable
//
//  Created by 孙昕 on 15/2/5.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "LazyTableBaseSection.h"
@interface LazyTableBaseSection()
@property  (strong,nonatomic,readwrite) NSMutableArray *arrItem;
@end
@implementation LazyTableBaseSection
-(id)init
{
    if(self=[super init])
    {
        _arrItem=[[NSMutableArray alloc] initWithCapacity:30];
    }
    return self;
}

-(void)addRow:(id)item
{
    [_arrItem addObject:item];
}
@end













