//
//  DGRConstants.m
//  Duogram1
//
//  Created by Moritz Kremb on 6/3/14.
//  Copyright (c) 2014 Kremb. All rights reserved.
//

#import "DGRConstants.h"

@implementation DGRConstants

#pragma mark - Aviary
NSString *const kAviaryAPIKey = @"af342a96e373a275";
NSString *const kAviarySecret = @"3eaab52408eeeea0";


#pragma mark - PFObject Activity Class
// Class key
NSString *const kDGRActivityClassKey = @"Activity";

// Field key
NSString *const kDGRActivityUser1 = @"user1";
NSString *const kDGRActivityUser2 = @"user2";
NSString *const kDGRActivityTypeKey = @"type";
NSString *const kDGRActivityPhotoKey = @"photopointer";

// Type values
NSString *const kDGRActivityTypeLike = @"like";
NSString *const kDGRActivityTypeApprove = @"approve";
NSString *const kDGRActivityTypeComplete = @"complete";
NSString *const kDGRActivityTypeComment = @"comment";
NSString *const kDGRActivityTypeConnectedUserPostsNewMono = @"newMono";
NSString *const kDGRActivityTypeStaffpick = @"staffpick";


#pragma mark - PFObject CPhoto Class
// Class key
NSString *const kDGRCPhotoClassKey = @"CPhoto";

// Field key
NSString *const kDGRCPhotoUser1 = @"user1";
NSString *const kDGRCPhotoUser2 = @"user2";
NSString *const kDGRCPhotoImage1 = @"image1";
NSString *const kDGRCPhotoImage2 = @"image2";
NSString *const kDGRCPhotoTimeplace1 = @"timeplace1";
NSString *const kDGRCPhotoTimeplace2 = @"timeplace2";
NSString *const kDGRCPhotoThumbnail = @"thumbnail";
NSString *const kDGRCPhotoObjectId = @"objectId";

#pragma mark - PFObject UPhoto Class
// Class key
NSString *const kDGRUPhotoClassKey = @"UPhoto";

#pragma mark - PFObject User Class
// Class key
NSString *const kDGRUserClassKey = @"User";

#pragma mark - Home Cell
NSInteger kCatchWidth = 100.0f;

// Field key
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
