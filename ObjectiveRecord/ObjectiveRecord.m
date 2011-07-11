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

@interface ObjectiveRecord(private)

+ (NSString *)pathToDb;
- (void)create;

@end

@implementation ObjectiveRecord

@synthesize primaryKey;

+ (id)initWithAttributes:(NSDictionary *)attributes {
    id object = [self new];
    
    if (object) {
        for(NSString *key in attributes) {
            NSString *normalizedKey = [key isEqualToString:@"id"] ? @"primaryKey": key;
            
            if ([object respondsToSelector:NSSelectorFromString(normalizedKey)]) {
                [object setValue:[attributes objectForKey:key] forKey:normalizedKey];
            } else {
                // Don't know if we should silent fail here... anyways, the user should receive some kind of warning
            }

        }
    }
    
    return [object autorelease];
}

+ (NSMutableArray *)findWithSQL:(NSString *)sql {
    NSMutableArray *objectiveRecords = [NSMutableArray array];
    NSArray *rows = [[self connection] executeQuery:sql];
    
    for(NSDictionary *values in rows)
        [objectiveRecords addObject:[self initWithAttributes:values]];
    
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

- (void)save {
    [self create];
}

#pragma mark -
#pragma mark Private methods

+ (NSArray *)columnNamesWithoutPrimaryKey {
    NSMutableArray *columnNames = [NSMutableArray arrayWithArray:[self columnNames]];
    [columnNames removeObjectAtIndex:0];
    
    return columnNames;
}

// Of course we should use prepared statements here, but this was the fastest implementation for the proof of concept
- (void)create {
    NSArray *columnNames = [[self class] columnNamesWithoutPrimaryKey];
    NSMutableArray *values = [NSMutableArray array];
    
    for (NSString *column in columnNames) {
        [values addObject:[NSString stringWithFormat:@"'%@'", [self valueForKey:column]]];
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", 
                     [[self class] tableName], 
                     [columnNames componentsJoinedByString:@","],
                     [values componentsJoinedByString:@","]];
    
    [[[self class] connection] executeQuery:sql];
}

+ (NSString *)pathToDb {
    //Having a hard time making these paths work during test.
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"plist"];
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