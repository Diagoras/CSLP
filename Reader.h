#import <Foundation/NSObject.h>
#import <objc/objc.h>

@interface Reader : NSObject {

NSString * filePath;
}

@property (readwrite, retain) NSString * filePath;

-(id) init: (NSString*) tempPath;

-(NSArray*) read;

-(int) timeExtractor;

-(NSDictionary*) ratioExtractor;

-(NSMutableDictionary*) amountExtractor;

-(NSArray*) formulaeExtractor;

@end
