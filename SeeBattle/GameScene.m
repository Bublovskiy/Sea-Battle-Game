//
//  GameScene.m
//  SeaBattle
//
//  Created by Maxim Bublowskiy on 2016-09-21.
//  Copyright © 2016 Maxim Bublovskiy. All rights reserved.
//

#import "GameScene.h"
#import "Geometry_Calculations.h"



@implementation GameScene

//Bit Mask Category
static const int _ship = 1 << 0;
static const int _shell = 1 << 1;
//static const int _midLine = 1 << 2;

SKColor* _mainScreenColor;
SKSpriteNode* _cannonSpriteNode;
SKNode* _midLineNode;

SKTexture* _shellTexture;
SKTexture* _shipTexture;
SKTexture* _boomTexture;

CGFloat _cannonScale = 0.8;
CGFloat _shellScale = 1.5;
CGFloat _shipScale = 1.5;
CGFloat _boomScale = 2;

CGFloat _cannonPositionShift;
CGFloat _angelOfCannon;
CGFloat _minYToReact;

//pivoting point for the cannon
CGPoint _cannonPivotPoint;
CGPoint _contactPoint;

//time intervals
NSTimeInterval _shipSpeed = 15;
NSTimeInterval _shellSpeed = 8;
NSTimeInterval _cannonRecoilSpeed = 0.3;
NSTimeInterval _boomScaleSpeed = 0.5;
NSTimeInterval _shipAppearanceDeley = 7;
NSTimeInterval _cannonTurningSpeed = 0.1;

unsigned int _currentTime = 0;
unsigned int _cannonReloadTime = 3;



- (void)didMoveToView:(SKView *)view {
    
    //set main screen color
    self.physicsWorld.contactDelegate = self;
    
    _mainScreenColor = [SKColor colorWithRed:0.2 green:0.8 blue:1 alpha:1];
    [self setBackgroundColor:_mainScreenColor];
    
//    //set mid line node
//    _midLineNode  = [SKNode node];
//    _midLineNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, 10)];
//    _midLineNode.physicsBody.affectedByGravity = NO;
//    _midLineNode.physicsBody.categoryBitMask = _midLine;
//    _midLineNode.physicsBody.contactTestBitMask = _shell;
    
    //set the Cannon
    
    SKTexture* _cannonTexture = [SKTexture textureWithImageNamed:@"Cannon"];
    
    _cannonSpriteNode = [SKSpriteNode spriteNodeWithTexture:_cannonTexture];
    _cannonSpriteNode.zPosition = 100;
    [_cannonSpriteNode setScale: _cannonScale];
    
    //create a pivot point for the cannon on the screen
    _cannonPivotPoint.x = CGRectGetMidX(self.frame);
    _cannonPositionShift = _cannonSpriteNode.size.height/3;
    _cannonPivotPoint.y = CGRectGetMinY(self.frame) + _cannonPositionShift;
    _minYToReact = _cannonPivotPoint.y + _cannonSpriteNode.size.height;
    
    _cannonSpriteNode.position = _cannonPivotPoint;
    [self addChild:_cannonSpriteNode];
    
    //set a shell
    
     _shellTexture = [SKTexture textureWithImageNamed:@"Shell"];
    
    //set ships
    
    _shipTexture = [SKTexture textureWithImageNamed:@"Ship1"];
    SKAction* _generateShip = [SKAction performSelector:@selector(spawnShip) onTarget:self];
    SKAction* _shipdelay = [SKAction waitForDuration:_shipAppearanceDeley];
    SKAction* _shipSequebce = [SKAction sequence:@[_generateShip,_shipdelay]];
    SKAction* _generateShipsForever = [SKAction repeatActionForever:_shipSequebce];
    [self runAction:_generateShipsForever];
    
    //set boom
    _boomTexture = [SKTexture textureWithImageNamed:@"Boom"];
    
 }


- (void)touchDownAtPoint:(CGPoint)pos {
 
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
    if (pos.y>=_minYToReact) {
        
    _angelOfCannon = [Geometry_Calculations findAngelToRotateCannonForPointOfTouch:pos andCannonPosition:_cannonPivotPoint withCannonShift:_cannonPositionShift];
        
    //turn the cannon
    SKAction* cannotTurningAction = [SKAction rotateToAngle:_angelOfCannon duration:_cannonTurningSpeed];

    [_cannonSpriteNode runAction:cannotTurningAction];
    
    }
}

- (void)touchUpAtPoint:(CGPoint)pos {
    
    if ((pos.y>=_minYToReact)&&((time(NULL) - _currentTime)>=_cannonReloadTime)) {
    
    _currentTime = (unsigned int)time(NULL);
    
    //fire a shell
    CGPoint _pointBeyondScreen = [Geometry_Calculations
                                        findCrossPointLine1Point1: _cannonPivotPoint
                                        nLine1Point2: pos
                                        nLine2Point1: CGPointMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame))nLine2Point2: CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame))];
        
    SKSpriteNode* _shellSpriteNode = [SKSpriteNode spriteNodeWithTexture:_shellTexture];
    [_shellSpriteNode setScale:_shellScale];
    _shellSpriteNode.position = _cannonPivotPoint;
    _shellSpriteNode.zRotation = _angelOfCannon;
    _shellSpriteNode.zPosition = 80;
    
    _shellSpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_shellSpriteNode.size];
    _shellSpriteNode.physicsBody.affectedByGravity = NO;
    _shellSpriteNode.physicsBody.dynamic = YES;
    _shellSpriteNode.physicsBody.categoryBitMask = _shell;
    _shellSpriteNode.physicsBody.contactTestBitMask = _ship;

    
    SKAction* _moveShell = [SKAction moveTo:_pointBeyondScreen duration:_shellSpeed];
    SKAction* _deleteShell = [SKAction removeFromParent];
        
    [self addChild:_shellSpriteNode];
    [_shellSpriteNode runAction:[SKAction sequence:@[_moveShell,_deleteShell]]];
        
        
    //recoil the cannon
    
    CGPoint pointOfrecoil = [Geometry_Calculations findCrossPointLine1Point1:pos nLine1Point2:_cannonPivotPoint nLine2Point1:CGPointMake(CGRectGetMinX(self.frame), _cannonPivotPoint.y-_cannonPositionShift) nLine2Point2:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y-_cannonPositionShift)];
    
    SKAction* _recoilCannon = [SKAction moveTo:pointOfrecoil duration:_cannonRecoilSpeed];
    SKAction* _moveCannonBackInPlace = [SKAction moveTo:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y) duration:_cannonRecoilSpeed];

    [_cannonSpriteNode runAction:[SKAction sequence:@[_recoilCannon,_moveCannonBackInPlace]]];
    
    }
}


- (void)spawnShip {
    
    SKSpriteNode* _nShip = [SKSpriteNode spriteNodeWithTexture:_shipTexture];
    [_nShip setScale:_shipScale];
    
    //set range of Y coordinate to choose from
    CGFloat rangeMaxY = (CGRectGetMaxY(self.frame) - _shipTexture.size.height) + fabs(_minYToReact);
    CGFloat y = (arc4random() % (NSInteger)(rangeMaxY)) - fabs(_minYToReact);
    
    _nShip.position = CGPointMake(self.frame.size.width, y);
    _nShip.zPosition = 100;
    
    _nShip.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_nShip.size];
    _nShip.physicsBody.affectedByGravity = NO;
    _nShip.physicsBody.dynamic = YES;
    _nShip.physicsBody.categoryBitMask = _ship;
   
    
    SKAction* _moveShip = [SKAction moveTo:CGPointMake(CGRectGetMinX(self.frame)-_shipTexture.size.width/2, y) duration:_shipSpeed];
    SKAction* _deleteShip = [SKAction removeFromParent];
    [self addChild:_nShip];
    
    [_nShip runAction: [SKAction sequence:@[_moveShip,_deleteShip]]];

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


- (void)didBeginContact:(SKPhysicsContact *)contact {
    _contactPoint = contact.contactPoint;
    
   
    //boom effect
    SKSpriteNode* _boom = [SKSpriteNode spriteNodeWithTexture:_boomTexture];
    _boom.position = _contactPoint;
    [_boom setScale:0.1];
    
    [self addChild:_boom];
    [_boom runAction: [SKAction sequence:@[[SKAction scaleTo:_boomScale duration:_boomScaleSpeed],[SKAction removeFromParent]]]];
    
    if (contact.bodyA.categoryBitMask == _shell) {
      [contact.bodyA.node setHidden:YES];
    }
    else {
      [contact.bodyB.node setHidden:YES];
    }
    
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
    [contact.bodyA.node runAction:[SKAction removeFromParent]];
    [contact.bodyB.node runAction:[SKAction removeFromParent]];
    
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
