//
//  GameScene.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/01/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let cameraNode = SKCameraNode()
    
    // 타이머용 컨테이너
    var meteorTimer = Timer()
    var meteorInterval: TimeInterval = 2.0
    var enemyTimer = Timer()
    var enemyInterval: TimeInterval = 1.2
    
    var player: Player! // 널 값이 안들어가는게 확실!
    var playerFireTimer = Timer()
    
    
    let hud = Hud()
    
    var boss: Boss?
    var isBossOnScreen = false
    var bossNumber = 2
    var bossFireTimer1 = Timer()
    var bossFireTimer2 = Timer()
    
    
    override func didMove(to view: SKView) {    // 화면 초기화
        
        // 물리효과 판정 델리게이트 셋업
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        
        // 카메라 추가
        self.camera = cameraNode
        cameraNode.position.x = self.size.width / 2
        cameraNode.position.y = self.size.height / 2
        self.addChild(cameraNode)

        // 배경용 별무리 붙이기
        guard let starfield = SKEmitterNode(fileNamed: Particle.starfield) else {return}   // 파일이 없을 경우 return
        starfield.position = CGPoint(x: size.width / 2, y: size.height) // 화면의 중간지점, 제일 위쪽
        starfield.zPosition = Layer.starfield
        starfield.advanceSimulationTime(30) // 화면이 30초 진행된 상태에서 시작해라
        self.addChild(starfield)
        
        
        hud.createHud(screenSize: self.size)
        self.addChild(hud)  // Hud객체를 화면에 붙여줌
        
        //        addMeteor()
        meteorTimer = setTimer(interval: meteorInterval, function: self.addMeteor)  // 메테오 타이머에 부여한다 이때 addmeteor는 Self형태로
        enemyTimer = setTimer(interval: enemyInterval, function: self.addEnemy)
        
        // 플레이어 배치
        player = Player(screenSize: self.size)
        player.position = CGPoint(x: size.width / 2, y: player.size.height * 2)
        self.addChild(player) // player 게임 씬에 붙여주기
        
        playerFireTimer = setTimer(interval: 0.4, function: self.playerFire)
        
        // 보스 배치 후 출현시킴
//        boss = Boss(screenSize: self.size, level: 1)
//        addChild(boss!)
//        boss!.appear()
        
    }
    
    // MARK - 미사일 발사 관련
    func playerFire() {
        let missile = self.player.createMissile()
        self.addChild(missile)
        self.player.fireMissile(missile: missile) // firemissile을 통해 화면 밖으로 보낸다
    }
    
    // 보스 직선샷
    func bossFire() {
        guard let boss = boss else {return}
        let missile = boss.createMissile()
        self.addChild(missile)
        let action = SKAction.sequence([SKAction.moveTo(y: -missile.size.width, duration: 3.0), SKAction.removeFromParent()])
        missile.run(action)
    }
    
    // 보서 원형샷
    func bossCircleFire(bPoint: CGPoint) {
        guard let boss = boss else {return}
        
        let seperate: Double = 30.0             // 원을 몇 개로 만드느냐
        let missileSpeed: TimeInterval = 8.0    // 미사일이 발사되는 속도
        
        for i in 0 ..< Int(seperate) {
            let r: CGFloat = self.size.height
            let x: CGFloat = r * CGFloat((cos(Double(i) * 2 * Double.pi / seperate)))
            let y: CGFloat = r * CGFloat((sin(Double(i) * 2 * Double.pi / seperate)))
           
            let action = SKAction.sequence([SKAction.move(to: CGPoint(x: bPoint.x + x, y: bPoint.y + y), duration: missileSpeed), SKAction.removeFromParent()])
            let missile = boss.createMissile()
            self.addChild(missile)
            missile.run(action)
        }
    }
    
    // MARK: - 각종 객체 생성
    func addMeteor() {  // meteor를 만드는 함수
        let randomMeteor = arc4random_uniform(UInt32(3)) + 1                    // 랜덤으로 메테오 생성 (3가지 중 1개)
        let randomXPos = CGFloat(arc4random_uniform(UInt32(self.size.width)))   // x위치
        let randomSpeed = TimeInterval(arc4random_uniform(UInt32(5)) + 5)       // 스피드도 랜덤
    
        let texture = Atlas.gameobject.textureNamed("meteor\(randomMeteor)")    // 메테오 스프라이트를 넣어줌
        let meteor = SKSpriteNode(texture: texture)                             // 랜더링
        meteor.name = "meteor"                                                  // 이름 붙여줌
        meteor.position = CGPoint(x: randomXPos, y: self.size.height + meteor.size.height)      // 메테오 사이즈만큼 큰 곳에 붙여줌
        meteor.zPosition = Layer.meteor // 백그라운드보다 하나 높은 위치
        
        
        // 물리바디 부여
        meteor.physicsBody = SKPhysicsBody(texture: texture, size: meteor.size)
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.meteor
        meteor.physicsBody?.contactTestBitMask = 0
        meteor.physicsBody?.collisionBitMask = 0
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
        
        // 물리바디 부여
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.height/2)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = 0
        enemy.physicsBody?.collisionBitMask = 0
        self.addChild(enemy)
        
        // 스러스터 효과 부착
        guard let thruster = SKEffectNode(fileNamed: Particle.enemyThruster) else {return}
        thruster.zPosition = Layer.sub
        let thrusterEffectNode = SKEffectNode()
        thrusterEffectNode.addChild(thruster)
        enemy.addChild(thrusterEffectNode)
        
        let moveAct = SKAction.moveTo(y: -enemy.size.height, duration: randomSpeed)
        let removeAct = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAct, removeAct]))
    }
    
    // MARK: - 타이머 관련
    func setTimer(interval: TimeInterval, function:@escaping () -> Void) -> Timer { // 함수를 포인터형태로
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true){ _ in function()
        }
        timer.tolerance = interval * 0.2    // 여유분을 제공
        
        return timer
    }
    
    func setTimer(interval: TimeInterval, function: @escaping (CGPoint) -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true){ _ in
            guard let boss = self.boss else {return}
            function(boss.position)
        }
        timer.tolerance = interval * 0.2
        
        return timer
    }
    
    // 데미지 이펙트 정의
    func explosion(targetNode: SKSpriteNode, isSmall: Bool) {
        let particle: String!
        if isSmall {
            particle = Particle.hit
        } else {
            particle = Particle.explosion
        }
        guard let explosion = SKEmitterNode(fileNamed: particle) else {return}
        explosion.position = targetNode.position
        explosion.zPosition = targetNode.zPosition
        self.addChild(explosion)
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
    }
    
    func playerDamgageEffect() {
        // 화면을 빨간색으로 점멸
        let flashNode = SKSpriteNode(color: SKColor.red, size: self.size)
        flashNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        flashNode.zPosition = Layer.hud
        self.addChild(flashNode)
        flashNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.01), SKAction.removeFromParent()]))
        
        // 화면 흔들기
        let moveLeft = SKAction.moveTo(x: self.size.width / 2 - 5, duration: 0.1)
        let moveRight = SKAction.moveTo(x: self.size.width / 2 + 5, duration: 0.1)
        let moveCentor = SKAction.moveTo(x: self.size.width / 2, duration: 0.1)
        let shakeAction = SKAction.sequence([moveLeft,moveRight,moveLeft,moveRight,moveCentor])
        shakeAction.timingMode = .easeInEaseOut
        self.cameraNode.run(shakeAction)
        
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 충돌한 두 바디 정렬
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player
            && secondBody.categoryBitMask == PhysicsCategory.meteor {
//             print("player and meteor!!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: false)
            targetNode.removeFromParent()
            
            playerDamgageEffect()
            hud.subtractLive()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player
            && secondBody.categoryBitMask == PhysicsCategory.enemy {
//            print("player and enemy!!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            playerDamgageEffect()
            hud.subtractLive()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.bossMissile {
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            playerDamgageEffect()
            hud.subtractLive()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile
            && secondBody.categoryBitMask == PhysicsCategory.meteor {
//            print("missile and meteor!!")
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: false)
            targetNode.removeFromParent()
            
            firstBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile
            && secondBody.categoryBitMask == PhysicsCategory.enemy {
//            print("missile and enemy!!")
            
            self.hud.score += 10
            
            guard let targetNode = secondBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            firstBody.node?.removeFromParent()
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.missile
            && secondBody.categoryBitMask == PhysicsCategory.boss {
            
            print("missile and boss!!")
            
            // 미사일이 부딪힌 부분에서 폭발처리
            guard let targetNode = firstBody.node as? SKSpriteNode else {return}
            explosion(targetNode: targetNode, isSmall: true)
            targetNode.removeFromParent()
            
            guard let boss = boss else {return}
            boss.shootCount += 1
            print(boss.shootCount)
            
//            if boss.shootCount >= (boss.maxHP / 2) {
//                let damageTexture = boss.createDamageTexture()
//                boss.addChild(damageTexture)
//            }
            
            if boss.shootCount > boss.maxHP {
//                print("boss has defeated!")
                
                explosion(targetNode: targetNode, isSmall: false)
                secondBody.node?.removeFromParent()
                self.boss = nil
                self.hud.score += 100
                self.bossNumber -= 1
                isBossOnScreen = false
                bossFireTimer1.invalidate() // 보스가 파괴되었을 때 화면에서 제거하고 내부 값을 nil로 변화시킨 뒤...
                bossFireTimer2.invalidate()
                
            } else if boss.shootCount >= Int(Double(boss.maxHP) * 0.6) {
//                print("boss HP left is 40%")
                
                // 2단게에서 3단계로 전환
                if boss.bossState == .secondStep{
                    boss.bossState = .thirdStep
                
                    bossFireTimer2 = setTimer(interval: 3.0, function: bossCircleFire(bPoint:))
                } else {return}
            } else if boss.shootCount >= Int(Double(boss.maxHP) * 0.2) {
//                print("boss HP left is 80%")
            
                // 1단계에서 2단계로 전환
                if boss.bossState == .firstStep {
                    boss.bossState = .secondStep
                    
                    bossFireTimer1 = setTimer(interval: 2.0, function: self.bossFire)
                } else {return}
            }
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isBossOnScreen{
            return
        } else if self.hud.score >= 350 {
            self.boss = Boss(screenSize: self.size, level: 2)
            guard let boss = boss else {return}
            self.addChild(boss)
            boss.appear()
            
            isBossOnScreen = true
        } else if self.hud.score >= 50 {
            if bossNumber == 2{
                self.boss = Boss(screenSize: self.size, level: 1)
                guard let boss = boss else {return}
                self.addChild(boss)
                boss.appear()
                
                isBossOnScreen = true
            } else {return}            
        }
    }
}
