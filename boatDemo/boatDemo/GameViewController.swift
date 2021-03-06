//
//  GameViewController.swift
//  boatDemo
//
//  Created by Dust Liu on 2021/9/12.
//

import UIKit
import SpriteKit
import GameplayKit


class GameViewController: UIViewController {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        processClientSocket()
        
        if let view = self.view as! SKView? {
            let gameScene = GameScene(size: view.bounds.size)
            gameScene.scaleMode = .resizeFill
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.presentScene(gameScene)
        }
    }
    
    

    override var shouldAutorotate: Bool {
        return true
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
