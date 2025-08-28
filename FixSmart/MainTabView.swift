//
//  MainTabView.swift
//  FixMosselBay
//
//  Created by mac on 2025/08/28.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ReportIssueView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Report Issue")
                }
            
            TrackIssuesView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Track Issues")
                }
            
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
