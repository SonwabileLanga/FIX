//
//  SettingsView.swift
//  FixMosselBay
//
//  Created by mac on 2025/08/28.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("autoLocation") private var autoLocation = true
    @AppStorage("appVersion") private var appVersion = "1.0.0"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Push Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Text("You'll receive updates when your reported issues change status")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Location Services")) {
                    Toggle("Auto-capture Location", isOn: $autoLocation)
                    
                    if autoLocation {
                        Text("Automatically capture your location when reporting issues")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Support")) {
                    Button("How to Report Issues") {
                        // Show help modal
                    }
                    
                    Button("Privacy Policy") {
                        // Show privacy policy
                    }
                    
                    Button("Terms of Service") {
                        // Show terms
                    }
                    
                    Button("Contact Support") {
                        // Open email or contact form
                    }
                }
                
                Section(header: Text("Data")) {
                    Button("Export My Data") {
                        // Export functionality
                    }
                    
                    Button("Clear All Data") {
                        // Clear data with confirmation
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Municipal Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mossel Bay Municipality")
                            .font(.headline)
                        
                        Text("Emergency: 044 606 5000")
                            .font(.body)
                        
                        Text("Email: info@mosselbay.gov.za")
                            .font(.body)
                        
                        Text("Website: www.mosselbay.gov.za")
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
