//
//  ObjectiveRecordAdapter.h
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/7/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjectiveRecordAdapter

- (id)initWithPath:(NSString *)path;
- (id)connection;
- (NSArray *)executeQuery:(NSString *)sql;
- (NSArray *)executeQueryWithParameters:(NSString *)sql, ...;
- (NSArray *)columnsForTable:(NSString *)tableName;

- (void)beginTransaction;
- (void)commitTransaction;
- (void)rollbackTransaction;

@end
