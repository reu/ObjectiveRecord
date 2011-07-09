//
//  SQLiteStatement.h
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/8/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteStatement : NSObject {
    sqlite3 *database;
    sqlite3_stmt *statement;
}

- (id)initWithDatabase:(sqlite3 *)databaseConnection;
- (id)initWithDatabase:(sqlite3 *)databaseConnection andQuery:(NSString *)sql;

- (void)prepare:(NSString *)sql;

- (NSArray *)columns;
- (NSDictionary *)step;

- (int)bindParameterCount;

- (void)bindObject:(id)object toColumn:(int)index;

@end
