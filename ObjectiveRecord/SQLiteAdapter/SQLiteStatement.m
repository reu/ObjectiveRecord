//
//  SQLiteStatement.m
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/8/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import "SQLiteStatement.h"

@interface SQLiteStatement()

- (id)castedValueForColumnIndex:(int)columnIndex;
- (NSDate *)parseDateTime:(NSString *)dateTime;
- (NSDate *)parseDate:(NSString *)date;

@end

@implementation SQLiteStatement

- (id)initWithDatabase:(sqlite3 *)databaseConnection {
    if (self = [super init]) {
        database = databaseConnection;
    }
    
    return self;
}

- (id)initWithDatabase:(sqlite3 *)databaseConnection andQuery:(NSString *)sql {
    if (self = [self initWithDatabase:databaseConnection]) {
        [self prepare:sql];
    }
    
    return self;
}

- (void)prepare:(NSString *)sql {
    sqlite3_stmt *query;
    const char *tail;
    
    int result = sqlite3_prepare_v2(database, [sql UTF8String], [sql lengthOfBytesUsingEncoding:NSUTF8StringEncoding], &query, &tail);
    
    if (result != SQLITE_OK || query == NULL) {
        [NSException raise:@"Error while preparing the sqlite query" 
                    format:@"could not prepare %@", sql];
    }
    
    statement = query;
}

- (NSArray *)columns {
    NSMutableArray *columns = [NSMutableArray array];
    
    int columnCount = sqlite3_column_count(statement);
    
    for (int i = 0; i < columnCount; i++) {
        const char *columnName = sqlite3_column_name(statement, i);
        [columns addObject:[NSString stringWithUTF8String:columnName]];
    }
    
    return columns;
}

- (int)bindParameterCount {
    return sqlite3_bind_parameter_count(statement);
}

// Borrowed from fmdb https://github.com/ccgus/fmdb/blob/master/src/FMDatabase.m#L294-334
- (void)bindObject:(id)object toColumn:(int)columnIndex {
    if ((!object) || ((NSNull *)object == [NSNull null])) {
        sqlite3_bind_null(statement, columnIndex);
    } else if ([object isKindOfClass:[NSData class]]) {
        sqlite3_bind_blob(statement, columnIndex, [object bytes], (int)[object length], SQLITE_STATIC);
    } else if ([object isKindOfClass:[NSDate class]]) {
        sqlite3_bind_double(statement, columnIndex, [object timeIntervalSince1970]);
    } else if ([object isKindOfClass:[NSNumber class]]) {
        if (strcmp([object objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(statement, columnIndex, ([object boolValue] ? 1 : 0));
        } else if (strcmp([object objCType], @encode(int)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, [object longValue]);
        } else if (strcmp([object objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, [object longValue]);
        } else if (strcmp([object objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, [object longLongValue]);
        } else if (strcmp([object objCType], @encode(float)) == 0) {
            sqlite3_bind_double(statement, columnIndex, [object floatValue]);
        } else if (strcmp([object objCType], @encode(double)) == 0) {
            sqlite3_bind_double(statement, columnIndex, [object doubleValue]);
        } else {
            sqlite3_bind_text(statement, columnIndex, [[object description] UTF8String], -1, SQLITE_STATIC);
        }
    } else {
        sqlite3_bind_text(statement, columnIndex, [[object description] UTF8String], -1, SQLITE_STATIC);
    }
}

- (NSMutableDictionary *)step {
    NSArray *columns = [self columns];
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        NSMutableDictionary *row = [NSMutableDictionary dictionary];
        
        int columnIndex = 0;
        
        for (NSString *column in columns) {
            [row setObject:[self castedValueForColumnIndex:columnIndex] forKey:column];
            
            columnIndex++;
        }
        
        return row;
    } else {
        return nil;
    }
}

- (void)dealloc {
    sqlite3_finalize(statement);
}

#pragma mark -
#pragma mark Private methods


- (id)castedValueForColumnIndex:(int)columnIndex {    
    NSString *columnValue;
    
    switch (sqlite3_column_type(statement, columnIndex)) {
        case SQLITE_INTEGER:
            return [NSNumber numberWithInt:sqlite3_column_int(statement, columnIndex)];
            break;
        case SQLITE_FLOAT:
            return [NSNumber numberWithDouble:sqlite3_column_double(statement, columnIndex)];
            break;
        case SQLITE_TEXT:
            columnValue = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, columnIndex)];
            
            NSString *columnType = [[NSString stringWithUTF8String:(const char *)sqlite3_column_decltype(statement, columnIndex)] lowercaseString];
            
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
