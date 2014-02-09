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

/*
// Retrieving images from the photo library
-(void)getImage:(NSDate*)assetDate fromAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock {
    NSLog(@"asset date = %@", assetDate);
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                NSLog(@"Found Album");
                                NSLog(@"Number of assets in group %d", [group numberOfAssets]);
                                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                                    if(asset) {
                                        NSLog(@"enumerated asset date %@", [asset valueForProperty:ALAssetPropertyDate]);
                                        if ([[asset valueForProperty:ALAssetPropertyDate] isEqualToDate:assetDate]) {
                                            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:1.0 orientation:[[asset defaultRepresentation]orientation]];
                                            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:image forKey:@"photoImage"]]];

                                        }
                                        else NSLog(@"Dates are not equal");
                                    }
                                 }];

                            }
                            
                        }failureBlock: completionBlock];
    
}
*/

ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
{
    ALAssetRepresentation *rep = [myasset defaultRepresentation];
    CGImageRef iref = [rep fullResolutionImage];
    if (iref) {
        NSLog(@"asset default = %@", rep.filename);
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:[UIImage imageWithCGImage:iref] forKey:@"photoImage"]]];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:nil forKey:@"photoImage"]]];
    }
/*    PhotoAttributes *photoData = [[PhotoAttributes alloc] init];

    [[myasset defaultRepresentation] fullResolutionImage];
    // get the image
    ALAssetRepresentation *rep = [myasset defaultRepresentation];
    ALAssetOrientation orientation = [rep orientation];

    photoData.regularImage = [UIImage imageWithCGImage:[rep fullResolutionImage] scale:1.0 orientation:(UIImageOrientation)orientation];
//    photoData.fullImage = [UIImage imageWithCGImage:[rep fullScreenImage] scale:1.0 orientation:(UIImageOrientation)orientation];
//    photoData.thumbnail = [UIImage imageWithCGImage:[myasset thumbnail] scale:1.0 orientation:(UIImageOrientation)orientation];
    if (![rep fullResolutionImage]) NSLog(@"Here's your problem");
    NSLog(@"photo data full rep = %@", [rep fullScreenImage]);

    NSLog(@"photo data reg = %@", photoData.regularImage);
//    NSLog(@"photo data full = %@", photoData.fullImage);
//    NSLog(@"photo data thumb = %@", photoData.thumbnail);
    if (photoData) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:photoData forKey:@"photoImage"]]];
    }*/
};

ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"photoRetrieved" object:nil userInfo:[NSDictionary dictionaryWithObject:nil forKey:@"photoImage"]]];
    
    NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
};

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
    
    //setImageData:metadata:completionBlock
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
