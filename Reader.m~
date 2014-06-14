#import <Foundation/Foundation.h>
#import <stdio.h>
#import "Reader.h"

@implementation Reader

NSString * filePath; //Represents the location of the file to be read from.
@synthesize filePath;

-(id) init: (NSString*) tempPath
{
filePath = tempPath; //Initialize with desired file path.

return self;
}

-(NSArray*) read
{
//Get file contents from file path as array of lines.
NSString * fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
NSArray * allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

//Filter out blank lines and comments.

NSPredicate * pred = [NSPredicate predicateWithFormat:@"(NOT (SELF LIKE %@)) AND (NOT (SELF BEGINSWITH %@))", @"", @"#"];
NSArray * filtered = [allLinedStrings filteredArrayUsingPredicate:pred];

return filtered;
}

-(int) timeExtractor
{
NSArray * filtered = [self read];
//Grab time value - always first line of filtered, always from fourth character onwards.
NSString * tValue = [[filtered objectAtIndex:0] substringFromIndex:4];
int t = [tValue intValue];

return t;
}

-(NSDictionary*) ratioExtractor
{
NSArray * filtered = [self read];
//To get ratio, first filter out time, amount, and formula lines.
NSPredicate * pred = [NSPredicate predicateWithFormat:@"(NOT (SELF BEGINSWITH %@)) AND (SELF MATCHES %@)", @"t", @"^[a-z] =.*"];
NSArray * tempRatios = [filtered filteredArrayUsingPredicate:pred];

NSMutableArray * ratioMolecules = [NSMutableArray new];
NSMutableArray * ratioValues = [NSMutableArray new];

//Iterate over ratios, extracting molecules and values and storing them in mutable arrays.

int i;
for (i = 0; i < tempRatios.count; i++) {
NSString * molecule = [tempRatios objectAtIndex:i];
NSNumber * value = [NSNumber numberWithFloat:[[molecule substringFromIndex:4] floatValue]];
[ratioMolecules insertObject:[molecule substringToIndex:1] atIndex:i];
[ratioValues insertObject:value atIndex:i];
}

//Finally, build dictionary from molecule/ratio arrays, with molecule as key and ratio as value.

NSDictionary * ratios = [NSDictionary dictionaryWithObjects:ratioValues forKeys:ratioMolecules];
[ratioMolecules release];
[ratioValues release];

return ratios;
}

-(NSMutableDictionary*) amountExtractor
{
NSArray * filtered = [self read];

//Filter out time, ratios, and formula lines.

NSPredicate * pred = [NSPredicate predicateWithFormat:@"(NOT (SELF BEGINSWITH %@)) AND (SELF MATCHES %@)", @"t", @"^[A-Z] =.*"];
NSArray * tempAmounts = [filtered filteredArrayUsingPredicate:pred];

NSMutableArray * amountMolecules = [NSMutableArray new];
NSMutableArray * amountValues = [NSMutableArray new];

//Iterate over amounts, extracting molecules and values and storing them in mutable arrays.

int i;
for (i = 0; i < tempAmounts.count; i++) {
NSString * molecule = [tempAmounts objectAtIndex:i];
NSNumber * value = [NSNumber numberWithFloat:[[molecule substringFromIndex:4] floatValue]];
[amountMolecules insertObject:[molecule substringToIndex:1] atIndex:i];
[amountValues insertObject:value atIndex:i];
}

//Finally, build dictionary from molecule/amount arrays, with molecule as key and amount as value.

NSMutableDictionary * amounts = [NSMutableDictionary dictionaryWithObjects:amountValues forKeys:amountMolecules];
[amountMolecules release];
[amountValues release];

return amounts;
}

-(NSArray*) formulaeExtractor
{
NSArray * filtered = [self read];

//Filter out time, ratio, and amounts.

NSPredicate * pred = [NSPredicate predicateWithFormat:@"(NOT (SELF BEGINSWITH %@)) AND (SELF MATCHES %@)", @"t", @"^[a-z] :.*"];
NSArray * tempFormulae = [filtered filteredArrayUsingPredicate:pred];

NSMutableArray * formulae = [NSMutableArray new];

//Iterate over formula, extracting molecules and formulae and storing them in mutable array. Individual formula are represented as
//an array containing a character (for kinetic ratio), and two arrays - one for reactants and one for products, both represented by
//their molecules.

int i;
for (i = 0; i < tempFormulae.count; i++) {
NSString * molecule = [tempFormulae objectAtIndex:i];
NSString * ratio = [molecule substringToIndex:1];
molecule = [molecule substringFromIndex:4];

NSCharacterSet * charSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
NSArray * seperated = [molecule componentsSeparatedByCharactersInSet:charSet];

NSMutableArray  *formula = [NSMutableArray new];
[formula addObject:ratio];

charSet = [NSCharacterSet characterSetWithCharactersInString:@"+>: "];

NSString * firstHalf = [[seperated objectAtIndex:0] stringByTrimmingCharactersInSet:charSet];
NSString * secondHalf = [[seperated objectAtIndex:1] stringByTrimmingCharactersInSet:charSet];

charSet = [NSCharacterSet characterSetWithCharactersInString:@" + "];
NSArray * seperated1 = [firstHalf componentsSeparatedByCharactersInSet:charSet];
NSArray * seperated2 = [secondHalf componentsSeparatedByCharactersInSet:charSet];

NSPredicate * pred = [NSPredicate predicateWithFormat:@"NOT (SELF LIKE %@)", @""];
NSArray * cleanSeperated1 = [seperated1 filteredArrayUsingPredicate:pred];
NSArray * cleanSeperated2 = [seperated2 filteredArrayUsingPredicate:pred];

[formula addObject:cleanSeperated1];
[formula addObject:cleanSeperated2];

[formulae insertObject:formula atIndex:i];
}

return formulae;
}
@end
