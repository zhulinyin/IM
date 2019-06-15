//
//  RequestModel.m
//  IM
//
//  Created by student5 on 2019/6/15.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import "RequestModel.h"

@implementation RequestModel

- (instancetype)initWithProperties:(UserModel *)User
                             State:(NSString *)State
                               Cid:(NSInteger)Cid
{
    self = [super init];
    if (self)
    {
        self.User = User;
        self.State = State;
        self.Cid = Cid;
    }
    return self;
}

@end
