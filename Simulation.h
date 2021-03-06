#import <Foundation/NSObject.h>

@class Reader;

@interface Simulation : NSObject {

int t;
NSDictionary * ratios;
NSMutableDictionary * amounts;
NSArray * formulae;
}

@property (assign) int t;
@property (retain) NSDictionary * ratios;
@property (retain) NSMutableDictionary * amounts;
@property (retain) NSArray * formulae;

-(NSDictionary*) rateChange;
- run;

@end
