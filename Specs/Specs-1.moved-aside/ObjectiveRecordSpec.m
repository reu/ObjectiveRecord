#import "Kiwi.h"
#import "ObjectiveRecord.h"

/*@interface DummyClass : ObjectiveRecord {
    NSNumber *primaryKey;
    NSString *name;
}

@property (nonatomic, retain) NSNumber *primaryKey;
@property (nonatomic, retain) NSString *name;

@end

@implementation DummyClass

@synthesize primaryKey, name;

@end*/



SPEC_BEGIN(ObjectiveRecordSpec)

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
                [[[row objectForKey:@"age"] should] equal:[NSNumber numberWithInt:26]];
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

SPEC_END