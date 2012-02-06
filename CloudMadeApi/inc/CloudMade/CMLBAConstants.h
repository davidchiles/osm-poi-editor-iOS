/*
 *  CMLBAConstants.h
 *  LBAApp
 *
 *  Created by pigeon on 2/5/10.
 *  Copyright 2010 CloudMade. All rights reserved.
 *
 */

#ifndef __CMLBACONSTANTS_H__
#define __CMLBACONSTANTS_H__

/** \file CMLBAConstants.h 
   \brief A file with constants 
*/

typedef enum _CMAdType
	{
		CMBannerAd,
		CMSpoiAd
	} CMAdType;


//! Specifies the size of the advertising banner. 
typedef enum _CMAdsSize
	{
		ADSize_125x125 = 1,  /*!< default alighment CMAdsAlighmentTop */
		ADSize_300x250 = 2,  /*!< default alighment CMAdsAlighmentCenter */
		ADSize_300x50  = 4,   /*!< default alighment CMAdsAlighmentTop */
		ADSize_300x75  = 8,   /*!< default alighment CMAdsAlighmentTop */
		ADSize_216x36  = 16,   /*!< default alighment CMAdsAlighmentTop */
		ADSize_216x54  = 32,   /*!< default alighment CMAdsAlighmentTop */
		ADSize_168x28  = 64,   /*!< default alighment CMAdsAlighmentTop */		
		ADSize_320x50  = 128,   /*!< default alighment CMAdsAlighmentTop */	
		ADSize_120x20  = 256,     /*!< default alighment CMAdsAlighmentTop */	
		ADSize_MaxValue = ADSize_120x20
	} CMAdsSize;

//! Specifies the alighment of the advertising banner.
typedef enum _CMAdsAlighment
	{
		CMAdsAlighmentTop,    /**< Centers the banner on the top of the view */
		CMAdsAlighmentBottom, /**< Centers the banner on the bottom of the view */
		CMAdsAlighmentCenter, /**< Centers the banner in the center of the view */
		CMAdsAlighmentLeft,   
		CMAdsAlighmentRight,  
		CMAdsAlighmentDefault /**< default value \sa CMAdsSize */
	} CMAdsAlighment;

//! Specifies the bahavior of the advertising banner.
typedef enum _CMAdsBehavior
	{
		CMAdsDissapearsIn10, /**< A banner disappears in 10 sec */
		CMAdsDissapearsIn30, /**< A banner disappears in 30 sec */
		CMAdsStatic,         /**< A banner won't disappears  */
		CMAdsDefaultBehavior 
	} CMAdsBehavior;

#endif //__CMLBACONSTANTS_H__