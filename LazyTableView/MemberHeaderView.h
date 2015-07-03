//
//  MemberHeaderView.h
//  RunMan-User
//
//  Created by 孙昕 on 15/5/25.
//  Copyright (c) 2015年 孙昕. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberHeaderView : UIView
@property (strong, nonatomic) IBOutlet UIButton *btnPhoto;
- (IBAction)onPhoto:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lbBalance;
@property (strong, nonatomic) IBOutlet UILabel *lbCredit;
@property (strong, nonatomic) IBOutlet UIButton *btnUp;
@property (strong, nonatomic) IBOutlet UIButton *btnDown;
@property (strong, nonatomic) IBOutlet UIView *viewBalance;
@property (strong, nonatomic) IBOutlet UIView *viewCredit;



@end
