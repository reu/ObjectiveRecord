//
//  SQLiteAdapter.h
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/4/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <ObjectiveRecordAdapter.h>

@interface SQLiteAdapter : NSObject <ObjectiveRecordAdapter> {
    sqlite3 *database;
    BOOL currentlyInTransaction;
}

- (id)initWithPath:(NSString *)path;
- (id)initWithInMemoryDatabase;
- (id)connection;
- (NSArray *)executeQuery:(NSString *)sql;
- (NSArray *)executeQueryWithParameters:(NSString *)sql, ...;
- (NSArray *)columnsForTable:(NSString *)tableName;
- (NSUInteger)lastInsertId;

- (void)beginTransaction;
- (void)commitTransaction;
- (void)rollbackTransaction;

@end
