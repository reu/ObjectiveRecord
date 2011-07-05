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
            }) should] raise];
        });
    });
});

describe(@"executeQuery", ^{
    __block SQLiteAdapter *adapter = [[SQLiteAdapter alloc] initWithPath:@"Specs/Fixtures/test.db"];
    
    context(@"that returns two rows", ^{
        beforeAll(^{
            [adapter executeQuery:@"DELETE FROM user"];
            [adapter executeQuery:@"INSERT INTO user (name, age) VALUES ('Rodrigo', 25)"];
            [adapter executeQuery:@"INSERT INTO user (name, age) VALUES ('Marília', 28)"];
        });
        
        it(@"returns an array with two dictionaries", ^{
            NSArray *rows = [adapter executeQuery:@"SELECT name, age FROM user"];
            
            [[rows should] haveCountOf:2];
            [[[rows objectAtIndex:0] should] beKindOfClass:[NSDictionary class]];
        });
        
        describe(@"the first row", ^{
            __block NSArray *rows = [adapter executeQuery:@"SELECT * FROM user"];
            __block NSDictionary *row = [rows objectAtIndex:0];
            
            it(@"returns Rodrigo as its name", ^{
                [[[row objectForKey:@"name"] should] equal:@"Rodrigo"];
            });
            
            it(@"returns 25 as its age", ^{
                [[[row objectForKey:@"age"] should] equal:[NSNumber numberWithInt:25]];
            });
        });
    });
    
    afterAll(^{
        [adapter executeQuery:@"DELETE FROM user"];
        [adapter release];
    });
});

SPEC_END