#import <Foundation/Foundation.h>

@interface Listing : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *img;
@property (nonatomic, strong) NSString *text;

- (id)initWithParams:(NSString*)title andImg:(NSURL*)img andText:(NSString*)text;
+ (id)listingWithParams:(NSString*)title andImg:(NSURL*)img andText:(NSString*)text;

@end
