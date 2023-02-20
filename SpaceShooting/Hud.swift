//
//  Hud.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/02/20.
//

import SpriteKit

class Hud: SKNode {
    
    // 화면 크기를 받아올 컨테이너
    var screenSize: CGSize!
    
    var scoreLabel = SKLabelNode()
    var score: Int = 0 {
        didSet {    // 값이 바꼈을 때의 처리
            scoreLabel.text = "score: \(score)"
        }
    }
    
    // 노치가 있는 기기면 스코어를 더 내려야함
    var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }
    
    var livesArray: [SKSpriteNode] = []
    
    func createHud(screenSize: CGSize) {
        self.screenSize = screenSize
        
        addScoreLabel()
        addLives()
    }
    
    func addScoreLabel() {
        scoreLabel.text = "Score: 0"
        scoreLabel.fontName = "Minercraftory"
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 20
        scoreLabel.position.x = 20
        
        if hasTopNotch {
            scoreLabel.position.y = screenSize.height - 84
        } else {
            scoreLabel.position.y = screenSize.height - 40
        }
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = Layer.hud
        self.addChild(scoreLabel)
    }
    
    func addLives() {
        for live in 1...3 {
            let liveNode = SKSpriteNode(texture: Atlas.gameobject.textureNamed("heart"))
            liveNode.position.x = screenSize.width - 10 - CGFloat(4 - live) * liveNode.size.width
            
            if hasTopNotch {
                liveNode.position.y = screenSize.height - 74
            } else {
                liveNode.position.y = screenSize.height - 30
            }
            
            liveNode.zPosition = Layer.hud
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
    func subtractLive() {
        guard let liveNode = self.livesArray.first else { return }
        liveNode.removeFromParent()
        self.livesArray.removeFirst()
    }
}
