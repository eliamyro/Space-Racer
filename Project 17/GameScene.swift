//
//  GameScene.swift
//  Project 17
//
//  Created by Elias Myronidis on 4/12/19.
//  Copyright © 2019 Elias Myronidis. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    lazy var starfield: SKEmitterNode = {
        let emitterNode = SKEmitterNode(fileNamed: "starfield")
        emitterNode?.position = CGPoint(x: 1024, y: 384)
        emitterNode?.advanceSimulationTime(10)
        emitterNode?.zPosition = -1
        
        return emitterNode!
    }()
    
    lazy var player: SKSpriteNode = {
        let spriteNode = SKSpriteNode(imageNamed: "player")
        spriteNode.position = CGPoint(x: 100, y: 384)
        spriteNode.physicsBody = SKPhysicsBody(texture: spriteNode.texture!, size: spriteNode.size)
        spriteNode.physicsBody?.contactTestBitMask = 1
        
        return spriteNode
    }()
    
    lazy var scoreLabel: SKLabelNode = {
        let labelNode = SKLabelNode(fontNamed: "Chulkduster")
        labelNode.position = CGPoint(x: 16, y: 16)
        labelNode.horizontalAlignmentMode = .left
        
        return labelNode
    }()
    
    private var possibleEnemies = ["ball", "hammer", "tv"]
    private var gameTimer: Timer?
    private var isGameOver: Bool = false
    private var enemiesCounter = 0
    private var timerInterval: Double = 1.0
    private var lastPosition = CGPoint(x: 100, y: 368)
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        addChild(starfield)
        addChild(scoreLabel)
        addChild(player)
        
        score = 0
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        } else {
            gameTimer?.invalidate()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let explosion = SKEmitterNode(fileNamed: "explosion") else { return }
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100  {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = CGPoint(x: 100, y: location.y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.position = CGPoint(x: 100, y: 368)
    }
    
    @objc private func createEnemy() {
        
        guard let enemy = possibleEnemies.randomElement() else { return }
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        addChild(sprite)
        
        enemiesCounter += 1
        
        if enemiesCounter % 20 == 0 {
            timerInterval -= 0.1
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
}
