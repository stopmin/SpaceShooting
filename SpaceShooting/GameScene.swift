//
//  GameScene.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/01/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // 타이머용 컨테이너
    var meteorTimer = Timer()
    var meteorInterval: TimeInterval = 2.0
    
    override func didMove(to view: SKView) {    // 화면 초기화
        // 배경용 별무리 붙이기
        guard let starfield = SKEmitterNode(fileNamed: Particle.starfield) else {return}   // 파일이 없을 경우 return
        starfield.position = CGPoint(x: size.width / 2, y: size.height) // 화면의 중간지점, 제일 위쪽
        starfield.zPosition = Layer.starfield
        starfield.advanceSimulationTime(30) // 화면이 30초 진행된 상태에서 시작해라
        self.addChild(starfield)
        
//        addMeteor()
        meteorTimer = setTimer(interval: meteorInterval, function: self.addMeteor)  // 메테오 타이머에 부여한다 이때 addmeteor는 Self형태로
    }
    
    
    func addMeteor() {  // meteor를 만드는 함수
        let randomMeteor = arc4random_uniform(UInt32(3)) + 1                    // 랜덤으로 메테오 생성 (3가지 중 1개)
        let randomXPos = CGFloat(arc4random_uniform(UInt32(self.size.width)))   // x위치
        let randomSpeed = TimeInterval(arc4random_uniform(UInt32(5)) + 5)       // 스피드도 랜덤
    
        let texture = Atlas.gameobject.textureNamed("meteor\(randomMeteor)")    // 메테오 스프라이트를 넣어줌
        let meteor = SKSpriteNode(texture: texture)                             // 랜더링
        meteor.name = "meteor"                                                  // 이름 붙여줌
        meteor.position = CGPoint(x: randomXPos, y: self.size.height + meteor.size.height)      // 메테오 사이즈만큼 큰 곳에 붙여줌
        meteor.zPosition = Layer.meteor // 백그라운드보다 하나 높은 위치
        
        self.addChild(meteor)
        
        let moveAct = SKAction.moveTo(y: -meteor.size.height, duration: randomSpeed)        // Y 값으로만 움직이도록
        let rotateAct = SKAction.rotate(byAngle: CGFloat(Double.pi), duration: randomSpeed) // 빙글빙글 돌리는 것
        let moveandRotateAct = SKAction.group([moveAct,rotateAct])                          // 그룹함수로 움직이는 엑션과 로테이트 동시에 줌
        let removeAct = SKAction.removeFromParent() // 화면에서 사용되지 않는 객체 제거
        
        meteor.run(SKAction.sequence([moveandRotateAct,removeAct]))
    }
    
    func setTimer(interval: TimeInterval, function:@escaping () -> Void) -> Timer { // 함수를 포인터형태로
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true){ _ in function()
        }
        timer.tolerance = interval * 0.2    // 여유분을 제공하는 것 (좀 더 느려져도 된다)
        
        return timer
    }
}
