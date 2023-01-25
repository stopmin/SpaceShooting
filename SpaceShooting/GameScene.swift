//
//  GameScene.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/01/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {    // 화면 초기화
        // 배경용 별무리 붙이기
        guard let starfield = SKEmitterNode(fileNamed: Particle.starfield) else {return}   // 파일이 없을 경우 return
        starfield.position = CGPoint(x: size.width / 2, y: size.height) // 화면의 중간지점, 제일 위쪽
        starfield.zPosition = Layer.starfield
        starfield.advanceSimulationTime(30) // 화면이 30초 진행된 상태에서 시작해라
        self.addChild(starfield)
    }
}
