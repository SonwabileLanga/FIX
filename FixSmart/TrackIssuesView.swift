//
//  TrackIssuesView.swift
//  FixMosselBay
//
//  Created by mac on 2025/08/28.
//

import SwiftUI

struct TrackIssuesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Issue.createdAt, ascending: false)],
        animation: .default)
    private var issues: FetchedResults<Issue>
    
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    private let statusFilters = ["All", "Logged", "In Progress", "Resolved"]
    
    var filteredIssues: [Issue] {
        let filtered = issues.filter { issue in
            if searchText.isEmpty { return true }
            return (issue.category?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                   (issue.descriptionText?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                   (issue.trackingId?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        if selectedFilter == "All" {
            return filtered
        } else {
            return filtered.filter { $0.status == selectedFilter }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Picker
                Picker("Status Filter", selection: $selectedFilter) {
                    ForEach(statusFilters, id: \.self) { filter in
                        Text(filter).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if filteredIssues.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No issues found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        if issues.isEmpty {
                            Text("Start by reporting your first issue")
                                .foregroundColor(.gray)
                        } else {
                            Text("Try adjusting your search or filters")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredIssues, id: \.id) { issue in
                            NavigationLink(destination: IssueDetailView(issue: issue)) {
                                IssueRowView(issue: issue)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search issues...")
                }
            }
            .navigationTitle("Track Issues")
        }
    }
}

struct IssueRowView: View {
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(issue.category ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(issue.trackingId ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: issue.status ?? "Unknown")
            }
            
            if let description = issue.descriptionText, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text(issue.createdAt ?? Date(), style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let photoData = issue.photoData {
                    Image(systemName: "photo")
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status {
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
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .clipShape(Capsule())
    }
}

struct TrackIssuesView_Previews: PreviewProvider {
    static var previews: some View {
        TrackIssuesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
