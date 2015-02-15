//
//  NSData+SnapAdditions.h
//  Snap
//
//  Created by Ray Wenderlich on 5/25/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

@interface NSData (RoboAdditions)

- (int)rw_int32AtOffset:(size_t)offset;
- (short)rw_int16AtOffset:(size_t)offset;
- (char)rw_int8AtOffset:(size_t)offset;
- (NSString *)rw_stringAtOffset:(size_t)offset bytesRead:(size_t *)amount;
- (NSData *)rw_dataAtOffset:(size_t)offset bytesRead:(size_t *)amount;
@end

@interface NSMutableData (RoboAdditions)

- (void)rw_appendInt32:(int)value;
- (void)rw_appendInt16:(short)value;
- (void)rw_appendInt8:(char)value;
- (void)rw_appendString:(NSString *)string;
- (void)rw_appendData:(NSData *)data;
- (void)rw_appendDictionary:(NSDictionary *)dictionary;

@end
