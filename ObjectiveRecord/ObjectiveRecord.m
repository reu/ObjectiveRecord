//
//  ObjectiveRecord.m
//  ObjectiveRecord
//

#import "ObjectiveRecord.h"

// Class variable.
static id adapter;

@interface ObjectiveRecord(private)

+ (NSString *)pathToDb;
+ (NSMutableArray *)packRecordsForRows:(NSArray *)rows;
- (BOOL)create;
- (BOOL)update;

@end

@interface ObjectiveRecord(callbacks)

- (void)beforeSave;
- (void)beforeCreate;
- (void)beforeUpdate;
- (void)afterSave;
- (void)afterCreate;
- (void)afterUpdate;

@end

@implementation ObjectiveRecord

@synthesize primaryKey;

- (id)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        for(NSString *key in attributes) {
            NSString *normalizedKey = [key isEqualToString:@"id"] ? @"primaryKey": key;
            
            if ([self respondsToSelector:NSSelectorFromString(normalizedKey)]) {
                [self setValue:[attributes objectForKey:key] forKey:normalizedKey];
            } else {
                // Don't know if we should silent fail here... anyways, the user should receive some kind of warning
            }
        }
    }
    
    return self;
}

+ (id)recordWithAttributes:(NSDictionary *)attributes {
    return [[[self alloc] initWithAttributes:attributes] autorelease];
}

+ (NSMutableArray *)findWithSQL:(NSString *)sql {
    return [self packRecordsForRows:[[self connection] executeQuery:sql]];
}

+ (id)find:(NSUInteger)recordId {
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = ?", [self tableName]];
    
    return [[self packRecordsForRows:[[self connection] executeQueryWithParameters:query, [NSNumber numberWithInt:recordId]]] lastObject];
}

+ (NSMutableArray *)findAll {
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", [self tableName]];

    return [self packRecordsForRows:[[self connection] executeQuery:query]];
}

+ (NSMutableArray *)findAllWithConditions:(NSString *)conditions {
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [self tableName], conditions];

    return [self packRecordsForRows:[[self connection] executeQuery:query]];
}

+ (NSMutableArray *)findAllWithConditions:(NSString *)conditions andParameters:(NSArray *)parameters {
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [self tableName], conditions];

    return [self packRecordsForRows:[[self connection] executeQuery:query withParameters:parameters]];
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

// TODO: make this smarter, perhaps using an property newRecord as a cache or something
- (BOOL)isNewRecord {
    if ([self primaryKey]) {
        return [[self class] find:(NSUInteger)[self primaryKey]] != nil;
    } else {
        return YES;
    }
}

- (BOOL)save {
    @try {
        if ([self isNewRecord]) {
            [self beforeCreate];
            [self beforeSave];
            
            [self create];
            
            [self afterCreate];
            [self afterSave];
        } else {
            [self beforeUpdate];
            [self beforeSave];
            
            [self update];
            
            [self afterUpdate];
            [self afterSave];
        }
    }
    @catch (NSException * e) {
        return NO;
    }
    
    return YES;
}

- (BOOL)destroy {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = ?", [[self class] tableName]];
    
    @try {
        [[[self class] connection] executeQueryWithParameters:sql, [self primaryKey]];
    }
    @catch (NSException * e) {
        return NO;
    }
    
    return YES;
}


#pragma mark -
#pragma mark Callbacks

- (void)beforeSave {}
- (void)beforeCreate {}
- (void)beforeUpdate {}
- (void)afterSave {}
- (void)afterCreate {}
- (void)afterUpdate {}

#pragma mark -
#pragma mark Private methods

+ (NSArray *)columnNamesWithoutPrimaryKey {
    NSMutableArray *columnNames = [NSMutableArray arrayWithArray:[self columnNames]];
    [columnNames removeObjectAtIndex:0];
    
    return columnNames;
}

- (BOOL)create {
    NSArray *columnNames = [[self class] columnNamesWithoutPrimaryKey];
    
    NSMutableArray *bindings = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    for (NSString *column in columnNames) {
        id value = [self valueForKey:column];
        [values addObject:value ? value : @""];
        [bindings addObject:@"?"];
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", 
                     [[self class] tableName], 
                     [columnNames componentsJoinedByString:@","],
                     [bindings componentsJoinedByString:@","]];
    
    @try {
        [[[self class] connection] executeQuery:sql withParameters:values];
    }
    @catch (NSException *error) {
        return NO;
    }
    
    [self setValue:[NSNumber numberWithInteger:[[[self class] connection] lastInsertId]] forKey:@"primaryKey"];
    
    return YES;
}

- (BOOL)update {
    NSArray *columnNames = [[self class] columnNamesWithoutPrimaryKey];
    
    NSMutableArray *bindings = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    for (NSString *column in columnNames) {
        id value = [self valueForKey:column];
        [values addObject:value ? value : @""];
        
        [bindings addObject:[NSString stringWithFormat:@"%@ = ?", column]];
    }
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE id = %@", 
                     [[self class] tableName], 
                     [bindings componentsJoinedByString:@","],
                     [self primaryKey]];
    
    @try {
        [[[self class] connection] executeQuery:sql withParameters:values];
    }
    @catch (NSException *error) {
        return NO;
    }
    
    return YES;
}

+ (NSString *)pathToDb {
    //Having a hard time making these paths work during test.
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"plist"];
    if (!plistPath)
        plistPath = @"database.plist";
    
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *dbName = [NSString stringWithString:[config valueForKey:@"database"]];
    
    [config release];
    
    if (!dbName || [dbName isEqualToString:@":memory:"])
        return dbName;

    return [[NSBundle mainBundle] pathForResource:dbName ofType:@"db"];
}

+ (NSMutableArray *)packRecordsForRows:(NSArray *)rows {
    NSMutableArray *objectiveRecords = [NSMutableArray array];

    if (!rows)
        return objectiveRecords;

    for(NSDictionary *attributes in rows)
        [objectiveRecords addObject:[self recordWithAttributes:attributes]];

    return objectiveRecords;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
    [primaryKey release];

    [super dealloc];
}

@end