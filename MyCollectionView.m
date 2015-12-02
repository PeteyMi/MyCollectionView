//
//  MyCollectionView.m
//  MyCollectionView
//
//  Created by Petey Mi on 12/2/15.
//  Copyright © 2015 Petey Mi. All rights reserved.
//

#import "MyCollectionView.h"

@interface MyCollectionView ()
{
    BOOL _isBeginUpdates;
}

@property(nonatomic, strong) NSMutableIndexSet*     deletedSectionIndexes;
@property(nonatomic, strong) NSMutableIndexSet*     insertedSectionIndexes;
@property(nonatomic, strong) NSMutableArray*        deletedItemIndexPaths;
@property(nonatomic, strong) NSMutableArray*        insertedItemIndexPaths;
@property(nonatomic, strong) NSMutableArray*        updatedItemIndexPaths;

@end


@implementation MyCollectionView


-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self commonInit];
    }
    return self;
}
-(id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

-(void)commonInit
{
    _isBeginUpdates = NO;
}

-(void)clearChanges
{
    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.deletedItemIndexPaths = nil;
    self.insertedItemIndexPaths = nil;
    self.updatedItemIndexPaths = nil;
}

- (void)beginUpdates
{
    self.insertedSectionIndexes = [[NSMutableIndexSet alloc] init];
    self.deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
    self.deletedItemIndexPaths = [[NSMutableArray alloc] init];
    self.insertedItemIndexPaths = [[NSMutableArray alloc] init];
    self.updatedItemIndexPaths = [[NSMutableArray alloc] init];
    _isBeginUpdates = YES;
}
- (void)endUpdates
{
    _isBeginUpdates = NO;
    
    if (self.window == nil) {
        [self clearChanges];
        [self reloadData];
    } else {
        NSInteger totalChanges = [self.insertedSectionIndexes count] +
        [self.deletedSectionIndexes count] +
        [self.insertedItemIndexPaths count] +
        [self.deletedItemIndexPaths count] +
        [self.updatedItemIndexPaths count];
        
        if (totalChanges > 50) {
            [self clearChanges];
            [self reloadData];
            return;
        }
        
        [self performBatchUpdates:^{
            [super deleteSections:self.deletedSectionIndexes];
            [super insertSections:self.insertedSectionIndexes];
            
            [super deleteItemsAtIndexPaths:self.deletedItemIndexPaths];
            [super insertItemsAtIndexPaths:self.insertedItemIndexPaths];
            [super reloadItemsAtIndexPaths:self.updatedItemIndexPaths];
        } completion:^(BOOL finished) {
            [self clearChanges];
        }];
    }
}

#pragma mark Overwrite Function
-(void)insertSections:(NSIndexSet *)sections
{
    if (_isBeginUpdates) {
        [self.insertedSectionIndexes addIndexes:sections];
    } else {
        [super insertSections:sections];
    }
}
-(void)deleteSections:(NSIndexSet *)sections
{
    if (_isBeginUpdates) {
        [self.deletedSectionIndexes addIndexes:sections];
        
        //	since we are deleting entire section,
        //	remove items scheduled to be deleted/updated from this same section
        NSMutableArray *indexPathsInSection = [NSMutableArray array];
        //
        for (NSIndexPath *indexPath in self.deletedItemIndexPaths) {
            if ([sections containsIndex:indexPath.section]) {
                [indexPathsInSection addObject:indexPath];
            }
        }
        [self.deletedItemIndexPaths removeObjectsInArray:indexPathsInSection];
        //
        [indexPathsInSection removeAllObjects];
        for (NSIndexPath *indexPath in self.updatedItemIndexPaths) {
            if ([sections containsIndex:indexPath.section]) {
                [indexPathsInSection addObject:indexPath];
            }
        }
        [self.updatedItemIndexPaths removeObjectsInArray:indexPathsInSection];
        
    } else {
        [super deleteSections:sections];
    }
}

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (_isBeginUpdates) {
        for (NSIndexPath* indexPath in indexPaths) {
            if ([self.insertedSectionIndexes containsIndex:indexPath.section]) {
                continue;
            }
            [self.insertedItemIndexPaths addObject:indexPath];
        }
    } else {
        [self insertItemsAtIndexPaths:indexPaths];
    }
}
- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (_isBeginUpdates) {
        for (NSIndexPath* indexPath in indexPaths) {
            if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
                continue;
            }
            [self.deletedItemIndexPaths addObject:indexPath];
        }
    } else {
        [self deleteItemsAtIndexPaths:indexPaths];
    }
}
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (_isBeginUpdates) {
        for (NSIndexPath* indexPath in indexPaths) {
            if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
                continue;
            }
            if ([self.updatedItemIndexPaths containsObject:indexPath] == NO) {
                [self.updatedItemIndexPaths addObject:indexPath];
            }
        }
    } else {
        [super reloadItemsAtIndexPaths:indexPaths];
    }
    
}
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    if (_isBeginUpdates) {
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section] == NO) {
            [self.insertedItemIndexPaths addObject:newIndexPath];
        }
        if ([self.deletedSectionIndexes containsIndex:indexPath.section] == NO) {
            [self.deletedItemIndexPaths addObject:indexPath];
        }
    } else {
        [super moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

@end
