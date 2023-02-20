//
//  Boss.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/02/20.
//

import SpriteKit

class Boss: SKSpriteNode {
    var screenSize: CGSize!
    var level: Int!
    
    // HP 관련
    let bossHP: [Int] = [50, 70]
    let maxHP: Int!
    var shootCount: Int = 0
    
    // MARK: - 초기화
    init(screenSize: CGSize, level: Int) {
        
        // 초기 파ㅏ라메타 결정
        self.screenSize = screenSize
        self.level = level
        self.maxHP = self.bossHP[level - 1]
        let texture = Atlas.gameobject.textureNamed(String(format: "boss%d", level))
        
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
            
        // 물리바디 셋업
        self.zPosition = Layer.boss
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.boss
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        
        self.position.x = screenSize.width / 2
        self.position.y = screenSize.height + texture.size().height
    }
    
    // 출현하는 애니메이션
    func appear() {
        let duration = 3.0
        let fadeIn = SKAction.moveTo(y: screenSize.height * 0.8, duration: duration)
        run(fadeIn)
    }
    
    // 데미지 표현하기
    func createDamageTexture() -> SKSpriteNode {
        let texture = Atlas.gameobject.textureNamed(String(format: "bossdamage%d", level))
        let overlay = SKSpriteNode(texture: texture)
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = Layer.upper
        overlay.colorBlendFactor = 0.0
        
        return overlay
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
