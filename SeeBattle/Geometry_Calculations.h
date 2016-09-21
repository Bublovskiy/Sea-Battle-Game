//
//  Geometry_Calculations.h
//  SeaBattle
//
//  Created by Maxim Bublowskiy on 2016-09-21.
//  Copyright © 2016 Maxim Bublovskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Geometry_Calculations : NSObject

+ (CGPoint) findCrossPointLine1Point1:(CGPoint) line1point1 nLine1Point2:(CGPoint) line1point2 nLine2Point2:(CGPoint) line2point1 nLine2Point2:(CGPoint) line2point2;

@end
