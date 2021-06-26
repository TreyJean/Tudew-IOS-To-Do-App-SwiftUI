//
//  TudewApp.swift
//  Tudew
//
//  Created by Trey Jean-Baptiste on 6/24/21.
//

import SwiftUI

@main
struct TudewApp: App {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }.onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            
            case .background:
                print("Scene is in the Background")
                persistenceController.save()
            case .inactive:
                print("Scene is Inactive")
            case .active:
                print("Scene is Active")
            @unknown default:
                print("Apple Must Have Changed Something")
            }
        }
    }
}
