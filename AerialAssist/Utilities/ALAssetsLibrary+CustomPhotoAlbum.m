//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "PhotoAttributes.h"

@implementation ALAssetsLibrary(CustomPhotoAlbum)

-(void)getImageFromAssetURL:(NSURL*)assetURL withCompletionBlock:(SaveImageCompletion)completionBlock {
    // NSLog(@"asset URL = %@", assetURL);
    [self assetForURL:assetURL
          resultBlock:resultblock
         failureBlock:failureblock];
}

ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
{
    /* Minimum working code */
    ALAssetRepresentation *rep = [myasset defaultRepresentation];
 //   NSLog(@"asset date = %@", [myasset valueForProperty:ALAssetPropertyDate]);
 //   NSLog(@"asset representations = %@", [myasset valueForProperty:ALAssetPropertyRepresentations]);
 //   NSLog(@"asset property url = %@", [myasset valueForProperty:ALAssetPropertyURLs]);
    CGImageRef iref = [rep fullResolutionImage];
    ALAssetOrientation orientation = [rep orientation];
    if (iref) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:[UIImage imageWithCGImage:iref scale:1.0 orientation:(UIImageOrientation)orientation] forKey:@"photoImage"]]];
    }
/*
    PhotoAttributes *photoData = [[PhotoAttributes alloc] init];
    ALAssetRepresentation *rep = [myasset defaultRepresentation];
    ALAssetOrientation orientation = [rep orientation];
    CGImageRef iref = [rep fullResolutionImage];
        photoData.regularImage = [UIImage imageWithCGImage:iref scale:1.0 orientation:(UIImageOrientation)orientation];
        NSLog(@"Got regular image = %@", photoData.regularImage);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:[UIImage imageWithCGImage:iref] forKey:@"photoImage"]]];
//    });
    dispatch_sync(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        photoData.fullImage = [UIImage imageWithCGImage:[rep fullScreenImage] scale:1.0 orientation:(UIImageOrientation)orientation];
        NSLog(@"Got full image");
    });
    dispatch_sync(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        photoData.thumbnail = [UIImage imageWithCGImage:[myasset thumbnail] scale:1.0 orientation:(UIImageOrientation)orientation];
        NSLog(@"Got thumbnail");
    });*/

/*    if (photoData) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:photoData forKey:@"photoImage"]]];
    }*/
};

ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:nil forKey:@"photoImage"]]];
    
    NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
};

-(void)getImageFromAssetDate:(NSDate *)assetDate fromAlbum:albumName withCompletionBlock:(SaveImageCompletion)completionBlock {
    // Retrieving images from the photo library
    //NSLog(@"asset date = %@", assetDate);
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //compare the names of the albums
        if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
            ////NSLog(@"Found Album");
            NSLog(@"Number of assets in group %d", [group numberOfAssets]);
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if(asset) {
                    //NSLog(@"Vurrently checking %@", [asset valueForProperty:ALAssetPropertyDate]);
                    if ([[asset valueForProperty:ALAssetPropertyDate] isEqualToDate:assetDate]) {
                       // NSLog(@"enumerated asset date %@", [asset valueForProperty:ALAssetPropertyDate]);
                       // NSLog(@"enumerated asset URL %@", [asset valueForProperty:ALAssetPropertyAssetURL]);
                        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1.0 orientation:[[asset defaultRepresentation]orientation]];
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[[asset valueForProperty:ALAssetPropertyAssetURL], image] forKeys:@[@"assetURL", @"photoImage"]]]];
//                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:image forKey:@"photoImage"]]];
     
                    }
                   // else NSLog(@"Dates are not equal");
                }
            }];
        }
    }failureBlock: completionBlock];
     
}

// Save image to photo library
-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    //write the image data to the assets library (camera roll)
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation
                        completionBlock:^(NSURL* assetURL, NSError* error) {
                          //error handling
                          if (error!=nil) {
                              completionBlock(error);
                              return;
                          }

                          //add the asset to the custom photo album
                          [self addAssetURL: assetURL 
                                    toAlbum:albumName 
                        withCompletionBlock:completionBlock];
      
                      }];
}

// User chose an existing image so don't save, just add to album
-(void)addImage:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    //add the asset to the custom photo album
    [self addAssetURL:assetURL toAlbum:albumName
                        withCompletionBlock:completionBlock];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock
{
    __block BOOL albumWasFound = NO;
    
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //compare the names of the albums
        if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
            //target album is found
            albumWasFound = YES;
            
            //get a hold of the photo's asset instance
            [self assetForURL: assetURL resultBlock:^(ALAsset *asset) {
                //add photo to the target album
                [group addAsset: asset];
         
                //run the completion block
                completionBlock(nil);
                //NSLog(@"creation date %@", [asset valueForProperty:ALAssetPropertyDate]);
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoSaved" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[assetURL, [asset valueForProperty:ALAssetPropertyDate]] forKeys:@[@"assetURL", @"photoDate"]]]];
            } failureBlock: completionBlock];

            //album was found, bail out of the method
            return;
        }
                            
        if (group==nil && albumWasFound==NO) {
            //photo albums are over, target album does not exist, thus create it
                                
            __weak ALAssetsLibrary* weakSelf = self;

            //create new assets album
            [self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                                                                  
                //get the photo's instance
                [weakSelf assetForURL: assetURL resultBlock:^(ALAsset *asset) {

                    //add photo to the newly created album
                    [group addAsset: asset];
      
                    //call the completion block
                    completionBlock(nil);
                    //NSLog(@"creation date %@", [asset valueForProperty:ALAssetPropertyDate]);
 //                   NSArray *objects = [NSArray arrayWithObjects:assetURL, [asset valueForProperty:ALAssetPropertyDate], nil];
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoSaved" object:nil userInfo:[NSDictionary dictionaryWithObjects:@[assetURL, [asset valueForProperty:ALAssetPropertyDate]] forKeys:@[@"assetURL", @"photoDate"]]]];

                } failureBlock: completionBlock];
                
            } failureBlock: completionBlock];

            //should be the last iteration anyway, but just in case
            return;
        }
                            
    } failureBlock: completionBlock];

}

@end
