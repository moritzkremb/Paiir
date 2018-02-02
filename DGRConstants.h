//
//  DGRConstants.h
//  Duogram1
//
//  Created by Moritz Kremb on 6/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Flurry.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface DGRConstants : NSObject

#pragma mark - Aviary

extern NSString *const kAviaryAPIKey;
extern NSString *const kAviarySecret;

#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kDGRActivityClassKey;

// Field key
extern NSString *const kDGRActivityUser1;
extern NSString *const kDGRActivityUser2;
extern NSString *const kDGRActivityTypeKey;
extern NSString *const kDGRActivityPhotoPointerKey;

// Type values
extern NSString *const kDGRActivityTypeLike;
extern NSString *const kDGRActivityTypeApprove;
extern NSString *const kDGRActivityTypeComplete;
extern NSString *const kDGRActivityTypeComment;
extern NSString *const kDGRActivityTypeConnectedUserPostsNewMono;
extern NSString *const kDGRActivityTypeStaffpick;


#pragma mark - PFObject CPhoto Class
// Class key
extern NSString *const kDGRCPhotoClassKey;

// Field key
extern NSString *const kDGRCPhotoUser1;
extern NSString *const kDGRCPhotoUser2;
extern NSString *const kDGRCPhotoImage1;
extern NSString *const kDGRCPhotoImage2;
extern NSString *const kDGRCPhotoTimeplace1;
extern NSString *const kDGRCPhotoTimeplace2;
extern NSString *const kDGRCPhotoThumbnail;
extern NSString *const kDGRCPhotoObjectId;


#pragma mark - PFObject UPhoto Class
// Class key
extern NSString *const kDGRUPhotoClassKey;

#pragma mark - PFObject User Class
// Class key
extern NSString *const kDGRUserClassKey;

#pragma mark - Home Cell
extern NSInteger kCatchWidth;


#pragma mark - classes

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
