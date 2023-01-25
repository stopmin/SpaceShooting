//
//  Constants.swift
//  SpaceShooting
//
//  Created by 정지민 on 2023/01/25.
//

import SpriteKit

struct  Particle {
    static let starfield = "starfield"
}

struct Layer {
    static let starfield:  CGFloat = 0
    static let meteor: CGFloat = 1
    static let playermissile: CGFloat = 10
    static let player: CGFloat = 11
}

struct Atlas {
    static let gameobject = SKTextureAtlas(named: "Gameobjects")
}
