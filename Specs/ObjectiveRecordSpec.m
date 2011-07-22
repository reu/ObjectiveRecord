//
//  ObjectiveRecordSpec.m
//  ObjectiveRecord
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

describe(@"initWithAttributes", ^{
    __block NSMutableDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"id", @"Keyra Agustina", @"name", nil];
    
    it(@"allows initialize the record with a dictionary", ^{
        [[theBlock(^{
            [[User alloc] initWithAttributes:attributes];
        }) shouldNot] raise];
    });
    
    it(@"should ignore attributes in the dictionary that doesn't match any of the object properties", ^{
        NSMutableDictionary *invalidAttributes = [NSDictionary dictionaryWithObjectsAndKeys:@"Nyan", @"invalidAttribute", nil];
        
        [[theBlock(^{
            [[User alloc] initWithAttributes:invalidAttributes];
        }) shouldNot] raise];
    });
    
    describe(@"attributes setting", ^{
        __block User *user = [[User alloc] initWithAttributes:attributes];
        
        it(@"should set the name property", ^{
            [[[user name] should] equal:@"Keyra Agustina"];
        });
        
        it(@"automatically sets the primaryKey attribute in case the the dictionary has key named id", ^{
            [[[user primaryKey] should] equal:[NSNumber numberWithInt:1]];
        });
    });
});

describe(@"recordWithAttributes", ^{
    __block NSMutableDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"id", @"Keyra Agustina", @"name", nil];
    
    it(@"allows initialize the record with a dictionary", ^{
        [[theBlock(^{
            [User recordWithAttributes:attributes];
        }) shouldNot] raise];
    });
    
    it(@"returns an autorelease object", ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        User *user = [User recordWithAttributes:attributes];
        [[user should] receive:@selector(release)];
        
        [pool release];
    });
});

describe(@"isNewRecord", ^{
    it(@"is false when the object is persisted in the database", ^{
        User *user = [User new];
        user.name = @"Rodrigo";
        [user save];
        
        [[theValue([user isNewRecord]) should] beFalse];
    });
    
    it(@"is true when the object is not persisted in the database", ^{
        User *user = [User new];
        user.name = @"Guilherme";
        
        [[theValue([user isNewRecord]) should] beTrue];
    });
});

describe(@"save", ^{
    context(@"when the record doesn't exist in the database", ^{
        it(@"creates it", ^{
            User *user = [User new];
            user.name = @"Nemo";
            [user save];
            
            [[[User findWithSQL:@"SELECT * FROM user where name = 'Nemo'"] should] haveCountOf:1];
        });
        
        it(@"returns true if it is successfully saved", ^{
            User *user = [User new];
            [[theValue([user save]) should] beTrue];
        });
        
        it(@"returns false if it is not successfully saved", ^{
            User *user = [User new];
            [User stub:@selector(tableName) andReturn:@"invalid table name"];
            
            [[theValue([user save]) should] beFalse];
        });
        
        it(@"sets the primary key of the recentyle created record", ^{
            User *user = [User new];
            user.name = @"Anakin";
            [user save];
            
            [[user primaryKey] shouldNotBeNil];
        });
    });
    
    context(@"when the record already exist in the database", ^{
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Keira')"];
        
        it(@"updates it", ^{
            User *user = [[User findWithSQL:@"SELECT * FROM user"] lastObject];
            user.name = @"Keyra";
            [user save];
            
            [[[User findWithSQL:@"SELECT * FROM user where name = 'Keyra'"] should] haveCountOf:1];
            [[[User findWithSQL:@"SELECT * FROM user where name = 'Keira'"] should] haveCountOf:0];
        });
        
        it(@"returns true if it is successfully saved", ^{
            User *user = [[User findWithSQL:@"SELECT * FROM user"] lastObject];
            user.name = @"Keyra";
            
            [[theValue([user save]) should] beTrue];
        });
        
        it(@"returns false if it is not successfully saved", ^{
            User *user = [[User findWithSQL:@"SELECT * FROM user"] lastObject];
            [User stub:@selector(tableName) andReturn:@"invalid table name"];
            
            [[theValue([user save]) should] beFalse];
        });
    });
    
    describe(@"callbacks", ^{
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Rodrigo')"];
        
        __block User *savedUser;
        __block User *unsavedUser;
        
        beforeEach(^{
            savedUser = [[User findWithSQL:@"SELECT * FROM USER WHERE name = 'Rodrigo'"] lastObject];
            unsavedUser = [User new];
        });
        
        context(@"before save", ^{
            it(@"is triggered before saving a saved record", ^{
                [[savedUser should] receive:@selector(beforeSave)];
                [savedUser save];
            });
            
            it(@"is triggered before saving a unsaved record", ^{
                [[unsavedUser should] receive:@selector(beforeSave)];
                [unsavedUser save];
            });
        });
        
        context(@"after save", ^{
            it(@"is triggered after saving a saved record", ^{
                [[savedUser should] receive:@selector(afterSave)];
                [savedUser save];
            });
            
            it(@"is triggered after saving a unsaved record", ^{
                [[unsavedUser should] receive:@selector(afterSave)];
                [unsavedUser save];
            });
        });
        
        context(@"before create", ^{
            it(@"is triggered after saving a unsaved record", ^{
                [[unsavedUser should] receive:@selector(beforeCreate)];
                [unsavedUser save];
            });
            
            it(@"is not triggered after saving a saved record", ^{
                [[savedUser shouldNot] receive:@selector(beforeCreate)];
                [savedUser save];
            });
        });
        
        context(@"after create", ^{
            it(@"is triggered after saving a unsaved record", ^{
                [[unsavedUser should] receive:@selector(afterCreate)];
                [unsavedUser save];
            });
            
            it(@"is not triggered after saving a saved record", ^{
                [[savedUser shouldNot] receive:@selector(afterCreate)];
                [savedUser save];
            });
        });
        
        context(@"before update", ^{
            it(@"is triggered after saving a saved record", ^{
                [[savedUser should] receive:@selector(beforeUpdate)];
                [savedUser save];
            });
            
            it(@"is not triggered after saving a unsaved record", ^{
                [[unsavedUser shouldNot] receive:@selector(beforeUpdate)];
                [unsavedUser save];
            });
        });
        
        context(@"after update", ^{
            it(@"is triggered after saving a saved record", ^{
                [[savedUser should] receive:@selector(afterUpdate)];
                [savedUser save];
            });
            
            it(@"is not triggered after saving a unsaved record", ^{
                [[unsavedUser shouldNot] receive:@selector(afterUpdate)];
                [unsavedUser save];
            });            
        });
    });
});

describe(@"destroy", ^{
    __block User *user;
    
    context(@"when the record exists on the database", ^{
        beforeEach(^{
            user = [User new];
            [user save];
        });
        
        it(@"destroys it", ^{
            [user destroy];
            [[[User findAllWithConditions:[NSString stringWithFormat:@"id = '%@'", [user primaryKey]]] should] haveCountOf:0];
        });
        
        it(@"return true the record is successfully destroyed", ^{
            [[theValue([user destroy]) should] beTrue];
        });
        
        it(@"return true the record is not successfully destroyed", ^{
            [User stub:@selector(tableName) andReturn:@"invalid table name"];
            [[theValue([user destroy]) should] beFalse];
        });
    });
});

describe(@"searching for records", ^{
    describe(@"find", ^{
        beforeEach(^{
            [[User connection] executeQuery:@"INSERT INTO user (id, name) VALUES (10, 'Rodrigo')"];
            [[User connection] executeQuery:@"INSERT INTO user (id, name) VALUES (24, 'Guilherme')"];
        });
        
        it(@"finds a record by its id", ^{
            [[[[User find:24] name] should] equal:@"Guilherme"];
        });
        
        it(@"returns nil if no record is found", ^{
            [[User find:30] shouldBeNil];
        });
        
        afterAll(^{
            [[User connection] executeQuery:@"DELETE FROM user"];
        });
    });
    
    describe(@"findWithSQL", ^{
        [[User connection] executeQuery:@"DELETE FROM user"];
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Rodrigo')"];
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Marília')"];
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Keyboard cat')"];
        [[User connection] executeQuery:@"INSERT INTO user (name) VALUES ('Guitar cat')"];
        
        context(@"searching for Rodrigo", ^{
            __block NSArray *users = [User findWithSQL:@"SELECT * FROM user where name = 'Rodrigo'"];
            
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

    describe(@"findAll", ^{
        context(@"searching for all records", ^{
            __block NSArray *users = [User findAll];

            it(@"successfully finds all users", ^{
                [[users should] haveCountOf:4];
            });
        });
    });

    context(@"searching for the cats", ^{
        describe(@"findAllWithConditions", ^{
            __block NSArray *users = [User findAllWithConditions:@"name LIKE '%cat%'"];

            it(@"successfully finds the cats", ^{
                [[users should] haveCountOf:2];
            });
        });

        describe(@"findAllWithConditionsAndParameters", ^{
            __block NSArray *users = [User findAllWithConditions:@"name LIKE ?" andParameters:[NSArray arrayWithObject:@"%cat%"]];

            it(@"successfully finds the cats", ^{
                [[users should] haveCountOf:2];
            });
        });
    });
});

describe(@"tableName", ^{
    it(@"is the lowercase class name", ^{
        [[[User tableName] should] equal:@"user"];
    });
});

describe(@"primaryKeyColumnName", ^{
    it(@"is the id column by default", ^{
        [[[User primaryKeyColumnName] should] equal:@"id"];
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