//
//  pathManager.m
//  testDemo
//
//  Created by LeslieChen on 13-11-5.
//  Copyright (c) 2013年 Xu zhanya. All rights reserved.
//

#import "MyPathManager.h"

#pragma mark -

BOOL makeSrueDirectoryExist(NSString *path)
{
    if (!path.length) {
        return NO;
    }
    
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:NULL];
    }
    
    return YES;
}

BOOL fileExistAtPath(NSString *path)
{
    if (!path.length) {
        return NO;
    }
    
    //文件存在且不是路径
    BOOL isDir;
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir;
}


long long fileSizeAtPath(NSString *filePath)
{
    if (filePath.length) {
        
        BOOL isDir;
        NSFileManager* manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir){
            return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        }
    }
    
    return 0;
}

long long folderSizeAtPath(NSString *folderPath)
{
    //1.判断路径所指定的类型
    //2.遍历所有子路径计算大小
    
    BOOL isDir;
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath isDirectory:&isDir]){
        return 0;
    }else if (!isDir){
        return [[manager attributesOfItemAtPath:folderPath error:nil] fileSize];
    }
    
    //遍历子路径
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        //完整路径
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += fileSizeAtPath(fileAbsolutePath);
    }
    
    return folderSize;
}

void folderSizeAtPath_asyn(NSString *folderPath, void (^completeBlock)(long long))
{
    if (completeBlock) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            long long resultSize = folderSizeAtPath(folderPath);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(resultSize);
            });
        });
    }
}

BOOL removeItemAtPath(NSString * path,BOOL onlyRemoveFile)
{
    BOOL isDir;
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path isDirectory:&isDir]){
        return NO;
    }else if (!isDir || !onlyRemoveFile){
        return [manager removeItemAtPath:path error:nil];
    }else{
        
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
        
        NSString * fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil) {
            
            NSString * fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
            
            if ([manager fileExistsAtPath:fileAbsolutePath isDirectory:&isDir] && !isDir) {
                [manager removeItemAtPath:fileAbsolutePath error:NULL];
            }else {
                removeItemAtPath(fileAbsolutePath, onlyRemoveFile);
            }
        }
        return YES;
    }
}

BOOL nibFileExist(NSString * nibName, NSBundle * bundle)
{
    if (nibName.length) {
        return [bundle ?: [NSBundle mainBundle] pathForResource:nibName ofType:@"nib"].length;
    }
    
    return NO;
}

#pragma mark -

@implementation MyPathManager

#pragma mark -

+ (NSString *)pathForType:(MyPathType)pathType
{
    switch (pathType) {
            
        case MyPathTypeDocument:
            return  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        case MyPathTypeLibrary:
            return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        case MyPathTypeCaches:
            return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            break;
            
        case MyPathTypeTemp:
            return NSTemporaryDirectory();
            break;
            
        default:
            return nil;
            break;
    }
}

+ (NSString *)pathForType:(MyPathType)pathType directory:(NSString *)directory
{
    NSString * path = [self pathForType:pathType];
    if (directory.length) {
        path = [path stringByAppendingPathComponent:directory];
    }
    
    return makeSrueDirectoryExist(path) ? path : nil;
}

+ (NSString *)pathForType:(MyPathType)pathType directory:(NSString *)directory fileName:(NSString *)fileName
{
    NSString * path = [self pathForType:pathType directory:directory];
    return [path stringByAppendingPathComponent:fileName];
}

#pragma mark -

+ (instancetype)pathManagerWithFileFolder:(NSString *)fileFolder {
    return [[MyPathManager alloc] initWithFileFolder:fileFolder];
}

+ (instancetype)pathManagerWithType:(MyPathType)pathType andFileFolder:(NSString *)fileFolder{
    return [[MyPathManager alloc] initWithType:pathType andFileFolder:fileFolder];
}

- (id)init {
    return [self initWithType:MyPathTypeDocument andFileFolder:nil];
}

- (id)initWithFileFolder:(NSString *)fileFolder{
    return [self initWithType:MyPathTypeDocument andFileFolder:fileFolder];
}

- (id)initWithType:(MyPathType)pathType andFileFolder:(NSString *)fileFolder
{
    self = [super init];
    if (self) {
        _pathType = pathType;
        _fileFolder = fileFolder;
    }
    
    return self;
}

#pragma mark -

- (NSString *)path {
    return [[self class] pathForType:self.pathType directory:self.fileFolder];
}

- (NSString *)pathForFile:(NSString *)fileName {
    return [[self class] pathForType:self.pathType directory:self.fileFolder fileName:fileName];
}

- (NSString *)pathForDirectory:(NSString *)DirectoryName
{
    NSString * path = [self pathForFile:DirectoryName];
    return makeSrueDirectoryExist(path) ? path : nil;
}

@end
