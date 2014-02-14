//
//  OPELog.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/14.
//
//

#import "DDLog.h"
#if DEBUG
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;
    static const BOOL OPELogDatabaseErrors = YES;
    static const BOOL OPETraceDatabaseTraceExecution = YES;
#else
    static const int ddLogLevel = LOG_LEVEL_OFF;
    static const BOOL OPELogDatabaseErrors = NO;
    static const BOOL OPETraceDatabaseTraceExecution = NO;
#endif
