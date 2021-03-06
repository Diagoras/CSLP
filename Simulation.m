#import <Foundation/Foundation.h>
#import <stdio.h>
#import <math.h>
#import <bsd/stdlib.h>
#import "Reader.h"
#import "Simulation.h"

@implementation Simulation

int t; //Stop time.
NSDictionary * ratios; //Kinetic ratios.
NSMutableDictionary * amounts; //Amounts of molecules at start time.
NSArray * formulae; //Formulae for molecules.

@synthesize t;
@synthesize ratios;
@synthesize amounts;
@synthesize formulae;

-(NSDictionary*) rateChange {

NSMutableArray * tempRate = [NSMutableArray new];
NSMutableArray * tempKey = [NSMutableArray new];

int i;
for (i = 0; i < formulae.count; i++) {

NSArray * formula = [formulae objectAtIndex:i];

float kc = [[ratios valueForKey:[formula objectAtIndex:0]] floatValue];
float rate;

if ([[formula objectAtIndex:1] count] == 0) {
rate = kc;
}

else if ([[formula objectAtIndex:1] count] == 1) {
NSString * reactant = [[formula objectAtIndex:1] objectAtIndex:0];
rate = [[amounts valueForKey:reactant] floatValue] * kc;
}

else if ([[formula objectAtIndex:1] count] == 2) {
NSString * reactant1 = [[formula objectAtIndex:1] objectAtIndex:0];
NSString * reactant2 = [[formula objectAtIndex:1] objectAtIndex:1];

if (reactant1 == reactant2) {
rate = 0.5 * [[amounts valueForKey:reactant1] floatValue] * ([[amounts valueForKey:reactant2] floatValue] - 1) * kc;
}

else {
rate = [[amounts valueForKey:reactant1] floatValue] * [[amounts valueForKey:reactant2] floatValue] * kc;
}
}

else {
rate = -1;
}

[tempRate addObject:[NSNumber numberWithFloat:rate]];
[tempKey addObject:[formula objectAtIndex:0]];
}

NSDictionary * unsortedRates = [NSDictionary dictionaryWithObjects:tempRate forKeys:tempKey];
NSArray * rateKeys = [unsortedRates keysSortedByValueUsingSelector:@selector(compare:)];
NSArray * rateValues = [[unsortedRates allValues] sortedArrayUsingSelector:@selector(compare:)];
NSDictionary * rates = [NSDictionary dictionaryWithObjects:rateValues forKeys:rateKeys];

return rates;
}

- run {

NSAutoreleasePool * pool = [NSAutoreleasePool new];

//Array of command-line arguments.
NSArray * arguments = [[NSProcessInfo processInfo] arguments];

//Instance of reader class for reading in script. File path is first argument.
Reader * reader = [[Reader new] init:[arguments objectAtIndex:1]];

//Set all initial values from script.
t = [reader timeExtractor];

ratios = [reader ratioExtractor];

amounts = [reader amountExtractor];

formulae = [reader formulaeExtractor];

//Set time at 0.
float current_time = 0;

//Initialize string containing program output.
NSString * output = [NSString new];

//Declare or allocate variables outside of main loop.
NSArray * amountValues;

NSDictionary * rates;
NSArray * rateValues;
NSArray * rateKeys;

float r1;
float r2;
float sum;
float ti;
float rj;

NSString * next = [NSString alloc];

NSArray * reactants = [NSArray alloc];
NSArray * products = [NSArray alloc];

//Write "t", molecule names to output string, followed by new line, as header.
output = [output stringByAppendingFormat:@"t,"];

for (NSString * amountKey in amounts) {
output = [output stringByAppendingFormat:@"%@,", amountKey];
}

output = [output stringByAppendingFormat:@"\n"];

//Main loop begins...
do {
//Write current time, current molecule amounts to output string, followed by new line.
amountValues = [amounts allValues];

output = [output stringByAppendingFormat:@"%f,", current_time];

for (NSNumber * amount in amountValues) {
output = [output stringByAppendingFormat:@"%i,", [amount intValue]];
}

output = [output stringByAppendingFormat:@"\n"];

//Intialize random floats (0-1) r1 and r2.
r1 = ((float)arc4random()/0x100000000);
r2 = ((float)arc4random()/0x100000000);

//Recalculate molecule rates from amounts, kinetic ratios.
rates = [self rateChange];
rateValues = [rates allValues];
rateKeys = [rates allKeys];

//Get sum of rate values.
sum = 0;
for (NSNumber * rateValue in rateValues) {
sum += [rateValue floatValue];
}

//Calculate next time interval using r1, sum of rate values.
ti = (1/sum)*log1pf((1/r1));

//Update current time with new time interval.
current_time += ti;

//Calculate next reaction rj using r2, sum of rate values.
rj = sum * r2;

//Loop through list of rates, finding the smallest that exceeds rj. Choose that formula,
//represented by kinetic ratio, and assign to next.
sum = 0;
int i;
for (i = ([rates count] - 1); i >= 0; i--) {
sum += [[rateValues objectAtIndex:i] floatValue];

if (sum >= rj) {
next = [rateKeys objectAtIndex:i];
break;
}
}

//Find products and reactants of next.
for (NSArray * formula in formulae) {
if ([next compare:[formula objectAtIndex:0]] == NSOrderedSame) {
reactants = [formula objectAtIndex:1];
products = [formula objectAtIndex:2];
}
}

//Decrement one or two molecules, depending on reactants. If there are none, no need to do anything.
if ([reactants count] == 1) {
NSNumber * newReactant = [NSNumber numberWithFloat:([[amounts valueForKey:[reactants objectAtIndex:0]] floatValue] - 1.0)];
[amounts setObject:newReactant forKey:[reactants objectAtIndex:0]];
}

else if ([reactants count] == 2) {
NSNumber * newReactant1 = [NSNumber numberWithFloat:([[amounts valueForKey:[reactants objectAtIndex:0]] floatValue] - 1.0)];
NSNumber * newReactant2 = [NSNumber numberWithFloat:([[amounts valueForKey:[reactants objectAtIndex:0]] floatValue] - 1.0)];
[amounts setObject:newReactant1 forKey:[reactants objectAtIndex:0]];
[amounts setObject:newReactant2 forKey:[reactants objectAtIndex:1]];
}

//Increment one or two molecules, depending on products. If there are none, no need to do anything.
if ([products count] == 1) {
NSNumber * newProduct = [NSNumber numberWithFloat:([[amounts valueForKey:[products objectAtIndex:0]] floatValue] + 1.0)];
[amounts setObject:newProduct forKey:[products objectAtIndex:0]];
}

else if ([products count] == 2) {
NSNumber * newProduct1 = [NSNumber numberWithFloat:([[amounts valueForKey:[products objectAtIndex:0]] floatValue] + 1.0)];
NSNumber * newProduct2 = [NSNumber numberWithFloat:([[amounts valueForKey:[products objectAtIndex:0]] floatValue] + 1.0)];
[amounts setObject:newProduct1 forKey:[products objectAtIndex:0]];
[amounts setObject:newProduct2 forKey:[products objectAtIndex:1]];
}

} while (current_time < t); //While not yet at or past stop time.

//Log information to console, write output string to file path given by second command line argument.
NSLog (@"Stop time is %i", t);
NSLog (@"Ratios are %@", ratios);
NSLog (@"Amounts are %@", amounts);
NSLog (@"Formulae are %@", formulae);
[output writeToFile:[arguments objectAtIndex:2] 
          atomically:YES 
            encoding:NSASCIIStringEncoding error:NULL];

[pool drain];
}

int main (int argc, const char * argv[]) {

//Main method. Initialize instance of class, execute run method, perform clean up.

Simulation * simulation = [Simulation new];

[simulation run];

[simulation release];

return 0;
}

@end
