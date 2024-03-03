//
//  periodtApp.swift
//  periodt
//
//  Created by Mihir Mutyampeta on 3/3/24.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
@main
struct periodtApp: App {
//    let container: ModelContainer = {
//        let schema = Schema([userData.self])
//        let container = try! ModelContainer(for: schema, configurations: [])
//        return container
//    } ()
//    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: userData.self)
    }
}
