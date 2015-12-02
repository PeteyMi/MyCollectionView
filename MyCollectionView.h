//
//  MyCollectionView.h
//  MyCollectionView
//
//  Created by Petey Mi on 12/2/15.
//  Copyright © 2015 Petey Mi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionView : UICollectionView



- (void)beginUpdates;   // allow multiple insert/delete of items and sections to be animated simultaneously. Nestable
- (void)endUpdates;     // only call insert/delete/reload calls or change the editing state inside an update block.  otherwise things like row count, etc. may be invalid.

@end
