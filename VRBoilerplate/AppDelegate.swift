//
//  AppDelegate.swift
//  VRBoilerplate
//
//  Created by Andrian Budantsov on 5/19/16.
//  Copyright © 2016 Andrian Budantsov. All rights reserved.
//

import UIKit

func isoDateNow() -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    return formatter.string(from: Date())
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {

    var window: UIWindow?
    var dataFile: FileHandle?
    
    func store(name: String, value: String) {
        let row = "\"\(name)\";\"\(value)\"\n"
        dataFile?.write(row.data(using: .utf8)!)
    }
    
    func store(point: Int, vote: Int) {
        let row = "\"\(point)\";\"\(vote)\"\n"
        dataFile?.write(row.data(using: .utf8)!)
    }
    
    func closeFile() {
        dataFile?.closeFile()
    }
    
    func openFile() {
        let manager = FileManager.default
        do {
            let docUrl = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            let fileUrl = docUrl.appendingPathComponent(isoDateNow() + ".csv")
            try "".data(using: .utf8)?.write(to: fileUrl)
            dataFile = try FileHandle(forWritingTo: fileUrl)
        } catch let error {
            fatalError("Failed to open data file: " + error.localizedDescription)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    // Make the navigation controller defer the check of supported orientation to its topmost view
    // controller. This allows |GVRCardboardViewController| to lock the orientation in VR mode.
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        
        return navigationController.topViewController!.supportedInterfaceOrientations
        
    }


}

