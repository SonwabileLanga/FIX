import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MathSolverView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Solve")
                }
            
            PracticeProblemsView()
                .tabItem {
                    Image(systemName: "pencil.and.outline")
                    Text("Practice")
                }
            
            SavedProblemsView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
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

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("MZANSI MATHS")
                                .font(.headline)
                            Text("Math Learning App")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    HStack {
                        Text("User Name")
                        Spacer()
                        TextField("Enter your name", text: $userName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("MZANSI MATHS Team")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("API Provider")
                        Spacer()
                        Text("PhotoMath")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Support")) {
                    Button("Rate the App") {
                        // App Store rating logic
                    }
                    
                    Button("Send Feedback") {
                        // Feedback logic
                    }
                    
                    Button("Privacy Policy") {
                        // Privacy policy logic
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
