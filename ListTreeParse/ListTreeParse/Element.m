
#import "Element.h"

@implementation Element

+ (NSArray *)getElementsFromListTree:(NSString *)listTree
{
    NSArray *lines = [listTree componentsSeparatedByString:@"\n"];
    NSArray *strippedArray = [self stripTabSpacingFromListTree:lines];
    
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    
    
    //Loop through lines and build an element from the contents of each line
    for (int x = 1; x < [strippedArray count]; x++) {
        NSString *objectType = [self getElementTypeFromString:[strippedArray objectAtIndex:x]];
        
        if (objectType) {
            Element *newElement = [[Element alloc] init];
            newElement.type = objectType;
            newElement.label = [self getElementLabelFromString:[strippedArray objectAtIndex:x]];
            
            NSArray *points = [self getCoordinatesFromString:[strippedArray objectAtIndex:x]];
            newElement.frame = CGRectMake([[points objectAtIndex:0] floatValue], [[points objectAtIndex:1] floatValue], [[points objectAtIndex:2] floatValue], [[points objectAtIndex:3] floatValue]);
            
            newElement.tabCount = [Element getTabCountForLine:[lines objectAtIndex:x]];
            
            [elements addObject:newElement];
        }
    }
    
    
//    for (Element *e in elements) {
//        
//        NSMutableString *compiledString = [[NSMutableString alloc] init];
//        
//        for (int x = 2; x < e.tabCount; x++) {
//            [compiledString appendString:@"\t"];
//        }
//        
//        NSString *detailString = [NSString stringWithFormat:@"%@ : %@ : {%.0f, %.0f, %.0f, %.0f}", e.type, e.label, e.frame.origin.x, e.frame.origin.y, e.frame.size.width, e.frame.size.height];
//        [compiledString appendString:detailString];
//        
//        NSLog(@"%@", compiledString);
//    }
    
    
    //Get the tab indent for the current element
    //Get the next index in the array
    //If the next index tab indent is greater that is a child
    //Need a recursive function of sorts to keep going down
    
    //Loop through - get range of lines in the array that are children or grandchildren
    
    return elements;
}

+ (NSArray *)stripTabSpacingFromListTree:(NSArray *)listTreeArray
{
    NSMutableArray *newListTree = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < [listTreeArray count]; x++) {
        NSString *line = [listTreeArray objectAtIndex:x];
        NSString *strippedLine = [line stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        [newListTree addObject:strippedLine];
    }
    
    return newListTree;
}

+ (NSString *)getElementTypeFromString:(NSString *)line
{
    NSArray *splitLine = [line componentsSeparatedByString:@" "];
    
    NSString *objectName = [splitLine firstObject];
    
    if ([objectName isEqualToString:@"UIATarget"] || [objectName isEqualToString:@"elements:"] || [objectName isEqualToString:@"}"] || [objectName isEqualToString:@"UIAStatusBar"] || [objectName isEqualToString:@"UIAApplication"] || objectName == nil) {
        return nil;
    }
    
    return [splitLine firstObject];
}

+ (NSString *)getElementLabelFromString:(NSString *)line
{
    NSArray *splitLine = [line componentsSeparatedByString:@"\""];
    
    if ([splitLine count] > 1) {
        return [splitLine objectAtIndex:1];
    }
    
    return nil;
}

+ (NSArray *)getCoordinatesFromString:(NSString *)line
{
    NSRange r1 = [line rangeOfString:@"{{"];
    NSRange r2 = [line rangeOfString:@"}}"];
    NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
    
    if (rSub.length != 0) {
        NSString *sub = [line substringWithRange:rSub];
        
        NSString *tidiedResult = [[[sub stringByReplacingOccurrencesOfString:@"}" withString:@""] stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSArray *points = [tidiedResult componentsSeparatedByString:@","];
        
        return points;
    }
    
    return nil;
}

+ (NSInteger)getTabCountForLine:(NSString *)line
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\t" options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, [line length])];
    
    return numberOfMatches;
}


@end
