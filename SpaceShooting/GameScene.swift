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
    var enemyTimer = Timer()
    var enemyInterval: TimeInterval = 1.2
    
    var player: Player! // 널 값이 안들어가는게 확실!
    var playerFireTimer = Timer()
    
    override func didMove(to view: SKView) {    // 화면 초기화
        // 배경용 별무리 붙이기
        guard let starfield = SKEmitterNode(fileNamed: Particle.starfield) else {return}   // 파일이 없을 경우 return
        starfield.position = CGPoint(x: size.width / 2, y: size.height) // 화면의 중간지점, 제일 위쪽
        starfield.zPosition = Layer.starfield
        starfield.advanceSimulationTime(30) // 화면이 30초 진행된 상태에서 시작해라
        self.addChild(starfield)
        
        //        addMeteor()
        meteorTimer = setTimer(interval: meteorInterval, function: self.addMeteor)  // 메테오 타이머에 부여한다 이때 addmeteor는 Self형태로
        enemyTimer = setTimer(interval: enemyInterval, function: self.addEnemy)
        
        // 플레이어 배치
        player = Player(screenSize: self.size)
        player.position = CGPoint(x: size.width / 2, y: player.size.height * 2)
        self.addChild(player) // player 게임 씬에 붙여주기
        
        playerFireTimer = setTimer(interval: 0.4, function: self.playerFire)
        
    }
    
    func playerFire() {
        let missile = self.player.createMissile()
        self.addChild(missile)
        self.player.fireMissile(missile: missile) // firemissile을 통해 화면 밖으로 보낸다
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
    
    func addEnemy() {
        let randomEnemy = arc4random_uniform(UInt32(3)) + 1
        let randomXpos = self.player.size.width / 2 + CGFloat(arc4random_uniform(UInt32(self.size.width - self.player.size.width / 2)))
        let randomSpeed = TimeInterval(arc4random_uniform(UInt32(3)) + 3)
        
        let texture = Atlas.gameobject.textureNamed("enemy\(randomEnemy)")
        let enemy = SKSpriteNode(texture: texture)
        enemy.name = "enemy"
        enemy.position = CGPoint(x: randomXpos, y: self.size.height + enemy.size.height)
        enemy.zPosition = Layer.enemy
        
        self.addChild(enemy)
        
        let moveAct = SKAction.moveTo(y: -enemy.size.height, duration: randomSpeed)
        let removeAct = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAct, removeAct]))
    }
    
    func setTimer(interval: TimeInterval, function:@escaping () -> Void) -> Timer { // 함수를 포인터형태로
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true){ _ in function()
        }
        timer.tolerance = interval * 0.2    // 여유분을 제공
        
        return timer
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var location: CGPoint!
        if let touch = touches.first {
            location = touch.location(in: self)
        }
        self.player.run(SKAction.moveTo(x: location.x, duration: 0.2))
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        playerFire()
//    }
}
