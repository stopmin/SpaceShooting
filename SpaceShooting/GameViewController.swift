//
//  GameViewController.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/01/25.
//

import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            
            let scene = MenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true     // 컴퓨터에게 객체를 그리는 순서를 맡기겠다
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
