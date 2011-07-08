//
//  SQLiteConnectionSpec.m
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/4/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import "Kiwi.h"
#import "SQLiteAdapter.h"
#import "ObjectiveRecordAdapter.h"

SPEC_BEGIN(SQLiteAdapterSpec)

it(@"implements the ObjectiveRecordAdapter protocol", ^{
    [[SQLiteAdapter should] conformToProtocol:@protocol(ObjectiveRecordAdapter)];
});

describe(@"initWithPath", ^{
    context(@"when the path points to an existent database", ^{
        it(@"successfully instantiates the class", ^{
            [[theBlock(^{
                [[SQLiteAdapter alloc] initWithPath:@"Specs/Fixtures/test.db"];
            }) shouldNot] raise];
        });
    });
    
    context(@"when the path points to an unexistent database", ^{
        __block NSString *unexistentDatabasePath = @"Specs/Fixtures/unexistent.db";
        __block NSFileManager *fileManager = [NSFileManager defaultManager];
        
        afterEach(^{
            if ([fileManager fileExistsAtPath:unexistentDatabasePath]) {
                [fileManager removeItemAtPath:unexistentDatabasePath error:nil];
            }
        });
        
        it(@"successfully instantiates the class", ^{
            [[theBlock(^{
                [[SQLiteAdapter alloc] initWithPath:unexistentDatabasePath];
            }) shouldNot] raise];
        });
        
        it(@"automatically creates the database file", ^{
            [[SQLiteAdapter alloc] initWithPath:unexistentDatabasePath];
            BOOL fileExists = [fileManager fileExistsAtPath:unexistentDatabasePath];
            [[theValue(fileExists) should] beTrue];
        });
    });
    
    context(@"when :memory: is informed", ^{
        it(@"doesn't create a file, as it should be an in memory database", ^{
            [[SQLiteAdapter alloc] initWithPath:@":memory:"];

            BOOL databaseFileCreated = [[NSFileManager defaultManager] fileExistsAtPath:@":memory:"];
            [[theValue(databaseFileCreated) should] beFalse];
        });
    });
});

describe(@"initWithInMemoryDatabase", ^{
    it(@"inits an in memory database", ^{
        [[theBlock(^{
            [[SQLiteAdapter alloc] initWithInMemoryDatabase];
        }) shouldNot] raise];
    });
});

describe(@"executeQuery", ^{
    __block SQLiteAdapter *adapter = [[SQLiteAdapter alloc] initWithInMemoryDatabase];
    
    context(@"that returns two rows", ^{
        [adapter executeQuery:@"CREATE TABLE user (id INTEGER PRIMARY KEY, name VARCHAR(255), age INTEGER, created_at DATETIME, birthday DATE)"];
        [adapter executeQuery:@"INSERT INTO user (name, age, created_at, birthday) VALUES ('Rodrigo', 25, '2010-01-01 00:02:03', '1986-03-31')"];
        [adapter executeQuery:@"INSERT INTO user (name, age, created_at, birthday) VALUES ('Marília', 28, '2010-10-01 10:00:00', '1983-01-25')"];
        
        describe(@"the first row", ^{
            __block NSArray *rows = [adapter executeQuery:@"SELECT * FROM user"];
            __block NSDictionary *row = [rows objectAtIndex:0];
            
            it(@"returns Rodrigo as its name", ^{
                [[[row objectForKey:@"name"] should] equal:@"Rodrigo"];
            });
            
            it(@"returns 25 as its age", ^{
                [[[row objectForKey:@"age"] should] equal:[NSNumber numberWithInt:25]];
            });
            
            it(@"returns a NSDate object for created_at", ^{
                [[[row objectForKey:@"created_at"] should] beKindOfClass:[NSDate class]];
            });
            
            it(@"returns a NSDate object for birthday", ^{
                [[[row objectForKey:@"birthday"] should] beKindOfClass:[NSDate class]];
            });
        });
    });
    
    afterAll(^{
        [adapter release];
    });
});

describe(@"executeQueryWithParameters", ^{
    __block SQLiteAdapter *adapter = [[SQLiteAdapter alloc] initWithInMemoryDatabase];
    
    [adapter executeQuery:@"CREATE TABLE bands (id INTEGER PRIMARY KEY, name VARCHAR(255), members INTEGER, last_show_at DATE)"];
    [adapter executeQuery:@"INSERT INTO bands (name, members, last_show_at) VALUES ('Dream Theater', 5, '2009-03-15')"];
    [adapter executeQuery:@"INSERT INTO bands (name, members, last_show_at) VALUES ('Rush', 3, '2011-01-23')"];
    [adapter executeQuery:@"INSERT INTO bands (name, members, last_show_at) VALUES ('Iron Maiden', 6, '2010-10-15')"];
    
    it(@"correct binds strings", ^{
        NSArray *result = [adapter executeQueryWithParameters:@"SELECT * FROM bands WHERE name LIKE ?", @"Dream Theater"];
        
        [[result should] haveCountOf:1];
    });
    
    it(@"correct binds numbers", ^{
        NSArray *result = [adapter executeQueryWithParameters:@"SELECT * FROM bands WHERE members > ?", [NSNumber numberWithInt:4]];
        
        [[result should] haveCountOf:2];
    });
    
    it(@"correct binds dates", ^{
        NSArray *result = [adapter executeQueryWithParameters:@"SELECT * FROM bands WHERE last_show_at > ?", @"2010-01-01"];
        
        [[result should] haveCountOf:2];
    });
    
    it(@"correct binds multiple parameters", ^{
        NSArray *result = [adapter executeQueryWithParameters:@"SELECT * FROM bands WHERE members < ? AND last_show_at < ?", [NSNumber numberWithInt:6], @"2011-01-01"];
        
        [[result should] haveCountOf:1];
    });
    
    afterAll(^{
        [adapter release];
    });
});

SPEC_END