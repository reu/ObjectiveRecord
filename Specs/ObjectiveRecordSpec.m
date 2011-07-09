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
    NSNumber *primaryKey;
    NSString *name;
}
 
 @property (nonatomic, retain) NSNumber *primaryKey;
 @property (nonatomic, retain) NSString *name;
 
 @end
 
 @implementation User
 
 @synthesize primaryKey, name;
 
 @end




SPEC_BEGIN(ObjectiveRecordSpec)

describe(@"findBySQL", ^{
    beforeAll(^{
        [[User connection] executeQuery:@"CREATE TABLE user (id INTEGER PRIMARY KEY, name VARCHAR(255))"];
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Rodrigo')"];
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Marília')"];
    });
    
    context(@"searching for Rodrigo", ^{
        
        beforeAll(^{
            // Learn how to use tis pointer over the it iterations
            //NSArray *users = [User findBySQL:@"SELECT * FROM user where name = 'Rodrigo'"];
        });
        
        it(@"successfully finds one record", ^{
            [[[User findBySQL:@"SELECT * FROM user where name = 'Rodrigo'"] should] haveCountOf:1];
        });
        
        context(@"user Rodrigo's attributes", ^{
            it(@"has a name", ^{
                User *user = [[User findBySQL:@"SELECT * FROM user where name = 'Rodrigo'"] lastObject];
                
                [[[user name] should] equal:@"Rodrigo"];
            });
        });
    });
});

SPEC_END
