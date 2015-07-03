//
//  MemberHeaderView.m
//  RunMan-User
//
//  Created by 孙昕 on 15/5/25.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import "MemberHeaderView.h"
@implementation MemberHeaderView

-(void)awakeFromNib
{
    _btnPhoto.layer.masksToBounds=YES;
    _btnPhoto.layer.cornerRadius=40;
    UITapGestureRecognizer *tap1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBalance)];
    [_viewBalance addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCredit)];
    [_viewCredit addGestureRecognizer:tap2];
}

-(void)tapBalance
{
    
}

-(void)tapCredit
{
   
}

- (IBAction)onPhoto:(id)sender
{
    
}




@end







