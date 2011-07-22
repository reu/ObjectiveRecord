//
//  ObjectiveRecord.h
//  ObjectiveRecord
//

#import <Foundation/Foundation.h>
#import "ObjectiveRecordAdapter.h"
#import "SQLiteAdapter.h"

@interface ObjectiveRecord : NSObject {
    NSNumber *primaryKey;
}

- (id)initWithAttributes:(NSDictionary *)attributes;
+ (id)recordWithAttributes:(NSDictionary *)attributes;

+ (id)find:(NSUInteger)recordId;
+ (NSMutableArray *)findWithSQL:(NSString *)sql;
+ (NSMutableArray *)findAll;
+ (NSMutableArray *)findAllWithConditions:(NSString *)conditions;
+ (NSMutableArray *)findAllWithConditions:(NSString *)conditions andParameters:(NSArray *)parameters;
+ (id <ObjectiveRecordAdapter>)connection;

+ (NSString *)tableName;
+ (NSArray *)columnNames;
+ (NSString *)primaryKeyColumnName;

- (BOOL)isNewRecord;
- (BOOL)save;
- (BOOL)destroy;

@property (nonatomic, retain) NSNumber *primaryKey;

@end
