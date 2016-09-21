//
//  GameScene.m
//  SeaBattle
//
//  Created by Maxim Bublowskiy on 2016-09-21.
//  Copyright © 2016 Maxim Bublovskiy. All rights reserved.
//

#import "GameScene.h"
#import <math.h>
#import "Geometry_Calculations.h"


@implementation GameScene


SKColor* _mainScreenColor;
SKSpriteNode* cannonSpriteNode;

//Scales
double cannonScale = 0.5;
double cannonPositionShift;

CGFloat angelOfCannon;


//Bit Mask Category
static const double degreesInOneRad = 57.2958;
static const int ship = 1 << 0;
static const int shell = 1 << 1;

//pivoting point for the canno
CGPoint cannonPivotPoint;



- (void)didMoveToView:(SKView *)view {
    
    //set main screen color
    
    _mainScreenColor = [SKColor colorWithRed:0.2 green:0.8 blue:1 alpha:1];
    [self setBackgroundColor:_mainScreenColor];
    
    //set the Cannon
    
    SKTexture* cannonTexture = [SKTexture textureWithImageNamed:@"cannon"];
    cannonSpriteNode = [SKSpriteNode spriteNodeWithTexture:cannonTexture];
    [cannonSpriteNode setScale: cannonScale];
    
    //create a pivot point for the cannon on the screen
    cannonPivotPoint.x = CGRectGetMidX(self.frame);
    cannonPositionShift = cannonSpriteNode.size.height/3;
    cannonPivotPoint.y = CGRectGetMinY(self.frame) + cannonPositionShift;
    
    cannonSpriteNode.position = cannonPivotPoint;
    [self addChild:cannonSpriteNode];
    
 }


- (void)touchDownAtPoint:(CGPoint)pos {
 
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
    //slope for the line of touch
    //original cannonPivotPoint.y seats above the screen baseline by 1/3 of the ship's size
    double slope = (pos.y - (cannonPivotPoint.y-cannonPositionShift))/(pos.x - cannonPivotPoint.x);
    
    //calculete and angle of inclination in Rad
    angelOfCannon = atan(slope) < 0 ? 90/degreesInOneRad - fabs(atan(slope)) : -(90/degreesInOneRad - fabs(atan(slope)));
    
    //turn the cannon
    SKAction* cannotTurningAction = [SKAction rotateToAngle:angelOfCannon duration:0.1];
    
    [cannonSpriteNode runAction:cannotTurningAction];
}

- (void)touchUpAtPoint:(CGPoint)pos {
    
    CGPoint pointOfrecoil = [Geometry_Calculations findCrossPointLine1Point1:pos nLine1Point2:cannonPivotPoint nLine2Point2:CGPointMake(CGRectGetMinX(self.frame), cannonPivotPoint.y-cannonPositionShift) nLine2Point2:CGPointMake(cannonPivotPoint.x, cannonPivotPoint.y-cannonPositionShift)];
    
    //CGPoint pointOfrecoil;
//    
//    double A1,B1,C1;
//    double A2,B2,C2;
    
    /**
    
    A = lineEndsY-lineStartY;
    B = lineStartX-lineEndsX;
    C=A*lineStartX+B*lineStartY;
    
    crossX = (B2*C1-B1*C2)/(B2*A1-B1*A2);
    crossY = (A1*C2-A2*C1)/(A1*B2-A2*B1);
    
    **/
    
//    A1 = pos.y-cannonPivotPoint.y;
//    B1 = cannonPivotPoint.x-pos.x;
//    C1=A1*cannonPivotPoint.x+B1*cannonPivotPoint.y;
//    
//    A2 = (cannonPivotPoint.y-cannonPositionShift) - (cannonPivotPoint.y-cannonPositionShift);
//    B2 = CGRectGetMinX(self.frame)-cannonPivotPoint.x;
//    C2 = A2*CGRectGetMinX(self.frame)+B2*(cannonPivotPoint.y-cannonPositionShift);
//    
//    //ger point of intersection
//    pointOfrecoil.x = (B2*C1-B1*C2)/(B2*A1-B1*A2);
//    pointOfrecoil.y = (A1*C2-A2*C1)/(A1*B2-A2*B1);
    
    //NSLog(@"\nx: %f   y: %f\n    width: %f", pointOfrecoil.x, pointOfrecoil.y, self.frame.size.width);
    SKAction* recoliCannon = [SKAction moveTo:pointOfrecoil duration:0.3];
    SKAction* moveCannonBackInPlace = [SKAction moveTo:CGPointMake(cannonPivotPoint.x, cannonPivotPoint.y) duration:0.3];

    [cannonSpriteNode runAction:[SKAction sequence:@[recoliCannon,moveCannonBackInPlace]]];
                                 

}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
     for (UITouch *t in touches) {[self touchDownAtPoint:[t locationInNode:self]];}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
     for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
     for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}


- (void)didBeginContact:(SKPhysicsContact *)contact {}

- (void)didEndContact:(SKPhysicsContact *)contact {}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
