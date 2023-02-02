//
//  Plater.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/01/26.
//

import SpriteKit

class Player: SKSpriteNode{
    var screenSize: CGSize!
    
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        let playerTexture = Atlas.gameobject.textureNamed("player")
        super.init(texture: playerTexture, color:SKColor.clear, size: playerTexture.size())
        self.zPosition = Layer.player
        
        // 스러스터 붙이기
        guard let thruster = SKEmitterNode(fileNamed: Particle.playerThruster) else {return}
        thruster.position.y -= self.size.height / 2
        thruster.zPosition = Layer.sub
        // 알파블렌딩 문제 해결
        let thrusterEffectNode = SKEffectNode()
        thrusterEffectNode.addChild(thruster)
        self.addChild(thrusterEffectNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 미사일 작성
    func createMissile() -> SKSpriteNode {
        let texture = Atlas.gameobject.textureNamed("playerMissile")
        let missile = SKSpriteNode(texture: texture)
        missile.position = self.position
        missile.position.y += self.size.height
        missile.zPosition = Layer.playermissile
        
        return missile
    }
    
    // 미사일 발사
    func fireMissile(missile: SKSpriteNode) {
        var actionArray = [SKAction]()
        actionArray.append(SKAction.moveTo(y: self.screenSize.height + missile.size.height, duration: 0.4))
        actionArray.append(SKAction.removeFromParent())
        
        missile.run(SKAction.sequence(actionArray))
    }
}
