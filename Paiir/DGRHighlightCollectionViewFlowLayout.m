//
//  DGRHighlightCollectionViewFlowLayout.m
//  Paiir
//
//  Created by Moritz Kremb on 17/10/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRHighlightCollectionViewFlowLayout.h"
#import "DGRConstants.h"

@implementation DGRHighlightCollectionViewFlowLayout

-(CGSize) collectionViewContentSize {
    
    // fixes a weird bug where content size was too small for iphone 4
    
    if (!IS_WIDESCREEN) {
        CGSize size = [super collectionViewContentSize];
        size.height = size.height + 80;
        return size;
    }
    else return [super collectionViewContentSize];
    
}

@end
