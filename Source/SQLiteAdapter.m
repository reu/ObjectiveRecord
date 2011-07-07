//
//  SQLiteAdapter.m
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/4/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import "SQLiteAdapter.h"

@interface SQLiteAdapter()

- (sqlite3_stmt *)prepareQuery:(NSString *)sql;

- (NSArray *)columnsForQuery:(sqlite3_stmt *)query;

- (id)castedValueForColumnIndex:(int)columnIndex forQuery:(sqlite3_stmt *)query;

- (NSDate *)parseDateTime:(NSString *)dateTime;

@end


@implementation SQLiteAdapter

- (id)initWithPath:(NSString *)path {
    if (self = [super init]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
                [NSException raise:@"The informed path is not a valid sqlite3 database" 
                            format:@"couldn't connect to %@", path];
            }
        } else {
            [NSException raise:@"You must specify the path to a pre-existing sqlite database" 
                         format:@"%@ is not a sqlite database", path];
        }
    }
    
    return self;
}

- (id)connection {
    return (id)database;
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

#pragma mark -
#pragma mark Private methods

- (sqlite3_stmt *)prepareQuery:(NSString *)sql {
    sqlite3_stmt *query;
    const char *tail;
    
    int result = sqlite3_prepare_v2(database, [sql UTF8String], [sql lengthOfBytesUsingEncoding:NSUTF8StringEncoding], &query, &tail);
    
    if (result != SQLITE_OK || query == NULL) {
        [NSException raise:@"Error while preparing the sqlite query" 
                    format:@"could not prepare %@", sql];
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
    NSString *columnValue;
    
    switch (sqlite3_column_type(query, columnIndex)) {
        case SQLITE_INTEGER:
            return [NSNumber numberWithInt:sqlite3_column_int(query, columnIndex)];
            break;
        case SQLITE_FLOAT:
            return [NSNumber numberWithDouble:sqlite3_column_double(query, columnIndex)];
            break;
        case SQLITE_TEXT:
            columnValue = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(query, columnIndex)];
            
            NSString *columnType = [[NSString stringWithUTF8String:(const char *)sqlite3_column_decltype(query, columnIndex)] lowercaseString];
            
            if ([columnType isEqualToString:@"datetime"]) {
                return [self parseDateTime:columnValue];
            } else {
                return columnValue;
            }
            
            break;
        case SQLITE_NULL:
            return nil;
            break;
        default:
            break;
    }
    
    return nil;
}

- (NSDate *)parseDateTime:(NSString *)dateTime {
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-mm-dd HH:mm:ss"];
    
    NSDate *parsedDateTime = [formater dateFromString:dateTime];
    
    [formater release];
    
    return parsedDateTime;
}

@end
