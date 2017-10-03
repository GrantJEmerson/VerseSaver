//
//  Extensions.swift
//  Bible Verse Saver
//
//  Created by Grant Emerson on 10/3/17.
//  Copyright © 2017 com.grant-emerson. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}

extension Verse {
    
    // Extension allows for quick save
    
    func save() {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
