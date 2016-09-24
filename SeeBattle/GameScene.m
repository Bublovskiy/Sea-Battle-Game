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
SKShapeNode* _laserPointShapeNode;
SKLabelNode* _gameOverText;

//SKNode* _midLineNode;
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
unsigned int _loosScore = 3;
unsigned int _winScore = 0;

BOOL _isGameLost = NO;
BOOL _isLaserPointOn = YES;

- (void)didMoveToView:(SKView *)view {
    
    //set main screen color
    self.physicsWorld.contactDelegate = self;
    
    SKSpriteNode* backgroundView =[SKSpriteNode spriteNodeWithImageNamed:@"Ocean"];
    [backgroundView setSize:self.size];                                    //scale to math the current screen size
    [backgroundView setZPosition:-1];                                      //place it behind everything
    
    [self addChild:backgroundView];
   
    //set the Cannon
    
    SKTexture* cannonTexture = [SKTexture textureWithImageNamed:@"Cannon"];
    
    _cannonSpriteNode = [SKSpriteNode spriteNodeWithTexture:cannonTexture];
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
    
    SKAction* generateShip = [SKAction performSelector:@selector(spawnShip) onTarget:self];
    SKAction* shipdelay = [SKAction waitForDuration:SHIP_AAPEARANCE_DELEY];
    SKAction* shipSequebce = [SKAction sequence:@[generateShip,shipdelay]];
    SKAction* generateShipsForever = [SKAction repeatActionForever:shipSequebce];
    [self runAction:generateShipsForever];
    
    //set boom
    _boomTexture = [SKTexture textureWithImageNamed:@"Boom"];
    
    //set score counters
    
    _looseScoreNode = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    [_looseScoreNode setFontColor:[UIColor purpleColor]];
    [_looseScoreNode setText:[NSString stringWithFormat:@"%d",_loosScore]];
    _looseScoreNode.zPosition = 100;
    [_looseScoreNode setScale:SCORE_SCALE];
    _looseScoreNode.position = CGPointMake(CGRectGetMinX(self.frame)/2, _cannonPivotPoint.y);
    [self addChild:_looseScoreNode];
    
    _winScoreNode = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    [_winScoreNode setFontColor:[UIColor purpleColor]];
    [_winScoreNode setText:[NSString stringWithFormat:@"%d",_winScore]];
    _winScoreNode.zPosition = 100;
    [_winScoreNode setScale:SCORE_SCALE];
    _winScoreNode.position = CGPointMake(CGRectGetMaxX(self.frame)/2, _cannonPivotPoint.y);
    [self addChild:_winScoreNode];
    
    //set laser point
    
    [self turnOnLaserPoint:_isLaserPointOn];

    //set double tap
    
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction)];
    doubleTap.numberOfTapsRequired = 2;
    
    [self.view addGestureRecognizer:doubleTap];
    
    //set game over node
    
    _gameOverText = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    [_gameOverText setText:GAME_OVER_MESSAGE];
    [_gameOverText setScale:GAME_OVER_MESSAGE_SCALE];
    _gameOverText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
}


- (void)touchDownAtPoint:(CGPoint)pos {
    
    if (_isGameLost) {
    
        [self restartGame];
        
    }
    
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
    if (pos.y>=_minYToReactToClick) {
        
    _angelOfCannon = [Geometry_Calculations findAngelToRotateCannonForPointOfTouch:pos andCannonPosition:_cannonPivotPoint withCannonShift:_cannonPositionShift];
        
    //turn the cannon
    
    SKAction* cannotTurningAction = [SKAction rotateToAngle:_angelOfCannon duration:CANNON_TURNING_SPEED];

    [_cannonSpriteNode runAction:cannotTurningAction];
    
    if (_isLaserPointOn) {
        //[_laserPointNode runAction:cannotTurningAction];
         [_laserPointShapeNode runAction:cannotTurningAction];
    }
       
    
    }
}

- (void)touchUpAtPoint:(CGPoint)pos {
    
    //firing possible every CANNON_RELOAD_TIME sec
    
    if ((pos.y>=_minYToReactToClick)&&((time(NULL) - _currentTime)>=CANNON_RELOAD_TIME)) {
    
    
    _currentTime = (unsigned int)time(NULL);                //update current time counter
    
    //fire a shell
    CGPoint pointBeyondScreen = [Geometry_Calculations
                                        findCrossPointLine1Point1: _cannonPivotPoint
                                        nLine1Point2: pos
                                        nLine2Point1: CGPointMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame))nLine2Point2: CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame))];
        
    SKSpriteNode* shellSpriteNode = [SKSpriteNode spriteNodeWithTexture:_shellTexture];
    [shellSpriteNode setScale:SHELL_SCALE];
    shellSpriteNode.position = _cannonPivotPoint;
    shellSpriteNode.zRotation = _angelOfCannon;
    shellSpriteNode.zPosition = 80;
    
    shellSpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shellSpriteNode.size];
    shellSpriteNode.physicsBody.affectedByGravity = NO;
    shellSpriteNode.physicsBody.dynamic = YES;
    shellSpriteNode.physicsBody.categoryBitMask = _shell;
    shellSpriteNode.physicsBody.contactTestBitMask = _ship;

    
    SKAction* moveShell = [SKAction moveTo:pointBeyondScreen duration:SHELL_SPEED];
    SKAction* deleteShell = [SKAction removeFromParent];
        
    [self addChild:shellSpriteNode];
    [shellSpriteNode runAction:[SKAction sequence:@[moveShell,deleteShell]]];
        
        
    //recoil the cannon
    
    CGPoint pointOfrecoil = [Geometry_Calculations findCrossPointLine1Point1:pos nLine1Point2:_cannonPivotPoint nLine2Point1:CGPointMake(CGRectGetMinX(self.frame), _cannonPivotPoint.y-_cannonPositionShift) nLine2Point2:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y-_cannonPositionShift)];
    
    SKAction* recoilCannon = [SKAction moveTo:pointOfrecoil duration:CANNON_RECOIL_SPEED];
    SKAction* moveCannonBackInPlace = [SKAction moveTo:CGPointMake(_cannonPivotPoint.x, _cannonPivotPoint.y) duration:CANNON_RECOIL_SPEED];

    [_cannonSpriteNode runAction:[SKAction sequence:@[recoilCannon,moveCannonBackInPlace]]];
    
    }
}


- (void)spawnShip {
    
    SKSpriteNode* nShip = [SKSpriteNode spriteNodeWithTexture:_shipsTextures[arc4random() % 2]];
    [nShip setScale:SHIP_SCALE];
    
    //set range of Y coordinate to choose from
    CGFloat rangeMaxY = (CGRectGetMaxY(self.frame) - nShip.size.height) + fabs(_minYToReactToClick);
    CGFloat y = (arc4random() % (NSInteger)(rangeMaxY)) - fabs(_minYToReactToClick);
    
    nShip.position = CGPointMake(self.frame.size.width, y);
    nShip.zPosition = 100;
    
    nShip.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:nShip.size];
    nShip.physicsBody.affectedByGravity = NO;
    nShip.physicsBody.dynamic = YES;
    nShip.physicsBody.categoryBitMask = _ship;
   
    
    SKAction* moveShip = [SKAction moveTo:CGPointMake(CGRectGetMinX(self.frame)-nShip.size.width/2, y) duration: SHIP_SPEED];
    SKAction* deleteShip = [SKAction removeFromParent];
    [self addChild:nShip];
    
    [nShip runAction: [SKAction sequence:@[moveShip,deleteShip]] completion:^{
    
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
    
    //hide score
    
    [_looseScoreNode setHidden:YES];
    
    //show Game Over Sign
    
    [self addChild:_gameOverText];
    
}

- (void) restartGame {

    //remove Game Over Sign
    
    [_gameOverText removeFromParent];
    
    //reset scores
    
    _loosScore = LOOSE_SHIPS_LIMIT;
    _winScore = 0;
    
    //show score node
    
    [_looseScoreNode setHidden:NO];
    
    //put new values in scores signs
    
    [self animateAndChangeScore:_looseScoreNode to:_loosScore];
    [self animateAndChangeScore:_winScoreNode to:_winScore];
    
    _isGameLost = NO;
    
}

- (void) turnOnLaserPoint: (BOOL) key {

    [_laserPointShapeNode setZRotation:_angelOfCannon];                //align the laser with the cannon angel in any case

    
    if (![_laserPointShapeNode inParentHierarchy:self]&&key){                //the first use of the laser point
  
        _laserPointShapeNode = [SKShapeNode node];
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        
        CGPathMoveToPoint(pathToDraw, NULL, _cannonPivotPoint.x,_cannonPivotPoint.y);
        CGPathAddLineToPoint(pathToDraw, NULL, 0,CGRectGetMaxY(self.frame)*2);
        
        _laserPointShapeNode.path = pathToDraw;
        
        [_laserPointShapeNode setStrokeColor:[SKColor redColor]];
        [_laserPointShapeNode setGlowWidth:3];
        [_laserPointShapeNode setLineWidth:2];
        [_laserPointShapeNode setPosition:_cannonPivotPoint];
        
        [self addChild:_laserPointShapeNode];
        
    }
    else {
        
        [_laserPointShapeNode setHidden:!key];

    }
    
}


- (void) doubleTapAction{

    _isLaserPointOn = !_isLaserPointOn;
    [self turnOnLaserPoint:_isLaserPointOn];
    
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
    SKSpriteNode* boom = [SKSpriteNode spriteNodeWithTexture:_boomTexture];
    boom.position = contact.contactPoint;
    [boom setScale:0.1];
    
    [self addChild:boom];
    [boom runAction: [SKAction sequence:@[[SKAction scaleTo:BOOM_SCALE duration:BOOM_SCALING_SPEED],[SKAction removeFromParent]]]];
    
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
    
    //remove a shell and a boat after the contact
    
    [contact.bodyA.node runAction:[SKAction removeFromParent]];
    [contact.bodyB.node runAction:[SKAction removeFromParent]];
    
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
}

@end
