//
//  ObjectiveRecordAdapter.h
//  ObjectiveRecord
//

#import <Foundation/Foundation.h>

@protocol ObjectiveRecordAdapter

- (id)initWithPath:(NSString *)path;
- (id)connection;
- (NSArray *)executeQuery:(NSString *)sql;
- (NSArray *)executeQueryWithParameters:(NSString *)sql, ...;
- (NSArray *)columnsForTable:(NSString *)tableName;
- (NSUInteger)lastInsertId;

- (void)beginTransaction;
- (void)commitTransaction;
- (void)rollbackTransaction;

@end
