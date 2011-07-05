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

SPEC_END