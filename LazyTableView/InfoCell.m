//
//  InfoCell.m
//  LazyTableView
//
//  Created by 孙昕 on 15/6/29.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "InfoCell.h"
#import "infoItem.h"
@implementation InfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

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

@end











