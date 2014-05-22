
#import "AppDelegate.h"
#import "Element.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *listTreePath = [[NSBundle mainBundle] pathForResource:@"list2" ofType:@"txt"];
    NSData *listTreeData = [NSData dataWithContentsOfFile:listTreePath];
    
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *listTree = [[NSString alloc] initWithData:listTreeData encoding:NSUTF8StringEncoding];
    
    NSArray *elements = [Element getElementsFromListTree:listTree];
    NSLog(@"%@", elements);
    
    
    NSString *runPlist = [[NSBundle mainBundle] pathForResource:@"Automation Results" ofType:@"plist"];
    [self loadResultsPlistFile:runPlist];
}

- (void)loadResultsPlistFile:(NSString *)file
{
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:file];
    
    NSDictionary *tree = [[plist objectForKey:@"All Samples"] objectAtIndex:1];
    
    NSLog(@"%@", tree);
}





@end
