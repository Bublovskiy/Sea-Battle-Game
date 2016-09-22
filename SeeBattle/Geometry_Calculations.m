//
//  Geometry_Calculations.m
//  SeaBattle
//
//  Created by Maxim Bublowskiy on 2016-09-21.
//  Copyright © 2016 Maxim Bublovskiy. All rights reserved.
//

#import "Geometry_Calculations.h"

@implementation Geometry_Calculations


+ (CGPoint) findCrossPointLine1Point1:(CGPoint) line1point1 nLine1Point2:(CGPoint) line1point2 nLine2Point1:(CGPoint) line2point1 nLine2Point2:(CGPoint) line2point2 {

    CGPoint crossPoint;
    
    double _A1,_B1,_C1;
    double _A2,_B2,_C2;
    
    /**
     
     A = lineEndsY-lineStartY;
     B = lineStartX-lineEndsX;
     C=A*lineStartX+B*lineStartY;
     
     crossX = (B2*C1-B1*C2)/(B2*A1-B1*A2);
     crossY = (A1*C2-A2*C1)/(A1*B2-A2*B1);
     
     **/
    
    _A1 = line1point2.y-line1point1.y;
    _B1 = line1point1.x-line1point2.x;
    _C1=_A1*line1point1.x+_B1*line1point1.y;
    
    _A2 = line2point2.y-line2point1.y;
    _B2 = line2point1.x-line2point2.x;
    _C2=_A2*line2point1.x+_B2*line2point1.y;

    
    //ger point of intersection
    crossPoint.x = (_B2*_C1-_B1*_C2)/(_B2*_A1-_B1*_A2);
    crossPoint.y = (_A1*_C2-_A2*_C1)/(_A1*_B2-_A2*_B1);
    
    return crossPoint;
}


+ (CGFloat)  findAngelToRotateCannonForPointOfTouch: (CGPoint)point andCannonPosition:(CGPoint)cannonPivotPoint withCannonShift:(double)cannonPositionShift {

    //slope for the line of touch
    //original cannonPivotPoint.y seats above the screen baseline by 1/3 of the ship's size
    double _slope = (point.y - (cannonPivotPoint.y- cannonPositionShift))/(point.x - cannonPivotPoint.x);
    
    //calculete and angle of inclination in Rad
    //1 Rad = 57.2958 degrees
    return atan(_slope) < 0 ? 90/57.2958 - fabs(atan(_slope)) : -(90/57.2958 - fabs(atan(_slope)));

}


@end
