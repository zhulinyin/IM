//
//  UserManager.h
//  IM
//
//  Created by zhulinyin on 2019/5/11.
//  Copyright © 2019 zhulinyin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Main/Model/UserModel.h"
#import <UIKit/UIKit.h>
#import "SocketRocketUtility.h"
#import "URLHelper.h"
#import <AFNetworking/AFNetworking.h>
#import "MainViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject
@property(strong, nonatomic) NSString *loginUserId;
@property NSInteger seq;
+(instancetype) getInstance;
-(void) login:(NSString *)username withPassword:(NSString *)password;
-(void) register:(NSString *)username withPassword:(NSString *)password;
-(void) modifyInfo:(NSString *)attr withValue:(NSString *)value;
-(void) uploadImage:(NSString* )path withImage:(UIImage* )image;
-(void) sendImage:(NSString* )path withImage:(UIImage* )image
       withToUser:(NSString* )userName withDate:(NSDate* )date;
-(void) getInfo;
-(UserModel*) getLoginModel;
-(void) logout;
-(void) tryLogin;
@end

NS_ASSUME_NONNULL_END
