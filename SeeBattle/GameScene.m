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

SKColor* _mainScreenColor;
SKSpriteNode* _cannonSpriteNode;
SKNode* _midLineNode;
SKLabelNode* _looseScoreNode;
SKLabelNode* _winScoreNode;

SKTexture* _shellTexture;
SKTexture* _boomTexture;
NSArray* _shipsTextures;

CGFloat _cannonPositionShift;
CGFloat _angelOfCannon;
CGFloat _minYToReactToClick;

//pivoting point for the cannon
CGPoint _cannonPivotPoint;

unsigned int _currentTime = 0;
unsigned int _loosScore = 1;
unsigned int _winScore = 0;

BOOL _isGameLost = NO;

- (void)didMoveToView:(SKView *)view {
    
    //set main screen color
    self.physicsWorld.contactDelegate = self;
    
    _mainScreenColor = [SKColor colorWithRed:0.2 green:0.8 blue:1 alpha:1];
    [self setBackgroundColor:_mainScreenColor];
    
    //set the Cannon
    
    SKTexture* _cannonTexture = [SKTexture textureWithImageNamed:@"Cannon"];
    
    _cannonSpriteNode = [SKSpriteNode spriteNodeWithTexture:_cannonTexture];
    _cannonSpriteNode.zPosition = 100;
    [_cannonSpriteNode setScale: CANNON_SCALE];
    
    //create a pivot point for the cannon on the screen
    _cannonPivotPoint.x = CGRectGetMidX(self.frame);
    _cannonPositionShift = _cannonSpriteNode.size.height/3;
    _cannonPivotPoint.y = CGRectGetMinY(self.frame) + _cannonPositionShift;
    _minYToReactToClick = _cannonPivotPoint.y + _cannonSpriteNode.size.height;
    
    _cannonSpriteNode.position = _cannonPivotPoint;
    [self addChild:_cannonSpriteNode];
    
    //set a shell
    
     _shellTexture = [SKTexture textureWithImageNamed:@"Shell"];
    
    //set ships
    
    _shipsTextures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"Ship1"],[SKTexture textureWithImageNamed:@"Ship2"],nil];
    
    SKAction* _generateShip = [SKAction performSelector:@selector(spawnShip) onTarget:self];
    SKAction* _shipdelay = [SKAction waitForDuration:SHIP_AAPEARANCE_DELEY];
    SKAction* _shipSequebce = [SKAction sequence:@[_generateShip,_shipdelay]];
    SKAction* _generateShipsForever = [SKAction repeatActionForever:_shipSequebce];
    [self runAction:_generateShipsForever];
    
    //set boom
    _boomTexture = [SKTexture textureWithImageNamed:@"Boom"];
    
    //set score counters
    
    _looseScoreNode = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    [_looseScoreNode setText:[NSString stringWithFormat:@"%d",_loosScore]];
    _looseScoreNode.zPosition = 100;
    [_looseScoreNode setScale:SCORE_SCALE];
    _looseScoreNode.position = CGPointMake(CGRectGetMinX(self.frame)/2, _cannonPivotPoint.y);
    [self addChild:_looseScoreNode];
    
    _winScoreNode = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    [_winScoreNode setText:[NSString stringWithFormat:@"%d",_winScore]];
    _winScoreNode.zPosition = 100;
    [_winScoreNode setScale:SCORE_SCALE];
    _winScoreNode.position = CGPointMake(CGRectGetMaxX(self.frame)/2, _cannonPivotPoint.y);
    [self addChild:_winScoreNode];
    

}


- (void)touchDownAtPoint:(CGPoint)pos {
    
    if (_isGameLost) {
    
        [self restartGame];
        
    }
    
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
    if ((pos.y>=_minYToReactToClick)&&!_isGameLost) {
        
    _angelOfCannon = [Geometry_Calculations findAngelToRotateCannonForPointOfTouch:pos andCannonPosition:_cannonPivotPoint withCannonShift:_cannonPositionShift];
        
    //turn the cannon
    SKAction* cannotTurningAction = [SKAction rotateToAngle:_angelOfCannon duration:CANNON_TURNING_SPEED];

    [_cannonSpriteNode runAction:cannotTurningAction];
    
    }
}

- (void)touchUpAtPoint:(CGPoint)pos {
    
    
    if ((pos.y>=_minYToReactToClick)&&((time(NULL) - _currentTime)>=CANNON_RELOAD_TIME)&&!_isGameLost) {
    
    _currentTime = (unsigned int)time(NULL);
    
    //fire a shell
    CGPoint _pointBeyondScreen = [Geometry_Calculations
                                        findCrossPointLine1Point1: _cannonPivotPoint
                                        nLine1Point2: pos
                                        nLine2Point1: CGPointMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame))nLine2Point2: CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame))];
        
    SKSpriteNode* _shellSpriteNode = [SKSpriteNode spriteNodeWithTexture:_shellTexture];
    [_shellSpriteNode setScale:SHELL_SCALE];
    _shellSpriteNode.position = _cannonPivotPoint;
    _shellSpriteNode.zRotation = _angelOfCannon;
    _shellSpriteNode.zPosition = 80;
    
    _shellSpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_shellSpriteNode.size];
    _shellSpriteNode.physicsBody.affectedByGravity = NO;
    _shellSpriteNode.physicsBody.dynamic = YES;
    _shellSpriteNode.physicsBody.categoryBitMask = _shell;
    _shellSpriteNode.physicsBody.contactTestBitMask = _ship;

    
    SKAction* _moveShell = [SKAction moveTo:_pointBeyondScreen duration:SHELL_SPEED];
    SKAction* _deleteShell = [SKAction removeFromParent];
        
    [self addChild:_shellSpriteNode];
    [_shellSpriteNode runAction:[SKAction sequence:@[_moveShell,_deleteShell]]];
        
        
    //recoil the cannon
    
    CGPoint pointOfrecoil = [Geometry_Calculations findCrossPointLine1Point1:pos nLine1Point2:_cannonPivotPoint nLine2Point1:CGPointMake(CGRectGetMinX(self.frame), _cannonPivotPoint.y-_cannonPositionShift) nLine2Point2:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y-_cannonPositionShift)];
    
    SKAction* _recoilCannon = [SKAction moveTo:pointOfrecoil duration:CANNON_RECOIL_SPEED];
    SKAction* _moveCannonBackInPlace = [SKAction moveTo:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y) duration:CANNON_RECOIL_SPEED];

    [_cannonSpriteNode runAction:[SKAction sequence:@[_recoilCannon,_moveCannonBackInPlace]]];
    
    }
}


- (void)spawnShip {
    
    SKSpriteNode* _nShip = [SKSpriteNode spriteNodeWithTexture:_shipsTextures[arc4random() % 2]];
    [_nShip setScale:SHIP_SCALE];
    
    //set range of Y coordinate to choose from
    CGFloat rangeMaxY = (CGRectGetMaxY(self.frame) - _nShip.size.height) + fabs(_minYToReactToClick);
    CGFloat y = (arc4random() % (NSInteger)(rangeMaxY)) - fabs(_minYToReactToClick);
    
    _nShip.position = CGPointMake(self.frame.size.width, y);
    _nShip.zPosition = 100;
    
    _nShip.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_nShip.size];
    _nShip.physicsBody.affectedByGravity = NO;
    _nShip.physicsBody.dynamic = YES;
    _nShip.physicsBody.categoryBitMask = _ship;
   
    
    SKAction* _moveShip = [SKAction moveTo:CGPointMake(CGRectGetMinX(self.frame)-_nShip.size.width/2, y) duration: SHIP_SPEED];
    SKAction* _deleteShip = [SKAction removeFromParent];
    [self addChild:_nShip];
    
    [_nShip runAction: [SKAction sequence:@[_moveShip,_deleteShip]] completion:^{
    
        //updare score
        
        _loosScore-=1;
        [self animateAndChangeScore:_looseScoreNode to:_loosScore];
        
        //stop the game if needed
        
        if (_loosScore == 0) {
            [self stopGame];
        }
    
        
    }];

    
}


- (void) animateAndChangeScore:(SKLabelNode*) labelToChange to:(int) newScore {

    [labelToChange setText:[NSString stringWithFormat:@"%d",newScore]];
    [labelToChange runAction:[SKAction sequence:@[[SKAction fadeOutWithDuration:SCORE_TEXT_UPDATE_SPEED],[SKAction fadeInWithDuration:SCORE_TEXT_UPDATE_SPEED]]]];
   
}


- (void) stopGame {
    
     _isGameLost = YES;
    
    //clear display
    
    [self removeAllChildren];
    
    //show Game Over Sign
    
    SKLabelNode* _gameOverText = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    [_gameOverText setText:GAME_OVER_MESSAGE];
    [_gameOverText setScale:GAME_OVER_MESSAGE_SCALE];
    _gameOverText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:_gameOverText];
    
}


- (void) restartGame {

    //clear dispalay
    
    [self removeAllChildren];

    //reset scores
    
    _loosScore = LOOSE_SHIPS_LIMIT;
    _winScore = 0;
    
    //restart all nodes
    [self addChild:_cannonSpriteNode];
    [self addChild:_looseScoreNode];
    [self addChild:_winScoreNode];
    
    //put new values in scores signs
    
    [self animateAndChangeScore:_looseScoreNode to:_loosScore];
    [self animateAndChangeScore:_winScoreNode to:_winScore];
    
    _isGameLost = NO;
    
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
    
    //boom effect
    SKSpriteNode* _boom = [SKSpriteNode spriteNodeWithTexture:_boomTexture];
    _boom.position = contact.contactPoint;
    [_boom setScale:0.1];
    
    [self addChild:_boom];
    [_boom runAction: [SKAction sequence:@[[SKAction scaleTo:BOOM_SCALE duration:BOOM_SCALING_SPEED],[SKAction removeFromParent]]]];
    
    if (contact.bodyA.categoryBitMask == _shell) {
      [contact.bodyA.node setHidden:YES];
    }
    else {
      [contact.bodyB.node setHidden:YES];
    }
    
    //updare score
    
    _winScore +=1;
    [self animateAndChangeScore:_winScoreNode to:_winScore];
    
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
    [contact.bodyA.node runAction:[SKAction removeFromParent]];
    [contact.bodyB.node runAction:[SKAction removeFromParent]];
    
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
