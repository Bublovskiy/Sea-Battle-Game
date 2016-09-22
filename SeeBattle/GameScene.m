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
SKSpriteNode* _cannonSpriteNode;

double _cannonScale = 0.5;
double _cannonPositionShift;

CGFloat _angelOfCannon;
CGFloat _minYToReact;

//Bit Mask Category
static const double _degreesInOneRad = 57.2958;
static const int _ship = 1 << 0;
static const int _shell = 1 << 1;

//pivoting point for the cannon
CGPoint _cannonPivotPoint;


- (void)didMoveToView:(SKView *)view {
    
    //set main screen color
    
    _mainScreenColor = [SKColor colorWithRed:0.2 green:0.8 blue:1 alpha:1];
    [self setBackgroundColor:_mainScreenColor];
    
    //set the Cannon
    
    SKTexture* _cannonTexture = [SKTexture textureWithImageNamed:@"cannon"];
    _cannonSpriteNode = [SKSpriteNode spriteNodeWithTexture:_cannonTexture];
    [_cannonSpriteNode setScale: _cannonScale];
    
    //create a pivot point for the cannon on the screen
    _cannonPivotPoint.x = CGRectGetMidX(self.frame);
    _cannonPositionShift = _cannonSpriteNode.size.height/3;
    _cannonPivotPoint.y = CGRectGetMinY(self.frame) + _cannonPositionShift;
    _minYToReact = _cannonPivotPoint.y + _cannonSpriteNode.size.height;
    
    _cannonSpriteNode.position = _cannonPivotPoint;
    [self addChild:_cannonSpriteNode];
    
 }


- (void)touchDownAtPoint:(CGPoint)pos {
 
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
    if (pos.y>=_minYToReact) {
    //slope for the line of touch
    //original cannonPivotPoint.y seats above the screen baseline by 1/3 of the ship's size
    double _slope = (pos.y - (_cannonPivotPoint.y-_cannonPositionShift))/(pos.x - _cannonPivotPoint.x);
    
    //calculete and angle of inclination in Rad
    _angelOfCannon = atan(_slope) < 0 ? 90/_degreesInOneRad - fabs(atan(_slope)) : -(90/_degreesInOneRad - fabs(atan(_slope)));
    
    //turn the cannon
    SKAction* cannotTurningAction = [SKAction rotateToAngle:_angelOfCannon duration:0.1];
    
    [_cannonSpriteNode runAction:cannotTurningAction];
    
    }
}

- (void)touchUpAtPoint:(CGPoint)pos {
    
    if (pos.y>=_minYToReact) {
    
        //recoil effect
    
    CGPoint pointOfrecoil = [Geometry_Calculations findCrossPointLine1Point1:pos nLine1Point2:_cannonPivotPoint nLine2Point2:CGPointMake(CGRectGetMinX(self.frame), _cannonPivotPoint.y-_cannonPositionShift) nLine2Point2:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y-_cannonPositionShift)];
    
    SKAction* recoliCannon = [SKAction moveTo:pointOfrecoil duration:0.3];
    SKAction* moveCannonBackInPlace = [SKAction moveTo:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y) duration:0.3];

    [_cannonSpriteNode runAction:[SKAction sequence:@[recoliCannon,moveCannonBackInPlace]]];
    
    }
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
