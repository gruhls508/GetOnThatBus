//
//  XmlHandler.m
//  GetOnThatBus
//
//  Created by Glen Ruhl on 3/20/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

#import "XmlHandler.h"

@implementation XmlHandler 

- (void)parseXmlData:(NSData *)data {

    if (_parser == nil)
        _parser = [[NSXMLParser alloc]initWithData:data];
}


+ (NSString *)appendNameComponent:(NSString *)component toName:(NSString *)name {

    return [name stringByAppendingString:component];
}


/*  
    This method will be used when adding coordinate string for given key
    to a bus stop object. */
+ (NSDictionary *)dictionary:(NSDictionary *)dictionary
                  addObject:(id)object forKey:(NSString *)key {

    NSMutableDictionary *mutable = dictionary.mutableCopy;
    [mutable setObject:object forKey:key];

    return [NSDictionary dictionaryWithDictionary:mutable];
}



@end
