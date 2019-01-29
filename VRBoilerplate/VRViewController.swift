//
//  ViewController.swift
//  VRBoilerplate
//
//  Created by Andrian Budantsov on 5/19/16.
//  Copyright © 2016 Andrian Budantsov. All rights reserved.
//

import UIKit
import SpriteKit

class VRViewController: UIViewController, GVRCardboardViewDelegate {

    let VRControllerClassKey = "VRControllerClass";
    
    var vrController: VRControllerProtocol?;
    
    var renderer : SceneKitVRRenderer?;
    var renderLoop: RenderLoop?;
    
    override func loadView() {
        
        let vrControllerClassName = Bundle.main
            .object(forInfoDictionaryKey: VRControllerClassKey) as! String;
        
        guard let vrClass = NSClassFromString(vrControllerClassName) as? VRControllerProtocol.Type else {
            fatalError("#fail Unable to find class \(vrControllerClassName), referenced in Info.plist, key=\(VRControllerClassKey)")
        }
        
        vrController = vrClass.init();
        
        let cardboardView = GVRCardboardView.init(frame: CGRect.zero)
        cardboardView?.delegate = self;
        cardboardView?.autoresizingMask =  [.flexibleWidth, .flexibleHeight];
        
        // VR mode is disabled in simulator by default 
        // double click to enable 
        
        #if targetEnvironment(simulator)
            cardboardView?.vrModeEnabled = false;
        #else
            cardboardView?.vrModeEnabled = true;
        #endif
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(toggleVR));
        doubleTap.numberOfTapsRequired = 2;
        cardboardView?.addGestureRecognizer(doubleTap);
        
        self.view = cardboardView;
    }

    @objc func toggleVR() {
        guard let cardboardView = self.view as? GVRCardboardView else {
            fatalError("view is not GVRCardboardView")
        }
        
        cardboardView.vrModeEnabled = !cardboardView.vrModeEnabled;
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        guard let cardboardView = self.view as? GVRCardboardView else {
            fatalError("view is not GVRCardboardView")
        }
        
        renderLoop = RenderLoop.init(renderTarget: cardboardView,
                                     selector: #selector(GVRCardboardView.render));
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        renderLoop?.invalidate()
        vrController?.cleanUp()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        renderLoop = nil
        vrController = nil
        
        let vr:GVRCardboardView = self.view as! GVRCardboardView
        vr.vrModeEnabled = false
        vr.delegate = nil
    }
    
    
    func cardboardView(_ cardboardView: GVRCardboardView!, willStartDrawing headTransform: GVRHeadTransform!) {
        renderer = SceneKitVRRenderer(scene:vrController!.scene)
        
        renderer?.cardboardView(cardboardView, willStartDrawing: headTransform)
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, prepareDrawFrame headTransform: GVRHeadTransform!) {
        vrController!.prepareFrame(with: headTransform);
        renderer?.cardboardView(cardboardView, prepareDrawFrame: headTransform)
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, draw eye: GVREye, with headTransform: GVRHeadTransform!) {
        renderer?.cardboardView(cardboardView, draw: eye, with: headTransform);
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, shouldPauseDrawing pause: Bool) {
        renderLoop?.paused = pause;
    }
    
    func cardboardView(_ cardboardView: GVRCardboardView!, didFire event: GVRUserEvent) {

        if event == GVRUserEvent.trigger {
            vrController!.eventTriggered();
        }
    }

}

