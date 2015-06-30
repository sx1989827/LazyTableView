//
//  infoItem.h
//  LazyTableView
//
//  Created by 孙昕 on 15/6/29.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "LazyTableBaseItem.h"

@interface InfoItem : LazyTableBaseItem
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *release_date;
@property (strong,nonatomic) NSString *type;
@end
