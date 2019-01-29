//
//  GameControllerSwift.swift
//  VRBoilerplate
//
//  Created by Andrian Budantsov on 5/21/16.
//  Copyright © 2016 Andrian Budantsov. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class Position {
    var order : Int
    var position : SCNVector3
    
    init (_ ord:Int,_ x:Float,_ y:Float,_ z:Float) {
        order = ord
        position = SCNVector3(x, y, z)
    }
}

@objc(VRControllerSwift)
class VRControllerSwift : NSObject, VRControllerProtocol {
    var scene : SCNScene
    let cursor = SCNNode()
    
    var voting : SCNNode
    var focusedNode : SCNNode?
    var isFocused = false
    var lastFocused : TimeInterval
    var currentPosition : Position?
    
    let whiteMaterial = VRControllerSwift.materialNoShadow(color: .white)
    let greyMaterial = VRControllerSwift.material(color: .gray)
    let yellowMaterial = VRControllerSwift.material(color: .yellow)
    
    var playerOpt : AVAudioPlayer?
    
    var subjectOrientation = true
    var orientationPositions : [Position] = [
        Position(2, 5, -1.6, -10), // Right close
        Position(3, -12, -1.6, -26), // left far
        Position(1, 0, -1.6, -5), // Center close
    ]
    
    var conePositions : [Position] = [
        
        //
        // Main test points
        //
        
        Position(1, -1.75, -1.6, -22.57),
        Position(2, 1.75, -1.6, -22.57),

        Position(3, -3.5, -1.6, -20.82),
        Position(4, 0, -1.6, -20.82),
        Position(5, 3.5, -1.6, -20.82),

        Position(6, -5.25, -1.6, -19.07),
        Position(7, -1.75, -1.6, -19.07),
        Position(8, 1.75, -1.6, -19.07),
        Position(9, 5.25, -1.6, -19.07),

        Position(10, -3.5, -1.6, -17.32),
        Position(11, 0, -1.6, -17.32),
        Position(12, 3.5, -1.6, -17.32),

        Position(13, -5.25, -1.6, -15.57),
        Position(14, -1.75, -1.6, -15.57),
        Position(15, 1.75, -1.6, -15.57),
        Position(16, 5.25, -1.6, -15.57),

        Position(17, -3.5, -1.6, -13.82),
        Position(18, 0, -1.6, -13.82),
        Position(19, 3.5, -1.6, -13.82),

        Position(20, -1.75, -1.6, -12.07),
        Position(21, 1.75, -1.6, -12.07),
    ]
    
    // MARK: Game Controller
    
    static func material(color : UIColor) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = color
        return m
    }
    
    static func materialNoShadow(color : UIColor) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = color
        m.ambient.contents = color
        m.emission.contents = color
        return m
    }
    
    func playSound(_ name:String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            fatalError("Can't locate sound effect")
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            playerOpt = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = playerOpt else {
                fatalError("Can't create player")
            }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func vote() {
        if subjectOrientation {
            if orientationPositions.count > 0 {
                playSound("Blop")
                let cone = scene.rootNode.childNode(withName: "cone_test", recursively: false)
                currentPosition = orientationPositions.popLast()!
                cone?.position = (currentPosition?.position)!
            } else {
                playSound("Done")
                let cone = scene.rootNode.childNode(withName: "cone_test", recursively: false)
                currentPosition = conePositions.popLast()!
                cone?.position = (currentPosition?.position)!
                subjectOrientation = false
            }
            return;
        }
        
        DispatchQueue.main.async {
            let app = UIApplication.shared.delegate as! AppDelegate
            let name = (self.focusedNode?.name)!
            let point = self.currentPosition?.order
            let vote = Int(name.replacingOccurrences(of: "text_", with: ""))
            NSLog("%d, %d", point!, vote!)
            app.store(point: point!, vote: vote!)
        }
        
        if conePositions.count > 0 {
            playSound("Blop")
            let cone = scene.rootNode.childNode(withName: "cone_test", recursively: false)
            currentPosition = conePositions.popLast()!
            cone?.position = (currentPosition?.position)!
        } else {
            playSound("Done")
            let cone = scene.rootNode.childNode(withName: "cone_test", recursively: false)
            cone?.removeFromParentNode()
            
            DispatchQueue.main.async {
                let app = UIApplication.shared.delegate as! AppDelegate
                app.closeFile()
                app.window?.rootViewController?.performBackSegue()
                app.openFile()
            }
        }
    }
    
    required override init() {
        guard let sceneOpt = SCNScene(named: "Cones.scnassets/ConeField.scn") else {
            fatalError("Unable to load scene file.")
        }
        scene = sceneOpt
        
        guard let voteBox = scene.rootNode.childNode(withName: "voting", recursively: false) else {
            fatalError("Can't find vote box")
        }
        voting = voteBox
        
        lastFocused = Date.timeIntervalSinceReferenceDate
        conePositions = conePositions.shuffled()
        
        let cone = scene.rootNode.childNode(withName: "cone_test", recursively: false)
        currentPosition = orientationPositions.popLast()!
        cone?.position = (currentPosition?.position)!
        
        cursor.geometry = SCNSphere(radius: 0.003)
        cursor.physicsBody = nil
        cursor.geometry?.materials = [whiteMaterial];
        
        scene.rootNode.addChildNode(cursor)
    }
    
    func prepareFrame(with headTransform: GVRHeadTransform) {
        
        let p1 = headTransform.rotateVector(SCNVector3(0, -0.2, -0.5))
        cursor.position = p1
        
        //let p2 = headTransform.rotateVector(SCNVector3(0, -0.2, -3))
        let v1 = SCNVector3ToGLKVector3(p1);
        let v2 = GLKVector3Normalize(v1);
        let v3 = GLKVector3MultiplyScalar(v2, 6);
        let p2 = SCNVector3FromGLKVector3(v3);
        let hits = voting.hitTestWithSegment(from: p1, to: p2, options: [
            SCNHitTestOption.firstFoundOnly.rawValue: true,
            SCNHitTestOption.boundingBoxOnly.rawValue: true,
            ])
        
        if let hit = hits.first {
            if !isFocused || focusedNode != hit.node {
                lastFocused = Date.timeIntervalSinceReferenceDate
            }
            focusedNode = hit.node
            isFocused = true
        } else {
            focusedNode = nil
            isFocused = false
        }
        
        voting.enumerateChildNodes { (node, end) in
            node.geometry?.materials = [self.greyMaterial]
        };
        
        if isFocused && Date.timeIntervalSinceReferenceDate - lastFocused > 2.5 {
            vote()
            isFocused = false
        }
        
        if isFocused {
            focusedNode?.geometry?.materials = [yellowMaterial]
        }
    }
    
    func eventTriggered() {
        
    }
    
    func cleanUp() {
        
    }
    
}


