//
//  SQLiteAdapter.h
//  ObjectiveRecord
//
//  Created by Rodrigo Navarro on 7/4/11.
//  Copyright 2011 Manapot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteAdapter : NSObject {
    sqlite3 *database;
}

- (id)initWithPath:(NSString *)path;
- (id)connection;

@end
