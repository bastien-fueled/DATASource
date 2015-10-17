#import "ViewController.h"

#import "DATAStack.h"
#import "User.h"
#import "FooterExampleView.h"
#import "CollectionCell.h"

#import "CollectionObjC-Swift.h"

@interface ViewController () <NSFetchedResultsControllerDelegate, DataSourceDelegate>

@property (nonatomic, weak) DATAStack *dataStack;
@property (nonatomic) DataSource *dataSource;

@end

@implementation ViewController

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout
                  andDataStack:(DATAStack *)dataStack {
    self = [super initWithCollectionViewLayout:layout];
    if (!self) return nil;

    _dataStack = dataStack;

    return self;
}

- (DataSource *)dataSource {
    if (_dataSource) return _dataSource;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstLetterOfName" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    _dataSource = [[DataSource alloc] initWithCollectionView:self.collectionView
                                              cellIdentifier:CollectionCellIdentifier
                                                fetchRequest:request
                                                 mainContext:self.dataStack.mainContext
                                                 sectionName:@"firstLetterOfName"
                                               configuration:^(UICollectionViewCell * _Nonnull cell, NSManagedObject * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
                                                   CollectionCell *collectionCell = (CollectionCell *)cell;
                                                   User *user = (User *)item;

                                                   [collectionCell updateWithText:user.name];
                                               }];
    _dataSource.delegate = self;

    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:CollectionCellIdentifier];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(addAction)];
    self.navigationItem.rightBarButtonItem = item;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);

    [self.collectionView registerClass:[FooterExampleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:FooterExampleViewIdentifier];
}

- (void)addAction {
    [self.dataStack performInNewBackgroundContext:^(NSManagedObjectContext *backgroundContext) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:backgroundContext];
        User *user = [[User alloc] initWithEntity:entity
                   insertIntoManagedObjectContext:backgroundContext];
        NSString *name = [self randomString];
        NSString *firstLetter = [[name substringToIndex:1] uppercaseString];
        [user setValue:name forKey:@"name"];
        [user setValue:firstLetter forKey:@"firstLetterOfName"];
        [backgroundContext save:nil];
    }];
}

- (NSString *)randomString {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:10];

    for (int i = 0; i < 10; i++) {
        u_int32_t rnd = (u_int32_t)[letters length];
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform(rnd)]];
    }

    return randomString;
}

#pragma mark - DataSourceDelegate

- (UICollectionReusableView *)dataSource:(DataSource *)dataSource
                          collectionView:(UICollectionView *)collectionView
       viewForSupplementaryElementOfKind:(NSString *)kind
                             atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
    } else if (kind == UICollectionElementKindSectionFooter) {
        FooterExampleView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                     withReuseIdentifier:FooterExampleViewIdentifier
                                                                            forIndexPath:indexPath];
        return view;
    }

    return nil;
}

@end