//
//  Settings.h
//  SeaBattle
//
//  Created by Maxim Bublowskiy on 2016-09-22.
//  Copyright © 2016 Maxim Bublovskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

#define CANNON_SCALE ((CGFloat)0.8)
#define SHELL_SCALE ((CGFloat)1.5)
#define SHIP_SCALE ((CGFloat)1.5)
#define BOOM_SCALE ((CGFloat)2)
#define SCORE_SCALE ((CGFloat)2)
#define GAME_OVER_MESSAGE_SCALE ((CGFloat)3)

#define SHIP_SPEED ((NSTimeInterval)15)
#define SHELL_SPEED ((NSTimeInterval)8)
#define CANNON_RECOIL_SPEED ((NSTimeInterval)0.3)
#define BOOM_SCALING_SPEED ((NSTimeInterval)0.5 )
#define SHIP_AAPEARANCE_DELEY ((NSTimeInterval)7)
#define CANNON_TURNING_SPEED ((NSTimeInterval)0.1)
#define SCORE_TEXT_UPDATE_SPEED ((NSTimeInterval)0.5)

#define CANNON_RELOAD_TIME ((unsigned int)3)
#define LOOSE_SHIPS_LIMIT ((unsigned int)   3)

#define GAME_OVER_MESSAGE ((NSString*)@"Game Over!")



