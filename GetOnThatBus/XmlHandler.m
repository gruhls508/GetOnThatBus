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

    BOOL success;
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
    parser.delegate = self;
    success = [parser parse];
}


#pragma mark NSXMLParserDelegate


//  Guide to handling XML elements/attributes--specifically recognizing an elementName in -didStartElement:
//  and using that to determine identity of string in -parser:foundCharacters:, and thus be able to pass that value
//  along from the callback correctly https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/XMLParsing/Articles/HandlingElements.html#//apple_ref/doc/uid/20002265-BCIJFGJI

//  Put this implementation, and the method -parseXmlData: into model object(s)


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {

    NSLog(@"-didStartElement, elementName == %@", elementName);


}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    NSLog(@"found characters, %@", string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {


}


@end
