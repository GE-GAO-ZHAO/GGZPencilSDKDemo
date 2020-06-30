//
//  SCTRobotPencilParingManager.h
//  SCTutorialOnline
//
//  Created by xes on 2019/9/18.
//  Copyright © 2019 易博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RobotPenManager.h"
#import "RobotPenHeader.h"

@protocol SCTRobotPencilParingManagerDelegate <NSObject>

//->>>>>>>>>>>>>>>>>>>>>>>>>>> 添加设备需要实现 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/**
 发现设备
 @param device device description
 */
- (void)resultScanGetDevice:(RobotPenDevice *)device;

//->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

@end

@interface SCTRobotPencilParingManager : NSObject

@property (nonatomic,weak) id<SCTRobotPencilParingManagerDelegate> delegate;

/**
 -单例
 */
+ (instancetype)shareManager;

/**
 初始化 robot pencil
 */
- (void)initPencilConfig;

/**
 配置白板的尺寸,用于换算点数据
 */
- (void)configWhiteBoardSize:(CGSize)whiteBoardSize;

/**
 -扫描设备
 */
- (void)scanDevice;

/**
 -配对指定设备
 */
- (void)connecteSpcialDeviceWithDeviceModel:(RobotPenDevice *)device;

/**
 -断开指定连接中设备
 */
- (void)disConnecteSpcialDeviceWithDeviceModel:(RobotPenDevice *)device;

/**
 -是否存在连接的设备
 */
- (BOOL)isExciteOnConnectedDevice;

/**
 获取当前正处于连接的设备
 */
- (RobotPenDevice *)getConnectDevice;

/**
 销毁单例
 */
- (void)destoryRobotPencilInstence;

/*!
 获取当前的系统服务状态：蓝牙、USB 的连接状态
 
 @result 返回结果
 */
- (OSDeviceStateType)getCurrentDeviceBlueToothState;

#pragma mark - 配对设备相关---------
/*!
 @method
 @abstract 检查是否有配对过的设备
 @discussion 蓝牙（BLE）专用
 @result 返回结果
 */
- (BOOL)checkIsHaveMatch;

/*!
 @method
 @abstract 获取配对设备列表
 @discussion 蓝牙（BLE）专用
 @result 返回结果
 */
- (NSArray *)getPairingDevice;

/*!
 @method
 @abstract 获取设备列表
 @result 返回结果
 */
- (NSArray *)getDeviceSearchList;

/**
 获取所有设备： 配对设备列表和为配对设备列表

 @return 设备列表
 */
- (NSMutableArray *)getAllDeviceListCanConnected;

/*!
 @method
 @abstract  清空之前所有配对设备
 @discussion 蓝牙（BLE）专用
 */
- (void)cleanAllPairingDeviceBeforeConnected;

@end
