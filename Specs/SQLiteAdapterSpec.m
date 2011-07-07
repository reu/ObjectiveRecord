//
//  SQLiteConnectionSpec.m
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/4/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import "Kiwi.h"
#import "SQLiteAdapter.h"

SPEC_BEGIN(SQLiteAdapterSpec)

describe(@"initWithPath", ^{
    context(@"when the path points to an existent database", ^{
        it(@"successfully instantiates the class", ^{
            [[theBlock(^{
                [[SQLiteAdapter alloc] initWithPath:@"Specs/Fixtures/test.db"];
            }) shouldNot] raise];
        });
    });
    
    pending(@"when the path points to an invalid database", ^{
        it(@"raises an error", ^{
            [[theBlock(^{
                [[SQLiteAdapter alloc] initWithPath:@"Specs/Fixtures/nosqlite.db"];
            }) should] raise];
        });
    });
    
    context(@"when the path points to an invalid path", ^{
        it(@"raises an error", ^{
            [[theBlock(^{
                [[SQLiteAdapter alloc] initWithPath:@"lol.wut"];
            }) should] raiseWithReason:@"lol.wut is not a sqlite database"];
        });
    });
});

describe(@"executeQuery", ^{
    __block SQLiteAdapter *adapter = [[SQLiteAdapter alloc] initWithPath:@"Specs/Fixtures/users.db"];
    
    context(@"that returns two rows", ^{
        [adapter executeQuery:@"DELETE FROM user"];
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
            
            it(@"returns the an NSDate object for created_at", ^{
                [[[row objectForKey:@"created_at"] should] beKindOfClass:[NSDate class]];
            });
            
            it(@"returns the an NSDate object for birthday", ^{
                [[[row objectForKey:@"birthday"] should] beKindOfClass:[NSDate class]];
            });
        });
    });
    
    afterAll(^{
        [adapter release];
    });
});

SPEC_END