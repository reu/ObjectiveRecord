//
//  ObjectiveRecord.h
//  ObjectiveRecord
//
//  Created by Guilherme da Silva Mello on 7/7/11.
//  Copyright 2011 Guimello Tecnologia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteAdapter.h"

@interface ObjectiveRecord : NSObject {
    
}

+ (NSMutableArray *)findBySQL:(NSString *)sql;
+ (id)new:(NSDictionary *)values;
+ (id)connection;


@end
