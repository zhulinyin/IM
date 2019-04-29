//
//  UserModel.h
//  IM
//
//  Created by Ray Shaw on 2019/4/27.
//  Copyright © 2019年 zhulinyin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject

@property (weak, nonatomic) NSString* UserID;
@property (weak, nonatomic) NSString* NickName;
@property (weak, nonatomic) NSString* RemarkName;
@property (weak, nonatomic) NSString* Gender;
@property (weak, nonatomic) NSString* Birthplace;
@property (weak, nonatomic) NSString* ProfilePicture;

- (instancetype)initWithProperties:(NSString *)UserID
                          NickName:(NSString *)NickName
                        RemarkName:(NSString *)RemarkName
                            Gender:(NSString *)Gender
                        Birthplace:(NSString *)Birthplace
                        ProfilePicture:(NSString *)ProfilePicture;


@end

NS_ASSUME_NONNULL_END
