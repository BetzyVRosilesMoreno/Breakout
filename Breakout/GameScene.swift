//
//  GameScene.swift
//  Breakout
//
//  Created by Betzy Moreno on 3/18/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var loseZone = SKSpriteNode()
    var playLable = SKLabelNode()
    var livesLable = SKLabelNode()
    var scoreLable = SKLabelNode()
    var playingGame = false
    var score = 0
    var lives = 3
    var removeBricks = 0
    
    override func didMove(to view: SKView) {
        // this stuff happens once (when the app opens)
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        resetGame()
    }
    
    func resetGame() {
        //This stuff happens before each game stars
        makeBall()
        makePaddle()
        makeBricks()
        makeLoseZone()
        kickBall()
        makeLabels()
        updateLabels()
    }
    
    func kickBall() {
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 5))
    }
    
    func updateLabels() {
        scoreLable.text = "Score: \(score)"
        livesLable.text = "Lives: \(lives)"
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "Stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveRest = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveRest])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeBall() {
        ball.removeFromParent () // remove the ball (if it exists)
        ball = SKShapeNode (circleOfRadius: 10)
        ball.position = CGPoint (x: frame.midX, y: frame.midY)
        ball.strokeColor = .black
        ball.fillColor = .yellow
        ball.name = "ball"
        
        // physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) // add ball obiect to the view
    }
    
    func makePaddle() {
        paddle.removeFromParent()  //remove the paddle, if it exists
        paddle = SKSpriteNode(color: .white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBricks() {
        // first, remove any leftover bricks (from prior game)
        for brick in bricks {
            if brick.parent != nil {
                brick.removeFromParent()
            }
        }
        bricks.removeAll() // clear the array
        removeBricks = 0 // reset the counter
        
        // now, figure the number and spacing for each row of bricks
        let count = Int(frame.width) / 55  // bricks per row
        let xOffset = (Int(frame.width) - (count * 55)) / 2 + Int(frame.minX) + 25
        let colors: [UIColor] = [.blue, .orange, .green]
        for r in 0..<3 {
            let y = Int(frame.maxY) - 65 - (r * 25)
            for i in 0..<count {
                let x = i * 55 + xOffset
                makeBrick(x: x, y: y, color: colors[r])
            }
        }
    }
    
    // helper function used  to make each brick
    func makeBrick(x: Int, y: Int, color: UIColor) {
        let brick = SKSpriteNode(color: color, size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: x, y: y)
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
        bricks.append(brick)
    }
    
    func makeLoseZone() {
        loseZone = SKSpriteNode (color: .red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody (rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    func makeLabels() {
        playLable.fontSize = 24
        playLable.text = "Tap To Start"
        playLable.fontName = "Arial"
        playLable.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playLable.name = "playLable"
        addChild(playLable)
        
        livesLable.fontSize = 18
        livesLable.fontColor = .black
        livesLable.position = CGPoint(x: frame.minX + 50, y: frame.minY + 18)
        addChild(livesLable)
        
        scoreLable.fontSize = 18
        scoreLable.fontColor = .black
        scoreLable.fontName = "Arial"
        scoreLable.position = CGPoint(x: frame.maxX - 50, y: frame.minY + 18)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if playingGame {
                paddle.position.x = location.x
            }
            else{
                for node in nodes(at: location) {
                    if node.name == "playLable" {
                        playingGame = true
                        node.alpha = 0
                        score = 0
                        lives = 3
                        updateLabels()
                        kickBall()
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if playingGame {
                paddle.position.x = location.x
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //ask each brick, "Is it you?"
        for brick in bricks {
            if contact.bodyA.node?.name == "brick" ||
                contact.bodyB.node?.name == "brick" {
                score += 1
                updateLabels()
                if brick.color == .blue {
                    brick.color = .orange //blue bricks turn orange
                }
                else if brick.color == .orange {
                    brick.color = .green // orange bricks turn green
                }
                else{ // must be a green brick, which get remove
                brick.removeFromParent()
                removeBricks += 1
                    if removeBricks == bricks.count {
                        gameOver(winner: true)
                    }
                }
        }
        }
        if contact.bodyA.node?.name == "LoseZone" ||
            contact.bodyB.node?.name == "LoseZone" {
            lives -= 1
            if lives > 0 {
                score = 0
                resetGame()
                kickBall()
            }
            else {
                gameOver(winner: false)
            }
        }
    }
    
    func gameOver (winner: Bool) {
        playingGame = false
        playLable.alpha = 1
        resetGame ()
        if winner {
            playLable.text = "You win! Tap to play again"
        }
        else {
            playLable.text = "You lose! Tap to play again"
        }
        
    }
}
