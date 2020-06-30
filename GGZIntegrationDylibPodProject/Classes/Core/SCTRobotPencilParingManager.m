//
//  SCTRobotPencilParingManager.m
//  SCTutorialOnline
//
//  Created by xes on 2019/9/18.
//  Copyright © 2019 易博. All rights reserved.
//

#import "SCTRobotPencilParingManager.h"

@interface SCTRobotPencilParingManager()<RobotPenDelegate>

/*
 当前使用中的设备
 */
@property (nonatomic,strong) RobotPenDevice *device;

/*
 当前作用的白板尺寸
 */
@property (nonatomic,assign) CGSize currentWhiteBoardSize;

/*
 正在等待连接的设备列表
 */
@property (nonatomic,strong) NSMutableArray <RobotPenDevice *>*waitingConnectDeviceList;

@end

@implementation SCTRobotPencilParingManager


static SCTRobotPencilParingManager *shareManager = nil;
static dispatch_once_t onceToken;

#pragma mark - system class mothods
+ (instancetype)shareManager {
    dispatch_once(&onceToken, ^{
        shareManager = [[SCTRobotPencilParingManager alloc] init];
    });
    
    return shareManager;
}

#pragma mark - local class mothods
/**
 初始化 robot pencil
 */
- (void)initPencilConfig {
    
    // 遵守RobotPenManager协议，必须实现
    [[RobotPenManager sharePenManager] setPenDelegate:self];
    
    // 自动连接，使用这个功能需要提前配置自动连接记录
    [[RobotPenManager sharePenManager] AutoCheckDeviceConnect];
    
}

/**
 配置白板的尺寸,用于换算点数据
 */
- (void)configWhiteBoardSize:(CGSize)whiteBoardSize {
    
    // 保存当前的白板尺寸
    self.currentWhiteBoardSize = whiteBoardSize;
    
    // SDK方法 设置报点类型，此处设置为优化点报点
    [[RobotPenManager sharePenManager] setOrigina:NO optimize:YES transform:NO];
    
    // SDK方法 设置自动连接
    [[RobotPenManager sharePenManager] AutoCheckDeviceConnect];

}

/**
 -扫描设备
 */
- (void)scanDevice {
    
    // 搜索设备 是否搜索全部（未连接）设备，默认为NO(只搜索可配对与可连接状态);
    [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
}

/**
 -配对指定设备
 */
- (void)connecteSpcialDeviceWithDeviceModel:(RobotPenDevice *)device {
    
//    NSLog(@"配对的设备名字：%@",device.deviceName);
    
    // 1. 如果要连接的设备在配对记录列表，就移除掉（不移除，连接会报重复连接的错误）
    if ([[RobotPenManager sharePenManager] getIsPairedWithDevice:device]) {
        
        [[RobotPenManager sharePenManager] deletePairingMacDevice:device];
    }
    
    // 2.1 如果当前存在正在使用中的设备： 1.保存进入待连接  2. 先断开当前连接的设备 3. 如果当前设备之前配对过，从配对记录列表删除 4. 等待断开结果成功进行新设备的连接。
    // 2.2 如果不存在正在使用中的设备：   直接进入接连新设备
    if ([self getConnectDevice]) {
        
        [self.waitingConnectDeviceList addObject:device];
        
        [[RobotPenManager sharePenManager] disconnectDevice];
        
    }else {

        //连接设备
        [[RobotPenManager sharePenManager] connectDevice:device];
    }
    

}

/**
 -断开指定连接中设备
 */
- (void)disConnecteSpcialDeviceWithDeviceModel:(RobotPenDevice *)device {
    
    [[RobotPenManager sharePenManager] deletePairingMacDevice:device];
}

/**
 -是否存在连接的设备
 */
- (BOOL)isExciteOnConnectedDevice {
    
    return [[RobotPenManager sharePenManager] getConnectDevice] ? YES : NO;
}

/**
 获取当前正处于连接的设备
 */
- (RobotPenDevice *)getConnectDevice {
    
    return [[RobotPenManager sharePenManager] getConnectDevice];
}

/**
 销毁单例
 */
- (void)destoryRobotPencilInstence {
    
    [[RobotPenManager sharePenManager] disconnectDevice];
    self.delegate = nil;
}

/*!
 获取当前的系统服务状态
 
 @result 返回结果
 */
- (OSDeviceStateType)getCurrentDeviceBlueToothState {
    
    return [[RobotPenManager sharePenManager] getOSDeviceState];
}

/*!
 @method
 @abstract 检查是否有配对过的设备
 @discussion 蓝牙（BLE）专用
 @result 返回结果
 */
- (BOOL)checkIsHaveMatch {
    
    return [[RobotPenManager sharePenManager] checkIsHaveMatch];
}

/*!
 @method
 @abstract 获取配对设备列表
 @discussion 蓝牙（BLE）专用
 @result 返回结果
 */
- (NSArray *)getPairingDevice {
    
    return [[RobotPenManager sharePenManager] getPairingDevice];
}

/*!
 @method
 @abstract 获取设备列表
 @result 返回结果
 */
- (NSArray *)getDeviceSearchList {
    
    return [[RobotPenManager sharePenManager] getDeviceSearchList];
}

/*!
 @method
 @abstract  清空之前所有配对设备
 @discussion 蓝牙（BLE）专用
 */
- (void)cleanAllPairingDeviceBeforeConnected {
    
    [[RobotPenManager sharePenManager] cleanAllPairingDevice];
}

/**
 获取所有设备： 配对设备列表和为配对设备列表
 
 @return 设备列表
 */
- (NSMutableArray *)getAllDeviceListCanConnected {
    
    // 定义数据源
    __block NSMutableArray * tempArr = [[NSMutableArray alloc] init];
    
    // 1. 获取连接过的设备列表
    NSArray * paringDeviceList = [self getPairingDevice];
    if (paringDeviceList && [paringDeviceList respondsToSelector:@selector(count)] && paringDeviceList.count > 0) {
        
        [paringDeviceList enumerateObjectsUsingBlock:^(RobotPenDevice * tempDevice, NSUInteger idx, BOOL * _Nonnull stop) {
            if (1 == tempDevice.Tags && tempDevice.peripheral) {
                
                // 添加操作：在搜索列表
                [tempArr addObject:tempDevice];
            }

        }];
    }
    
    // 2. 获取未连接过，但是可以配对的设备列表
    NSArray * searchNotHaveParingDeviceList = [self getDeviceSearchList];
    if (searchNotHaveParingDeviceList && [searchNotHaveParingDeviceList respondsToSelector:@selector(count)] && searchNotHaveParingDeviceList.count > 0) {
        
        [searchNotHaveParingDeviceList enumerateObjectsUsingBlock:^(RobotPenDevice * tempDevice, NSUInteger idx, BOOL * _Nonnull stop) {
            
            __block BOOL isExcite = NO; // 默认不存在
            [tempArr enumerateObjectsUsingBlock:^(RobotPenDevice * resTempDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([resTempDevice.uuID isEqualToString:tempDevice.uuID]) {
                    isExcite = YES;
                    *stop = YES;
                }
            }];
            
            // 添加操作：不存在 && 在搜索列表
            if (!isExcite && 1 == tempDevice.Tags && tempDevice.peripheral) {
                [tempArr addObject:tempDevice];
            }
            
        }];
    }

    return tempArr;
}

/**
 查找是否存在某个设备
 
 @param arrayParam : 数组  deviceUUID : 设备uuid
 @return 结果
 */
- (RobotPenDevice *)isExistSqcialDeviceWithArray:(NSArray *)arrayParam deviceUUID:(NSString *)deviceUUid {
    
    __block RobotPenDevice *resDevice = nil;
    [arrayParam enumerateObjectsUsingBlock:^(RobotPenDevice * tempDevice, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([tempDevice.uuID isEqualToString:deviceUUid]) {
            
            resDevice = tempDevice;
            *stop = YES;
        }
        
    }];
    
    return resDevice;
    
}

#pragma mark - ========== RobotPenSDK 笔服务协议 ===========
#pragma mark - ---------- 基础协议 ----------

/*!
 @method
 @abstract 监听系统状态
 @param State 状态
 */
- (void)getOSDeviceState:(OSDeviceStateType)State {
    
    // 通知UI层处理
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resultGetOSBlueToothState" object:[NSString stringWithFormat:@"%u",State]];
}

/*!
 @method
 @abstract 获取原始点数据 （使用于白板、笔）
 @param point 原始点
 */
-(void)getPointInfo:(RobotPenPoint *)point {
    
    if (point) {
        
        // 上报原始点
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resultDrewGetOriginPointInfo" object:point];
    }

}

/*!
 @method
 @abstract 获取优化点数据 （笔）
 @param point 即为优化点数据模型
 */
- (void)getOptimizesPointInfo:(RobotPenUtilPoint *)point {

    if (point) {
        //此时获取到的坐标为原始坐标点在左上角的原始点

        //转换为右上角坐标原点
        CGPoint tpoint = [point getTransformsPointWithType:(RobotPenCoordinateUpperRight) SceneSize:self.currentWhiteBoardSize];
        point.optimizeX = tpoint.x;
        point.optimizeY = tpoint.y;
        
        // 上报优化点
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resultDrewGetOptimizePointInfo" object:point];
        
    }
    
}

/**
 发现设备
 @param device device description
 */
- (void)getBufferDevice:(RobotPenDevice *)device {
    
    // 返回出去
    if ([self.delegate respondsToSelector:@selector(resultScanGetDevice:)]) {
        [self.delegate resultScanGetDevice:device];
    }
}

/**
 获取设备状态 （设备连接状态 ）
 @param State State description
 */
- (void)getDeviceState:(DeviceState)State DeviceUUID:(NSString *)uuid {
    
//    LOG_INFO(@"resultConnecteGetDeviceState uuid:%@ \t State:%u",uuid,State);
    
    dispatch_group_t group = nil;
    
    switch (State) {
        case DEVICE_DISCONNECTED://设备断开
        {
//            LOG_INFO(@"设备状态-设备断开");
            
            // 1. 设置当前连接的设备
            self.device = nil;
 
            // 2. 如果当前存在正在等待连接的设备，进行连接
            if ([self.waitingConnectDeviceList respondsToSelector:@selector(count)] && self.waitingConnectDeviceList.count > 0) {
                
                [self connecteSpcialDeviceWithDeviceModel:[self.waitingConnectDeviceList lastObject]];
                [self.waitingConnectDeviceList removeAllObjects];
            }
        }
            break;
        case DEVICE_ERROR_OFFS://未找到设备
        {
//            LOG_INFO(@"设备状态-未找到设备");
        }
            break;
        case DEVICE_CONNECTE_SUCCESS://设备连接成功
        {
//            LOG_INFO(@"设备状态-设备连接成功");
        }
            break;
        case DEVICE_INFO_END://获取设备信息成功
        {
//            LOG_INFO(@"设备状态-获取设备信息成功");
            
            // 设置当前连接的设备
            self.device = [self getConnectDevice];

            if (self.device) {
                // SDK方法 设置场景尺寸 ，默认左上角
                [[RobotPenManager sharePenManager] setSceneSizeWithWidth:self.device.function.deviceSize.width andHeight:self.device.function.deviceSize.height andIsHorizontal:NO];
            }
            
        }
            break;
        case DEVICE_CONNECT_FAIL://连接错误
        {
//            LOG_INFO(@"设备状态-连接错误");
            
            // 1. 断开设备是否存在配对记录列表： yes: 删除 no : 不处理 暂时不处理
            if ([self isExistSqcialDeviceWithArray:[self getPairingDevice] deviceUUID:uuid]) {
                
                group =  dispatch_group_create();
                dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                     [[RobotPenManager sharePenManager] deletePairingMacDevice:[self isExistSqcialDeviceWithArray:[self getPairingDevice] deviceUUID:uuid]];
                });

            }

            // 2. 断开设备是否存在配对记录列表： yes: 重新扫描
            if ([self isExistSqcialDeviceWithArray:[self getDeviceSearchList] deviceUUID:uuid]) {
                
                [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
            }
            
        }
            break;
        case DEVICE_CONNECTING://正在配对中...
        {
//            LOG_INFO(@"设备状态-正在配对中...");
        }
            break;
        default:
            break;
    }
    
    // 通知UI层处理
    if (group) {
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"resultConnecteGetDeviceState" object:[NSString stringWithFormat:@"%u",State]];;
        });
        
    }else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resultConnecteGetDeviceState" object:[NSString stringWithFormat:@"%u",State]];
    }

}

#pragma mark - get
- (NSMutableArray *)waitingConnectDeviceList {
    
    if (!_waitingConnectDeviceList) {
        _waitingConnectDeviceList = [[NSMutableArray alloc] init];
    }
    return _waitingConnectDeviceList;
}

@end
