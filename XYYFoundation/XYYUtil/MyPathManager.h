//
//  pathManager.h
//  testDemo
//
//  Created by LeslieChen on 13-11-5.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYYBaseDef.h"

#pragma mark -

//获取资源路径
#define __PathForResource__IMP__(_name, _bundle, L)                                              \
({                                                                                               \
NSString * __NSX_PASTE__(__path,L) = nil;                                                    \
NSString * __NSX_PASTE__(__name,L) = _name;                                                  \
if (__NSX_PASTE__(__name,L).length) {                                                        \
NSRange __NSX_PASTE__(__range,L) = [__NSX_PASTE__(__name,L) rangeOfString:@"." options:NSBackwardsSearch]; \
NSBundle *  __NSX_PASTE__(__bundle,L) = _bundle ?: [NSBundle mainBundle];                \
if (__NSX_PASTE__(__range,L).location != NSNotFound &&                                   \
__NSX_PASTE__(__range,L).location < __NSX_PASTE__(__name,L).length - 1) {            \
__NSX_PASTE__(__path,L) = [__NSX_PASTE__(__bundle,L) pathForResource:[__NSX_PASTE__(__name,L) substringToIndex:__NSX_PASTE__(__range,L).location] ofType:[__NSX_PASTE__(__name,L) substringFromIndex:__NSX_PASTE__(__range,L).location + 1]];                                                                  \
}                                                                                        \
}                                                                                            \
__NSX_PASTE__(__path,L);                                                                     \
})
#define PathForResource(_name, _bundle) __PathForResource__IMP__(_name, _bundle, __COUNTER__)


#define ResourceFilePathInBundle(_bundle,_name,_type) \
[_bundle ?: [NSBundle mainBundle] pathForResource:_name ofType:_type]
#define ResourceFilePath(_name,_type) \
[[NSBundle mainBundle] pathForResource:_name ofType:_type]

#define PlistResourceFilePathInBundle(_bundle,_name) \
[_bundle ?: [NSBundle mainBundle] pathForResource:_name ofType:@"plist"]
#define PlistResourceFilePath(_name) \
[[NSBundle mainBundle] pathForResource:_name ofType:@"plist"]



#pragma mark -

//----------文件相关--------------
//----------------------------------------------------------

/*
 *确保路径存在,如果成功返回YES
 */
BOOL makeSrueDirectoryExist(NSString *path);

//文件是否存在在path路径上
BOOL fileExistAtPath(NSString *path);

/**
 * 获取文件大小
 * @param filePath filePath为文件路径
 * @return 返回文件大小，单位byte，若路径无效或者为指定一个路径，则返回0
 */
long long fileSizeAtPath(NSString *filePath);

/**
 * 获取指定文件夹路径下的所有文件总大小
 * @param folderPath folderPath为文件夹路径
 * @return 返回所有文件总大小，单位byte，若路径无效，则返回0，若路径指定一个文件，则返回文件大小
 */
long long folderSizeAtPath(NSString *folderPath);

/**
 * 异步获取文件夹的所有文件的总大小
 * @param folderPath folderPath为文件夹路径，若路径无效，则返回0，若路径指定一个文件，则返回文件大小
 * @param completeBlock completeBlock为结果返回的block，在主线程调用
 */
void folderSizeAtPath_asyn(NSString *folderPath, void (^completeBlock)(long long));

/**
 * 删除指定路径上的项目
 * @param path path为路径
 * @param onlyRemoveFile onlyRemoveFile指示是否只删除文件，如果为YES，则只删除文件，不破坏目录结构
 * @return 若路径有效切删除成功则返回YES，无效返回NO
 */
BOOL removeItemAtPath(NSString * path,BOOL onlyRemoveFile);

//nib文件是否存在
BOOL nibFileExist(NSString * nibName, NSBundle * bundle);


#pragma mark -

typedef NS_ENUM(NSInteger,MyPathType) {
    MyPathTypeDocument,
    MyPathTypeLibrary,
    MyPathTypeCaches,
    MyPathTypeTemp,
    MyPathTypeCount
};

#pragma mark -

@interface MyPathManager : NSObject

+ (NSString *)pathForType:(MyPathType)pathType;
+ (NSString *)pathForType:(MyPathType)pathType directory:(NSString *)directory;
+ (NSString *)pathForType:(MyPathType)pathType directory:(NSString *)directory fileName:(NSString *)fileName;

+ (instancetype)pathManagerWithFileFolder:(NSString *)fileFolder;
+ (instancetype)pathManagerWithType:(MyPathType)pathType andFileFolder:(NSString *)fileFolder;

- (id)initWithFileFolder:(NSString *)fileFolder;
- (id)initWithType:(MyPathType)pathType andFileFolder:(NSString *)fileFolder;

@property(nonatomic) MyPathType pathType;
@property(nonatomic,strong) NSString *fileFolder;

- (NSString *)path;
- (NSString *)pathForFile:(NSString *)fileName;
- (NSString *)pathForDirectory:(NSString *)DirectoryName;


@end
