//
//  MapView.swift
//  FixMosselBay
//
//  Created by mac on 2025/08/28.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var locationManager = LocationManager()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Issue.createdAt, ascending: false)],
        animation: .default)
    private var issues: FetchedResults<Issue>
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -34.1833, longitude: 22.1333), // Mossel Bay coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedIssue: Issue?
    @State private var showingIssueDetail = false
    @State private var selectedCategoryFilter = "All"
    
    private let categories = ["All", "Pothole", "Water Leak", "Streetlight", "Illegal Dumping", "Power Outage"]
    
    var filteredIssues: [Issue] {
        if selectedCategoryFilter == "All" {
            return Array(issues)
        } else {
            return issues.filter { $0.category == selectedCategoryFilter }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategoryFilter = category
                                centerMapOnIssues()
                            }) {
                                Text(category)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategoryFilter == category ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedCategoryFilter == category ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Map
                Map(coordinateRegion: $region, annotationItems: filteredIssues) { issue in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: issue.latitude,
                        longitude: issue.longitude
                    )) {
                        IssueMapMarker(issue: issue) {
                            selectedIssue = issue
                            showingIssueDetail = true
                        }
                    }
                }
                .onTapGesture {
                    selectedIssue = nil
                }
            }
            .navigationTitle("Issue Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Center") {
                        centerMapOnIssues()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("My Location") {
                        centerOnUserLocation()
                    }
                }
            }
            .sheet(isPresented: $showingIssueDetail) {
                if let issue = selectedIssue {
                    NavigationView {
                        IssueDetailView(issue: issue)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showingIssueDetail = false
                                    }
                                }
                            }
                    }
                }
            }
            .onAppear {
                centerMapOnIssues()
            }
        }
    }
    
    private func centerMapOnIssues() {
        guard !filteredIssues.isEmpty else { return }
        
        let coordinates = filteredIssues.map { issue in
            CLLocationCoordinate2D(latitude: issue.latitude, longitude: issue.longitude)
        }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? -34.1833
        let maxLat = coordinates.map { $0.latitude }.max() ?? -34.1833
        let minLon = coordinates.map { $0.longitude }.min() ?? 22.1333
        let maxLon = coordinates.map { $0.longitude }.max() ?? 22.1333
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let spanLat = max(maxLat - minLat, 0.01)
        let spanLon = max(maxLon - minLon, 0.01)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(latitudeDelta: spanLat * 1.2, longitudeDelta: spanLon * 1.2)
            )
        }
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation(.easeInOut(duration: 0.5)) {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        } else {
            locationManager.requestLocation()
        }
    }
}

struct IssueMapMarker: View {
    let issue: Issue
    let onTap: () -> Void
    
    var statusColor: Color {
        switch issue.status {
        case "Logged":
            return .blue
        case "In Progress":
            return .orange
        case "Resolved":
            return .green
        default:
            return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(statusColor)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 3)
                
                Text(issue.category ?? "Unknown")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemBackground))
                    .clipShape(Capsule())
                    .shadow(radius: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryIcon: String {
        switch issue.category {
        case "Pothole":
            return "car.fill"
        case "Water Leak":
            return "drop.fill"
        case "Streetlight":
            return "lightbulb.fill"
        case "Illegal Dumping":
            return "trash.fill"
        case "Power Outage":
            return "bolt.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
