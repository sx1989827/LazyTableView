//
//  InfoCell1.m
//  LazyTableView
//
//  Created by 孙昕 on 15/7/6.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "InfoCell1.h"
#import "InfoItem.h"
@interface InfoCell1()
{
    UILabel *lb;
}
@end
@implementation InfoCell1
-(void)initWithCell
{
    lb=[[UILabel alloc] initWithFrame:self.bounds];
    lb.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:lb];
}


-(NSNumber*)LazyTableCellHeight:(id)item Path:(NSIndexPath *)path
{
    return @30;
}

-(void)LazyTableCellForRowAtIndexPath:(id)item Path:(NSIndexPath *)path
{
    InfoItem *data=item;
    lb.text=data.name;
}

@end
