#import "CDXibStoryBoardProcessor.h"
#import "CDXibStoryboardParser.h"


@implementation CDXibStoryBoardProcessor

- (void)obfuscateFilesUsingSymbols:(NSDictionary *)symbols {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *keys = @[NSURLIsDirectoryKey];
    NSURL *directoryURL;
    if (self.xibBaseDirectory) {
        directoryURL = [NSURL URLWithString:self.xibBaseDirectory];
    } else {
        directoryURL = [NSURL URLWithString:@"."];
    }

    NSDirectoryEnumerator *enumerator = [fileManager
        enumeratorAtURL:directoryURL
        includingPropertiesForKeys:keys
        options:0
        errorHandler:^(NSURL *url, NSError *error) {
            // Handle the error.
            // Return YES if the enumeration should continue after the error.
            return YES;
    }];
    
    //找到project.pbxproj 替换xib名字为混淆后的名字
    NSDirectoryEnumerator *enumerator2 = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    __block NSURL *pbxprojUrl;
    for (NSURL *url in enumerator2) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if ([url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error] && ![isDirectory boolValue]) {
            if ([url.absoluteString hasSuffix:@".pbxproj"]) {
                pbxprojUrl = url;
                NSLog(@"pbxproj path %@",pbxprojUrl);
                break;
            }
        }
    }
    NSString *pbxprojStr = [NSString stringWithContentsOfURL:pbxprojUrl encoding:NSUTF8StringEncoding error:NULL];
    

    CDXibStoryboardParser *parser = [[CDXibStoryboardParser alloc] init];
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if ([url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error] && ![isDirectory boolValue]) {
            if ([url.absoluteString hasSuffix:@".xib"] || [url.absoluteString hasSuffix:@".storyboard"]) {
                NSLog(@"Obfuscating IB file at path %@", url);
                NSData *data = [parser obfuscatedXmlData:[NSData dataWithContentsOfURL:url] symbols:symbols];
                
                
                NSString *srcClsName = [[url lastPathComponent] stringByDeletingPathExtension];//混淆前的类名
                NSString *desClsName = symbols[srcClsName];//混淆后的类名
                if (desClsName) {
                    NSURL *tempUrl = [[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.xib",desClsName]];
                    [data writeToURL:tempUrl atomically:YES];
                    
                    //备份旧xib
                    NSURL *cpUrl = [url URLByAppendingPathComponent:@".bak"];
                    [[NSFileManager defaultManager] copyItemAtURL:url toURL:cpUrl error:&error];
                    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
                    if (error) {
                        NSLog(@"remove file error :%@",error);
                    }
                    
                    
                    //替换pbxproj 里的xib名字
                    @autoreleasepool {
                        pbxprojStr = [pbxprojStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"path = %@.xib",srcClsName] withString:[NSString stringWithFormat:@"path = %@.xib",desClsName]];
                    }
                }
                else {
                    [data writeToURL:url atomically:YES];
                }
            }
        }
    }
    
    //保存pbxprojStr
    NSError *error;
    [pbxprojStr writeToURL:pbxprojUrl atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"save pbxproj error:%@",error);
    }
}



@end
