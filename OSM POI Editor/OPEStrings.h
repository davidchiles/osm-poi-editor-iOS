//
//  OPEStrings.h
//  OSM POI Editor
//
//  Created by David on 4/18/13.
//
//

#import <Foundation/Foundation.h>

@interface OPEStrings : NSObject


#define UPLOADING_STRING NSLocalizedString(@"Uploading",@"Status message infomring user something is being uploaded")
#define SAVING_STRING NSLocalizedString(@"Saving",@"Status message infomring user something is being saved")
#define ERROR_STRING NSLocalizedString(@"Error",@"Status message infomring user there was an error")
#define ZOOM_ERROR_STRING NSLocalizedString(@"Zoom in to load data",@"Status message infomring user they need to zoom in to load data")
#define ZOOM_ALERT_STRING NSLocalizedString(@"You need to zoom in to add a new POI",@"Alert message for user to zoom in on map more to add new POI")
#define OK_STRING NSLocalizedString(@"OK",@"affirmative ok")
#define ZOOM_ALERT_TITLE_STRING NSLocalizedString(@"Zoom Level",@"Title of alert for zoom")
#define FINDING_STRING NSLocalizedString(@"Finding",@"Message to User alerting that the app is parsing or finding the nodes/ways/relations")
#define DOWNLOAD_ERROR_STRING NSLocalizedString(@"Download Error",@"Error shown to user that error downloading existing data")

#define SETTINGS_TITLE_STRING NSLocalizedString(@"Settings",@"title for view where settings can be changed")
#define BING_AERIAL_STRING NSLocalizedString(@"Bing Aerial",@"Setting to select background layer")
#define MAPQUEST_AERIAL_STRING NSLocalizedString(@"OpenMapquest Aerial",@"Setting to select background layer")
#define OSM_DEFAULT_STRING NSLocalizedString(@"OSM Default",@"Setting to select background layer")
#define NO_NAME_HIGHWAY_STRING NSLocalizedString(@"Show No Name Streets",@"Setting to show or hide streets or highways with no names")
#define LOGIN_STRING NSLocalizedString(@"Login to OpenStreetMap",@"Login button label")
#define LOGOUT_STRING NSLocalizedString(@"Logout of OpenStreetMap",@"Logout button label")
#define FEEDBACK_STRING NSLocalizedString(@"Feedback",@"label for feedback button")
#define ABOUT_STRING NSLocalizedString(@"About POI+",@"label for about button")
#define TILE_SOURCE_STRING NSLocalizedString(@"Tile Source",@"Section label for tile source setting")

#define REMOVE_STRING NSLocalizedString(@"Remove",@"Button label to remove tag")
#define CANCEL_STRING NSLocalizedString(@"Cancel",@"Button label to cancel action")
#define DONE_STRING NSLocalizedString(@"Done",@"Button label to done action")
#define DELETE_STRING NSLocalizedString(@"Delete",@"Button label to delete item")
#define DELETE_ALERT_TITLE_STRING NSLocalizedString(@"Delete Point of Interest",@"Title to aler to delete node")
#define DELETE_ALERT_STRING NSLocalizedString(@"Are you Sure you want to delete this node?",@"Message when deleting a node")
#define DELETING_STRING NSLocalizedString(@"Deleting",@"Message to user while deleting node")
#define INFO_TITLE_STRING NSLocalizedString(@"Info",@"Title for detailed view of node")
#define SAVE_STRING NSLocalizedString(@"Save",@"Button label to save any changes")
#define NAME_STRING NSLocalizedString(@"Name",@"Label for name")
#define CATEGORY_STRING NSLocalizedString(@"Category",@"Label for category")
#define TYPE_STRING NSLocalizedString(@"Type",@"Label for type")

#define NO_NAME_STRING NSLocalizedString(@"No Name Street",@"label for street with missing name tag")

#define LOCA_DATA_STRING NSLocalizedString(@"Local Data",@"Button label for signifying using local or downloaded data")
#define MOVE_NODE_STRING NSLocalizedString(@"Move Node",@"Button label and title for view to move location of node/point")

#define COUNTRY_CODE_STRING NSLocalizedString(@"Contry Code",@"Label for country code entry for phone numbers")
#define AREA_CODE_STRING NSLocalizedString(@"Area Code",@"Label for area code entry for phone numbers")
#define LOCAL_NUMBER_STRING NSLocalizedString(@"Local Number",@"label for local number entry for phone numbers")

#define RECENTLY_USED_STRING NSLocalizedString(@"Recently Used",@"Section header for recently used values")
#define CATEGORIES_STRING NSLocalizedString(@"Categories",@"Section header for list of categories")
#define CREATE_NEW_NOTE_STRING NSLocalizedString(@"Create New Note",@"label for creating a new note")
#define NEW_NODE_STRING NSLocalizedString(@"New Node",@"Title for view for creating a new node")

#define SUNSET_STRING NSLocalizedString(@"Sunset",@"The time of day with the sun goes away")
#define SUNRISE_STRING NSLocalizedString(@"Sunrise",@"The time of day when the sun comes back")

#define ADD_RULE_STRING NSLocalizedString(@"Add Rule",@"Label for button to add opening_hours rule")
#define RULE_STRING NSLocalizedString(@"Rule",@"Title for view where opening_hours rules are edited, singular")
#define RULES_STRING NSLocalizedString(@"Rules",@"Title for view where opening_hours rules are edited, plural")
#define OPEN_TWENTY_FOUR_SEVEN_STRING NSLocalizedString(@"Open 24/7","Label for switch denoting if open 24/7 or all the time")
#define OPEN_STRING NSLocalizedString(@"Open",@"label denoting a business is open")
#define CLOSED_STRING NSLocalizedString(@"Closed",@"label denoting a business is closed")
#define MONTHS_STRING NSLocalizedString(@"Months",@"There's twelve of them and the first one is January")
#define ALL_MONTHS_STRING NSLocalizedString(@"All Months",@"There's twelve of them and the first one is January")

#define DAYS_OF_WEEK_STRING NSLocalizedString(@"Days of the Week",@"There's seven of them and the first one is Sunday or is it monday?")
#define ALL_DAYS_STRING NSLocalizedString(@"All Days",@"Label")

#define TIME_RANGES_STRING NSLocalizedString(@"Time Ranges",@"label for time ranges in opening_hours")
#define TIMES_STRING NSLocalizedString(@"Times",@"label for times in opening_hours")

#define ADD_TIME_RANGE_STRING NSLocalizedString(@"Add Time Range",@"Button to add new time range for opening_hours")
#define ADD_TIME_STIRNG NSLocalizedString(@"Add Time",@"Button to add new time for opening_hours")

#define START_TIME_STRING NSLocalizedString(@"Start Time",@"Title for time when a shop opens")
#define END_TIME_STIRNG NSLocalizedString(@"End Time",@"Title for when a shop closes")

#define TIME_STRING NSLocalizedString(@"Time",@"Time like on a watch")

#define TO_STRING NSLocalizedString(@"to",@"as in from 10 *to* 12 we'll be open")




@end
