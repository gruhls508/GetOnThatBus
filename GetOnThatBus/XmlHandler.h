//
//  XmlHandler.h
//  GetOnThatBus
//
//  Created by Glen Ruhl on 3/20/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlHandler : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSXMLParser *parser;

- (void)parseXmlData:(NSData *)data;
+ (NSString *)appendNameComponent:(NSString *)component toName:(NSString *)name;

@end
