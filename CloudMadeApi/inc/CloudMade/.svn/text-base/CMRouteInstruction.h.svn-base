//
//  RouteInstruction.h
//  NavigationView
//
//  Created by Dmytro Golub on 4/11/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//! Class presents route instructions  
/**
* \note
* YOUR USE OF THIS REAL TIME ROUTE GUIDANCE APPLICATION 
* IS AT YOUR SOLE RISK LOCATION DATA MAY NOT BE ACCURATE.
*/


enum
{
	CMContinueInstruction, 
	CMTurnRightInstruction,
	CMTurnSlightRightInstruction,
	CMTurnSharpRightInstruction,	
	CMTurnLeftInstruction,
	CMTurnSlightLeftInstruction,
	CMTurnSharpLeftInstruction,	
	CMMakeUTurnInstruction,
	CMTakeExit1Instruction,
	CMTakeExit2Instruction,
	CMTakeExit3Instruction,
	CMTakeExit4Instruction,
	CMTakeExit5Instruction,
	CMTakeExit6Instruction,
	CMTakeExit7Instruction,
	CMTakeExit8Instruction,
	CMTakeExit9Instruction,
	CMTakeExit10Instruction,
	CMTakeExit11Instruction,
	CMTakeExit12Instruction
};

typedef NSUInteger CMRouteTurnInstruction;


@interface CMRouteInstruction : NSObject
{
	NSString* instruction; /**< Instruction */
	NSString* distance;    /**< Distance */
	CLLocationCoordinate2D location;
	CMRouteTurnInstruction turnInstruction;
	
}

@property (nonatomic,retain) 	NSString* instruction;
@property (nonatomic,retain) 	NSString* distance;
@property (readwrite)    CLLocationCoordinate2D location;
@property (readwrite)  CMRouteTurnInstruction  turnInstruction;

-(CMRouteTurnInstruction) extractTurnInstruction:(NSDictionary*) instructionInfo;
-(NSString*) imageFileName;
@end
