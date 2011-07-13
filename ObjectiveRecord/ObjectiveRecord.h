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

+ (NSArray *)findWithSQL:(NSString *)sql;
+ (NSArray *)findAll;
+ (NSArray *)findAllWithConditions:(NSString *)conditions;
+ (NSArray *)findAllWithConditions:(NSString *)conditions andParameters:(NSArray *)parameters;
+ (id <ObjectiveRecordAdapter>)connection;

+ (NSString *)tableName;
+ (NSArray *)columnNames;

- (BOOL)isNewRecord;
- (void)save;

@property (nonatomic, retain) NSNumber *primaryKey;

@end
