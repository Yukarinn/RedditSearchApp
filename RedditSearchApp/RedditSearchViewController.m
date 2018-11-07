#import "RedditSearchViewController.h"
#import "Listing.h"
#import "AFNetworking.h"


@interface RedditSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *results;
@property (nonatomic) AFHTTPSessionManager *networkManager;

@end


@implementation RedditSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.results = [[NSMutableArray alloc] init];
    self.searchBar.delegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self registerNibsForTableView];
    [self setupNetworkManager];
}

- (void)setupNetworkManager {
    self.networkManager = [AFHTTPSessionManager manager];
    self.networkManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.networkManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.networkManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
}

- (void)registerNibsForTableView {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText
{
    if (searchText.length != 0)
    {
        NSString *searchURL = [NSString stringWithFormat:@"https://www.reddit.com/search.json?q=%@&sort=relevance", searchText];
        
        [self.networkManager GET:searchURL
          parameters:nil
            progress:nil
             success:^(NSURLSessionTask *task, id responseObject)
         {
             NSMutableArray *listingResults = [NSMutableArray new];
             NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
             NSMutableDictionary *data = [dict valueForKey:@"data"];
             NSMutableArray *children = [data valueForKey:@"children"];
             for (NSDictionary *entry in children)
             {
                 Listing *listing = [self listingForRawSearchResultDictionary:entry];
                 [listingResults addObject:listing];
             }
             self.results = listingResults;
             [self.tableView reloadData];
         }
             failure:^(NSURLSessionTask *operations, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
    }
}

- (Listing *)listingForRawSearchResultDictionary:(NSDictionary *)dictionary {
    id postdata = [dictionary valueForKey:@"data"];
    NSString *title = [postdata valueForKey:@"title"];
    NSString *urlString = [postdata valueForKey:@"thumbnail"];
    NSURL *img = [NSURL URLWithString:urlString];
    NSString *text = [postdata valueForKey:@"selftext"];
    return [[Listing alloc] initWithParams:title andImg:img andText:text];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    
    Listing *obj = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.title;
    cell.detailTextLabel.text = obj.text;
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:obj.img];
    cell.imageView.image = [[UIImage alloc] initWithData:imgData];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

@end
