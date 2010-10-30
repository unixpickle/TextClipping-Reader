//
//  TextClippingNode.m
//  TextClippingReader
//
//  Created by Alex Nichol on 10/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TextClippingNode.h"


@implementation TextClippingNode
+ (NSArray *)nodesFromData:(NSData *)data {
	NSMutableArray * retV = [[NSMutableArray alloc] init];
	if ([data length] > 4) {
		int index = 0;
		while (index < [data length] - 4) {
			// read an int
			const char * c = &([data bytes][index]);
			char mChar[4];
			mChar[3] = c[0];
			mChar[2] = c[1];
			mChar[1] = c[2];
			mChar[0] = c[3];
			int len = *((int *)mChar);
			const char * ptr = &(((const char *)[data bytes])[index + 4]);
			if ([data length] > index + len) {
				NSMutableData * node = [[NSMutableData alloc] initWithBytes:ptr length:len - (index == 0 ? 4 : 0)];
				
				[retV addObject:[node autorelease]];
			} else break;
			
			if (index + len < [data length]) {
				index = index + len + (index == 0 ? 0 : 4);
			}
		}
	}
	return [retV autorelease];
}
@end
