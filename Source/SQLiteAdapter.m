//
//  SQLiteAdapter.m
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/4/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import "SQLiteAdapter.h"


@implementation SQLiteAdapter

- (id)initWithPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
            [NSException raise:@"The informed path is not a valid sqlite3 database" 
                        format:@"couldn't connect to %d", path];
        }
    } else {
        [NSException raise:@"You must specify the path to a pre-existing sqlite database" 
                     format:@"%d is not a sqlite database", path];
    }
    
    return self;
}

- (id)connection {
    return (id)database;
}

@end
