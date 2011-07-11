//
//  ObjectiveRecord.h
//  ObjectiveRecord
//
//  Created by Guilherme da Silva Mello on 7/7/11.
//  Copyright 2011 Guimello Tecnologia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveRecordAdapter.h"
#import "SQLiteAdapter.h"

@interface ObjectiveRecord : NSObject {
    NSNumber *primaryKey;
}

+ (NSMutableArray *)findWithSQL:(NSString *)sql;
+ (id)initWithAttributes:(NSDictionary *)attributes;
+ (id <ObjectiveRecordAdapter>)connection;

+ (NSString *)tableName;
+ (NSArray *)columnNames;

@property (nonatomic, retain) NSNumber *primaryKey;

@end
