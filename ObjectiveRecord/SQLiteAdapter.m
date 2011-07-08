//
//  SQLiteAdapter.m
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/4/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import "SQLiteAdapter.h"

@interface SQLiteAdapter()

- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)pStmt;

- (NSArray *)executeStatement:(sqlite3_stmt *)query;
    
- (sqlite3_stmt *)prepareQuery:(NSString *)sql;

- (NSArray *)columnsForQuery:(sqlite3_stmt *)query;

- (id)castedValueForColumnIndex:(int)columnIndex forQuery:(sqlite3_stmt *)query;

- (NSDate *)parseDate:(NSString *)date;

- (NSDate *)parseDateTime:(NSString *)dateTime;

@end


@implementation SQLiteAdapter

- (id)initWithPath:(NSString *)path {
    if (self = [super init]) {
        if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
            [NSException raise:@"The informed path is not a valid sqlite3 database" 
                        format:@"couldn't connect to %@", path];
        }
    }
    
    return self;
}

- (id)initWithInMemoryDatabase {
    return [self initWithPath:@":memory:"];
}

- (id)connection {
    return (id)database;
}

- (NSArray *)executeQuery:(NSString *)sql {
    return [self executeStatement:[self prepareQuery:sql]];
}

- (NSArray *)executeQueryWithParameters:(NSString *)sql, ... {
    sqlite3_stmt *query = [self prepareQuery:sql];
    
    va_list parameters;
    va_start(parameters, sql);
    
    int bindCount = sqlite3_bind_parameter_count(query);
    
    for (int i = 1; i <= bindCount; i++) {
        [self bindObject:va_arg(parameters, id) toColumn:i inStatement:query];
    }

    va_end(parameters);
    
    return [self executeStatement:query];
}

- (void)dealloc {
    sqlite3_close(database);
}

#pragma mark -
#pragma mark Private methods

// Borrowed from fmdb https://github.com/ccgus/fmdb/blob/master/src/FMDatabase.m#L294-334
- (void)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt *)pStmt {
    if ((!obj) || ((NSNull *)obj == [NSNull null])) {
        sqlite3_bind_null(pStmt, idx);
    } else if ([obj isKindOfClass:[NSData class]]) {
        sqlite3_bind_blob(pStmt, idx, [obj bytes], (int)[obj length], SQLITE_STATIC);
    } else if ([obj isKindOfClass:[NSDate class]]) {
        sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        } else if (strcmp([obj objCType], @encode(int)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        } else if (strcmp([obj objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        } else if (strcmp([obj objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        } else if (strcmp([obj objCType], @encode(float)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        } else if (strcmp([obj objCType], @encode(double)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        } else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    } else {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

- (NSArray *)executeStatement:(sqlite3_stmt *)query {
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
            } else if([columnType isEqualToString:@"date"]) {
                return [self parseDate:columnValue];
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

- (NSDate *)parseDate:(NSString *)date {
   NSDateFormatter *formater = [[NSDateFormatter alloc] init];
   [formater setDateFormat:@"yyyy-mm-dd"];
   
   NSDate *parsedDate = [formater dateFromString:date];
   
   [formater release];
   
   return parsedDate;
}
@end
