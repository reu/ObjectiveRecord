//
//  SQLiteStatement.h
//  ObjectiveRecord
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteStatement : NSObject {
    sqlite3 *database;
    sqlite3_stmt *statement;
    NSArray *columnsCache;
}

- (id)initWithDatabase:(sqlite3 *)databaseConnection;
- (id)initWithDatabase:(sqlite3 *)databaseConnection andQuery:(NSString *)sql;

- (void)prepare:(NSString *)sql;

- (NSArray *)columns;
- (NSDictionary *)step;

- (int)bindParameterCount;

- (void)bindObject:(id)object toColumn:(int)index;

@end
