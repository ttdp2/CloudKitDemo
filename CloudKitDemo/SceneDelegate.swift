//
//  SceneDelegate.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/18.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit
import CloudKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            window.rootViewController = TabViewController()
            window.makeKeyAndVisible()
            
            self.window = window
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    
        if !CloudKitManager.isNotesZoneReady {
            CloudKitManager.setUpNotesZone()
        }

        if !CloudKitManager.isNotesSubcriptionReady {
            CloudKitManager.setupNotesSubcription()
        }
        
        if !CloudKitManager.isPhotosZoneReady {
            CloudKitManager.setupPhotosZone()
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptOperation: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        
        acceptOperation.qualityOfService = .userInteractive
        acceptOperation.acceptSharesCompletionBlock = { _ in
            // go where the user need to go
            print("Here we go")
        }
        
        CKContainer.default().add(acceptOperation)
    }
    
}
