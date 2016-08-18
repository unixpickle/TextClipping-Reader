#import <Foundation/Foundation.h>
#import "ResourceForkManager.h"
#import "TextClippingNode.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	int plain = 0, vbose = 0;
	
	if (argc > 1) {
		int i;
		for (i = 1; i < argc - 1; i++) {
			if (strcmp(argv[i], "--plain") == 0) {
				plain = 1;
			} else if (strcmp(argv[i], "-v") == 0) {
				vbose = 1;
			} else {
				fprintf(stderr, "Uknown option: %s\n", argv[i]);
				fflush(stderr);
			}
		}
	} else {
		fprintf(stderr, "Usage: %s [--plain] [-v] file\n", argv[0]);
		return 0;
	}
	
	const char * fname = argv[argc - 1];
	NSString * nname = [[NSString alloc] initWithFormat:@"%s", fname];
	
	ResourceForkManager * man = [[ResourceForkManager alloc] init];
	[man openResourceForFile:nname];
	NSData * d = [man readDataFromFile];
	[man closeFile];
	[man release];
	
	NSArray * blocks = [TextClippingNode nodesFromData:d];
	
	if (vbose) {
		printf(" LOG: Read %d blocks from file.\n", (int)[blocks count]);
	}

	if ([blocks count] == 9) {
		// assume its RTF
		if (vbose) {
			printf(" LOG: Detected RTF based on block count.\n");
		}
		if (plain) {
			// we want the 2nd block
			if (vbose) {
				printf(" LOG: Reading plain text from 2nd block (null spaced).\n");
			}
			NSData * d = [blocks objectAtIndex:1];
			for (int i = 0; i < [d length]; i++) {
				char c = ((const char *)[d bytes])[i];
				if (c != 0) printf("%c", c);
			}
			printf("\n");
		} else {
			if (vbose) {
				printf(" LOG: Reading RTF data from 4th block.\n");
			}
			// god, figure out which block this is.
			NSData * text = [blocks objectAtIndex:3];
			for (int i = 0; i < [text length]; i++) {
				const char c = ((const char *)[text bytes])[i];
				if (isascii(c)) printf("%c", c);
			}
		}
	} else if ([blocks count] == 10) {
		if (vbose) {
			printf(" LOG: Detected RTF based on block count.\n");
		}
		if (plain) {
			if (vbose) {
				printf(" LOG: Reading plain text from 5th block (UTF-16).\n");
			}
			NSData *txt = blocks[2];
			NSString *s = [[NSString alloc] initWithData:txt encoding:NSUTF16BigEndianStringEncoding];
			printf("%s", s.UTF8String);
			[s release];
		} else {
			if (vbose) {
				printf(" LOG: Reading RTF data from 5th block.\n");
			}
			NSData *rtf = blocks[4];
			fwrite(rtf.bytes, 1, rtf.length, stdout);
		}
	} else if ([blocks count] == 5) {
		// assume its text
		// the text should be the third block
		if (vbose) {
			printf(" LOG: Reading plain text from 3rd block.\n");
		}
		NSData * text = [blocks objectAtIndex:2];
		printf("%s\n", [[[[NSString alloc] initWithData:text encoding:NSUTF8StringEncoding] autorelease] UTF8String]);
	} else {
		fprintf(stderr, "Unknown format.  It was not rtf or txt and it has %lu blocks.\n", [blocks count]);
		if (vbose) {
			NSLog(@"%@", blocks);
		}
		return 1;
	}

	[pool drain];
    return 0;
}
