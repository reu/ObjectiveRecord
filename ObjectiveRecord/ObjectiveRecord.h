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

+ (NSMutableArray *)findWithSQL:(NSString *)sql;
+ (id <ObjectiveRecordAdapter>)connection;

+ (NSString *)tableName;
+ (NSArray *)columnNames;

- (BOOL)isNewRecord;
- (void)save;

@property (nonatomic, retain) NSNumber *primaryKey;

@end
