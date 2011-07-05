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

- (sqlite3_stmt *)prepareQuery:(NSString *)sql {
    sqlite3_stmt *query;
    const char *tail;
    
    int result = sqlite3_prepare_v2(database, [sql UTF8String], [sql lengthOfBytesUsingEncoding:NSUTF8StringEncoding], &query, &tail);
    
    if (result != SQLITE_OK || query == NULL) {
        [NSException raise:@"Error while preparing the sqlite query" 
                    format:@"could not prepare %d", sql];
    }
    
    return query;
}

- (NSArray *)columnsForQuery:(sqlite3_stmt *)query {
    NSMutableArray *columns = [NSMutableArray array];
    
    int columnCount = sqlite3_column_count(query);
    
    for (int i = 0; i < columnCount; i++) {
        const char *columnName = sqlite3_column_name(query, i);
        [columns addObject:[NSString stringWithUTF8String:columnName]];
    }
    
    return columns;
}

- (id)castedValueForColumnIndex:(int)columnIndex forQuery:(sqlite3_stmt *)query {    
    switch (sqlite3_column_type(query, columnIndex)) {
        case SQLITE_INTEGER:
            return [NSNumber numberWithInt:sqlite3_column_int(query, columnIndex)];
            break;
        case SQLITE_FLOAT:
            [NSNumber numberWithDouble:sqlite3_column_double(query, columnIndex)];
            break;
        case SQLITE_TEXT:
            return [NSString stringWithUTF8String:(const char *)sqlite3_column_text(query, columnIndex)];
            break;
        case SQLITE_NULL:
            return nil;
            break;
        default:
            break;
    }
    
    return nil;
}

- (NSArray *)executeQuery:(NSString *)sql {
    sqlite3_stmt *query;
    query = [self prepareQuery:sql];
    
    NSArray *columns = [self columnsForQuery:query];
    NSMutableArray *rows = [NSMutableArray array];
    
    while (sqlite3_step(query) == SQLITE_ROW) {
        NSMutableDictionary *row = [NSMutableDictionary dictionary];
        
        int columnIndex = 0;
        
        for (NSString *column in columns) {
            [row setObject:[self castedValueForColumnIndex:columnIndex forQuery:query]
                    forKey:column];
            
            columnIndex++;
        }
        
        [rows addObject:row];
    }
    
    return rows;
}

- (void)dealloc {
    sqlite3_close(database);
}

@end
