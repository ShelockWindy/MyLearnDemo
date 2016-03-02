//
//  WSNsstring+(conversion).h
//  MyLearnDemo
//
//  Created by 孙威风 on 15-4-29.
//  Copyright (c) 2015年 ___sunweifeng___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString(extension)
- (NSString *)lowercaseFirstCharacter;
- (NSString *)uppercaseFirstCharacter;
- (BOOL)isEmpty;
- (NSString *)trim;
- (NSString *)trimTheExtraSpaces;
- (NSString *)escapeHTML;
- (NSString *)stringByDecodingXMLEntities;
- (NSString *)md5;
- (NSString *)md5ForUTF16;
- (CGFloat)fontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (NSMutableArray *)tokenizationStringByNSStringEnumerationOptions:(NSStringEnumerationOptions)opts;
- (NSString *)languageForString;
- (NSMutableArray *)analyseTextOfSentences;

@end
