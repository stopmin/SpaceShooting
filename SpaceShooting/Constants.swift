//
//  Constants.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/01/25.
//

import SpriteKit

struct  Particle {
    static let starfield = "starfield"
    static let playerThruster = "playerThruster"
    static let enemyThruster = "enemyThruster"
    static let explosion = "explosion"
    static let hit = "hit"
}

struct Layer {
    static let sub: CGFloat = -0.1
    static let upper: CGFloat = 0.1
    static let starfield:  CGFloat = 0
    static let meteor: CGFloat = 1
    static let playermissile: CGFloat = 10
    static let player: CGFloat = 11
    static let enemy: CGFloat = 12
    static let item: CGFloat = 13
    static let bossmissile: CGFloat = 14
    static let boss: CGFloat = 15
    static let hud: CGFloat = 30
    static let gameover: CGFloat = 40
}

struct Atlas {
    static let gameobject = SKTextureAtlas(named: "Gameobjects")
}

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let shield: UInt32 = 0x1 << 1
    static let missile: UInt32 = 0x1 << 2
    static let enemy: UInt32 = 0x1 << 3
    static let boss: UInt32 = 0x1 << 4
    static let bossMissile: UInt32 = 0x1 << 5
    static let meteor: UInt32 = 0x1 << 6
    static let item: UInt32 = 0x1 << 7
}
