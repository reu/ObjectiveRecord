//
//  ObjectiveRecord.m
//  ObjectiveRecord
//
//  Created by Guilherme da Silva Mello on 7/7/11.
//  Copyright 2011 Guimello Tecnologia. All rights reserved.
//

#import "ObjectiveRecord.h"

// Class variable.
static id adapter;

@interface ObjectiveRecord()

+ (NSString *)pathToDb;

@end

@implementation ObjectiveRecord

@synthesize primaryKey;

+ (id)new:(NSDictionary *)values {
    id object = [self new];
    
    if (object)
        for(NSString *key in values)
            [object setValue:[values objectForKey:key] forKey:([key isEqualToString:@"id"] ? @"primaryKey": key)];
    
    return [object autorelease];
}

+ (NSMutableArray *)findBySQL:(NSString *)sql {
    NSMutableArray *objectiveRecords = [NSMutableArray array];
    NSArray *rows = [[self connection] executeQuery:sql];
    
    for(NSDictionary *values in rows)
        [objectiveRecords addObject:[self new:values]];
    
    return objectiveRecords;
}

+ (id)connection {
    if (!adapter)
        adapter = [[SQLiteAdapter alloc] initWithPath:[self pathToDb]];
    
    return adapter;
}

+ (NSString *)tableName {
    return [NSStringFromClass([self class]) lowercaseString];
}

+ (NSArray *)columnNames {
    return [[self connection] columnsForTable:[self tableName]];
}

#pragma mark -
#pragma mark Private methods

+ (NSString *)pathToDb {
    //Having a hard time making these paths work during test.
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"plist"];
    if (!plistPath)
        plistPath = @"database.plist";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *dbName = [config valueForKey:@"database"];
    
    [config release];
    
    if ([dbName isEqualToString:@":memory:"])
        return dbName;

    return [NSString stringWithFormat:@"%@/%@.db", [NSBundle mainBundle], dbName];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
    [super dealloc];
}

@end