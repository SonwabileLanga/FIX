//
//  ReportIssueView.swift
//  FixMosselBay
//
//  Created by mac on 2025/08/28.
//

import SwiftUI
import CoreLocation
import MapKit
import PhotosUI

struct ReportIssueView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedCategory = "Pothole"
    @State private var descriptionText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var isSubmitting = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let categories = [
        "Pothole",
        "Water Leak", 
        "Streetlight",
        "Illegal Dumping",
        "Power Outage"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Issue Details")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Location")) {
                    if let location = locationManager.location {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("Latitude: \(location.coordinate.latitude, specifier: "%.6f")")
                                    .font(.caption)
                                Text("Longitude: \(location.coordinate.longitude, specifier: "%.6f")")
                                    .font(.caption)
                            }
                        }
                        
                        Button("Update Location") {
                            locationManager.requestLocation()
                        }
                        .foregroundColor(.blue)
                    } else {
                        HStack {
                            Image(systemName: "location.slash")
                                .foregroundColor(.red)
                            Text("Location not available")
                                .foregroundColor(.red)
                        }
                        
                        Button("Enable Location") {
                            locationManager.requestLocation()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Photo")) {
                    if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button("Remove Photo") {
                            self.photoData = nil
                            self.selectedPhoto = nil
                        }
                        .foregroundColor(.red)
                    } else {
                        HStack {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Label("Select Photo", systemImage: "photo.on.rectangle")
                            }
                            
                            Spacer()
                            
                            Button("Camera") {
                                showingCamera = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                Section {
                    Button(action: submitIssue) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit Issue")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isSubmitting || descriptionText.isEmpty || locationManager.location == nil)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Report Issue")
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
            .alert("Issue Report", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitIssue() {
        guard let location = locationManager.location else { return }
        
        isSubmitting = true
        
        let newIssue = Issue(context: viewContext)
        newIssue.id = UUID()
        newIssue.trackingId = generateTrackingId()
        newIssue.category = selectedCategory
        newIssue.descriptionText = descriptionText
        newIssue.latitude = location.coordinate.latitude
        newIssue.longitude = location.coordinate.longitude
        newIssue.photoData = photoData
        newIssue.status = "Logged"
        newIssue.createdAt = Date()
        newIssue.updatedAt = Date()
        
        // Create initial status update
        let statusUpdate = StatusUpdate(context: viewContext)
        statusUpdate.id = UUID()
        statusUpdate.status = "Logged"
        statusUpdate.message = "Issue reported successfully"
        statusUpdate.createdAt = Date()
        statusUpdate.issue = newIssue
        
        do {
            try viewContext.save()
            
            // Reset form
            descriptionText = ""
            photoData = nil
            selectedPhoto = nil
            
            alertMessage = "Issue reported successfully! Tracking ID: \(newIssue.trackingId ?? "")"
            showingAlert = true
            
        } catch {
            alertMessage = "Failed to submit issue: \(error.localizedDescription)"
            showingAlert = true
        }
        
        isSubmitting = false
    }
    
    private func generateTrackingId() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in letters.randomElement()! })
    }
}

struct ReportIssueView_Previews: PreviewProvider {
    static var previews: some View {
        ReportIssueView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
