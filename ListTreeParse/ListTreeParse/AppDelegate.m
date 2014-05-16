
#import "AppDelegate.h"
#import "Element.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *listTreePath = [[NSBundle mainBundle] pathForResource:@"list2" ofType:@"txt"];
    NSData *listTreeData = [NSData dataWithContentsOfFile:listTreePath];
    
    
    NSLog(@"%@", [NSSearchPathForDirectoriesInDomains(NSTemporaryDirectory(), NSUserDomainMask, YES) firstObject]);
    
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *listTree = [[NSString alloc] initWithData:listTreeData encoding:NSUTF8StringEncoding];
    
    NSArray *elements = [Element getElementsFromListTree:listTree];
    NSLog(@"%@", elements);
}
@end
