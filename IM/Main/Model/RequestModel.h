//
//  RequestModel.h
//  IM
//
//  Created by student5 on 2019/6/15.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RequestModel : NSObject

@property (strong, nonatomic) UserModel* User;
@property (strong, nonatomic) NSString* State;
@property NSInteger Cid;

- (instancetype)initWithProperties:(UserModel *)User
                             State:(NSString *)State
                               Cid:(NSInteger)Cid;

@end

NS_ASSUME_NONNULL_END
