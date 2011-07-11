//
//  ObjectiveRecordSpec.m
//  ObjectiveRecord
//
//  Created by Guilherme da Silva Mello on 7/8/11.
//  Copyright 2011 Guimello Tecnologia. All rights reserved.
//

#import "Kiwi.h"
#import "ObjectiveRecord.h"

@interface User : ObjectiveRecord {
    NSString *name;
}

@property (nonatomic, retain) NSString *name;

@end

@implementation User

@synthesize name;

@end


SPEC_BEGIN(ObjectiveRecordSpec)

[[User connection] executeQuery:@"CREATE TABLE user (id INTEGER PRIMARY KEY, name VARCHAR(255))"];

describe(@"new", ^{
    __block NSMutableDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"id", @"Keyra Agustina", @"name", nil];
    
    describe(@"allows initialize the record with a dictionary", ^{
        [[theBlock(^{
            [User new:attributes];
        }) shouldNot] raise];
    });
    
    describe(@"attributes setting", ^{
        __block User *user = [User new:attributes];
        
        it(@"should set the name property", ^{
            [[[user name] should] equal:@"Keyra Agustina"];
        });
        
        it(@"automatically sets the primaryKey attribute in case a key named id is passed in the dictionary", ^{
            [[[user primaryKey] should] equal:[NSNumber numberWithInt:1]];
        });
    });
});

describe(@"findBySQL", ^{
    [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Rodrigo')"];
    [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Marília')"];
    
    context(@"searching for Rodrigo", ^{
        __block NSArray *users = [User findBySQL:@"SELECT * FROM user where name = 'Rodrigo'"];
        
        it(@"successfully finds one record", ^{
            [[users should] haveCountOf:1];
        });
        
        context(@"user Rodrigo's attributes", ^{
            __block User *user = [users lastObject];
            
            it(@"has a name", ^{
                [[[user name] should] equal:@"Rodrigo"];
            });
            
            it(@"has a primary key", ^{
                [[[user primaryKey] should] equal:[NSNumber numberWithInt:1]];
            });
        });
    });
});

describe(@"tableName", ^{
    it(@"is the lowercase class name", ^{
        [[[User tableName] should] equal:@"user"];
    });
});

describe(@"columnNames", ^{
    it(@"contains two columns", ^{
        [[[User columnNames] should] haveCountOf:2];
    });
    
    it(@"contains a name column", ^{
        [[[User columnNames] should] contain:@"name"];
    });
});

SPEC_END
