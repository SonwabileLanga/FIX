//
//  IssueDetailView.swift
//  FixMosselBay
//
//  Created by mac on 2025/08/28.
//

import SwiftUI
import MapKit

struct IssueDetailView: View {
    let issue: Issue
    @State private var region: MKCoordinateRegion
    
    init(issue: Issue) {
        self.issue = issue
        let coordinate = CLLocationCoordinate2D(
            latitude: issue.latitude,
            longitude: issue.longitude
        )
        self._region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with status
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(issue.category ?? "Unknown Issue")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        StatusBadge(status: issue.status ?? "Unknown")
                    }
                    
                    if let trackingId = issue.trackingId {
                        Text("Tracking ID: \(trackingId)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Description
                if let description = issue.descriptionText, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Photo
                if let photoData = issue.photoData, let uiImage = UIImage(data: photoData) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo")
                            .font(.headline)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Location Map
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                    
                    Map(coordinateRegion: $region, annotationItems: [issue]) { issue in
                        MapMarker(coordinate: CLLocationCoordinate2D(
                            latitude: issue.latitude,
                            longitude: issue.longitude
                        ), tint: .red)
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.red)
                        Text("Lat: \(issue.latitude, specifier: "%.6f"), Lon: \(issue.longitude, specifier: "%.6f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Status History
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status History")
                        .font(.headline)
                    
                    if let statusUpdates = issue.statusUpdates?.allObjects as? [StatusUpdate],
                       !statusUpdates.isEmpty {
                        let sortedUpdates = statusUpdates.sorted { 
                            ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) 
                        }
                        
                        ForEach(sortedUpdates, id: \.id) { update in
                            StatusUpdateRow(update: update)
                        }
                    } else {
                        Text("No status updates available")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Timestamps
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timestamps")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Reported")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(issue.createdAt ?? Date(), style: .date)
                                .font(.body)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Last Updated")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(issue.updatedAt ?? Date(), style: .date)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Issue Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatusUpdateRow: View {
    let update: StatusUpdate
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(update.status ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let message = update.message, !message.isEmpty {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(update.createdAt ?? Date(), style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Make Issue conform to Identifiable for Map
extension Issue: Identifiable {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct IssueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let issue = Issue(context: context)
        issue.id = UUID()
        issue.category = "Pothole"
        issue.descriptionText = "Large pothole on Main Street"
        issue.trackingId = "ABC12345"
        issue.status = "Logged"
        issue.createdAt = Date()
        issue.updatedAt = Date()
        issue.latitude = -34.1833
        issue.longitude = 22.1333
        
        return NavigationView {
            IssueDetailView(issue: issue)
        }
        .environment(\.managedObjectContext, context)
    }
}
