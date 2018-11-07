#import "Listing.h"

@implementation Listing

- (id) initWithParams:(NSString*)title andImg:(NSURL *)img andText:(NSString *)text {
    self = [super init];
    if (self){
        self.title = title;
        self.img = img;
        self.text = text;
    }
    return self;
}

+ (id)ListingWithParams:(NSString *)title andImg:(NSURL *)img andText:(NSString *)text {
    Listing *theListing = [[Listing alloc] initWithParams:title andImg:img andText:text];
    return theListing;
}

@end
