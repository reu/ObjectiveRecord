//
//  SQLiteAdapter.m
//  ObjectiveRecord
//

#import "SQLiteAdapter.h"
#import "SQLiteStatement.h"

@interface SQLiteAdapter()

- (NSArray *)executeStatement:(SQLiteStatement *)statement;

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
    SQLiteStatement *statement = [[SQLiteStatement alloc] initWithDatabase:database andQuery:sql];
    
    return [self executeStatement:statement];
}

- (NSArray *)executeQueryWithParameters:(NSString *)sql, ... {
    SQLiteStatement *statement = [[SQLiteStatement alloc] initWithDatabase:database andQuery:sql];
    
    va_list parameters;
    va_start(parameters, sql);
    
    // TODO: move this implementation to SQLiteStatement
    int bindCount = [statement bindParameterCount];
    
    for (int i = 1; i <= bindCount; i++) {
        [statement bindObject:va_arg(parameters, id) toColumn:i];
    }
    
    va_end(parameters);
    
    return [self executeStatement:statement];
}

- (NSUInteger)lastInsertId {
    return (NSUInteger)sqlite3_last_insert_rowid(database);
}

- (void)beginTransaction {
    if (!currentlyInTransaction) {
        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
        currentlyInTransaction = YES;
    } else {
        [NSException raise:@"Already in transaction"
                    format:@"there is already an active transaction"];
    }
}

- (void)commitTransaction {
    if (currentlyInTransaction) {
        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, NULL);
        currentlyInTransaction = NO;
    } else {
        [NSException raise:@"Not in transaction"
                    format:@"there must be an active transaction in order to commit one"];
    }

}

- (void)rollbackTransaction {
    if (currentlyInTransaction) {
        sqlite3_exec(database, "ROLLBACK TRANSACTION", NULL, NULL, NULL);
        currentlyInTransaction = NO;
    } else {
        [NSException raise:@"Not in transaction"
                    format:@"there must be an active transaction in order to rollback one"];
    }
}

// This is a terrible approach, but I was getting repeating errors using PRAGMA table_info(tableName)
- (NSArray *)columnsForTable:(NSString *)tableName {
    SQLiteStatement *statement = [[SQLiteStatement alloc] initWithDatabase:database andQuery:[NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 1", tableName]];
    
    NSArray *columns = [statement columns];
    
    [statement release];
    
    return columns;
}

- (void)dealloc {
    sqlite3_close(database);
}


#pragma mark -
#pragma mark Private methods

- (NSArray *)executeStatement:(SQLiteStatement *)statement {
    NSMutableArray *rows = [NSMutableArray array];
    
    NSDictionary *row;
    
    while ((row = [statement step])) {
        [rows addObject:row];
    }
    
    [statement release];
    
    return rows;
}

@end
