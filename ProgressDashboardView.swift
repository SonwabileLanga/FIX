import SwiftUI

struct ProgressDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MathProblemEntity.timestamp, ascending: false)],
        animation: .default)
    private var savedProblems: FetchedResults<MathProblemEntity>
    
    @State private var selectedTimeFrame = "Week"
    
    let timeFrames = ["Week", "Month", "Year"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header Stats
                    headerStatsView
                    
                    // Subject Breakdown
                    subjectBreakdownView
                    
                    // Recent Activity
                    recentActivityView
                    
                    // Insights
                    insightsView
                }
                .padding()
            }
            .navigationTitle("Progress Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Stats
    private var headerStatsView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            StatCard(
                title: "Total Problems",
                value: "\(savedProblems.count)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            StatCard(
                title: "This \(selectedTimeFrame.lowercased())",
                value: "\(problemsInTimeFrame)",
                icon: "calendar",
                color: .green
            )
            
            StatCard(
                title: "Success Rate",
                value: "85%",
                icon: "checkmark.circle.fill",
                color: .orange
            )
            
            StatCard(
                title: "Study Streak",
                value: "7 days",
                icon: "flame.fill",
                color: .red
            )
        }
    }
    
    // MARK: - Subject Breakdown
    private var subjectBreakdownView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Subject Performance")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(subjectPerformance, id: \.subject) { performance in
                    SubjectPerformanceCard(performance: performance)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(15)
    }
    
    // MARK: - Recent Activity
    private var recentActivityView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(Array(savedProblems.prefix(5)), id: \.id) { problem in
                RecentActivityRow(problem: problem)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(15)
    }
    
    // MARK: - Insights
    private var insightsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Learning Insights")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                InsightRow(
                    icon: "lightbulb.fill",
                    title: "Best Subject",
                    description: "You're excelling in \(bestSubject) with \(bestSubjectScore) problems solved",
                    color: .yellow
                )
                
                InsightRow(
                    icon: "target",
                    title: "Focus Area",
                    description: "Consider practicing more \(weakestSubject) problems",
                    color: .orange
                )
                
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress Trend",
                    description: "You're solving \(progressTrend) problems per day on average",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(15)
    }
    
    // MARK: - Computed Properties
    private var problemsInTimeFrame: Int {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredProblems = savedProblems.filter { problem in
            guard let timestamp = problem.timestamp else { return false }
            
            switch selectedTimeFrame {
            case "Week":
                return calendar.isDate(timestamp, equalTo: now, toGranularity: .weekOfYear)
            case "Month":
                return calendar.isDate(timestamp, equalTo: now, toGranularity: .month)
            case "Year":
                return calendar.isDate(timestamp, equalTo: now, toGranularity: .year)
            default:
                return false
            }
        }
        
        return filteredProblems.count
    }
    
    private var subjectPerformance: [SubjectPerformance] {
        let subjects = ["Algebra", "Geometry", "Calculus", "Trigonometry", "Statistics"]
        
        return subjects.map { subject in
            let count = savedProblems.filter { $0.subject == subject }.count
            let percentage = savedProblems.isEmpty ? 0 : (count * 100) / savedProblems.count
            return SubjectPerformance(subject: subject, problemsSolved: count, percentage: percentage)
        }
    }
    
    private var bestSubject: String {
        subjectPerformance.max(by: { $0.problemsSolved < $1.problemsSolved })?.subject ?? "Algebra"
    }
    
    private var bestSubjectScore: Int {
        subjectPerformance.max(by: { $0.problemsSolved < $1.problemsSolved })?.problemsSolved ?? 0
    }
    
    private var weakestSubject: String {
        subjectPerformance.min(by: { $0.problemsSolved < $1.problemsSolved })?.subject ?? "Statistics"
    }
    
    private var progressTrend: String {
        let recentProblems = problemsInTimeFrame
        let timeFrameDays = selectedTimeFrame == "Week" ? 7 : selectedTimeFrame == "Month" ? 30 : 365
        let average = Double(recentProblems) / Double(timeFrameDays)
        return String(format: "%.1f", average)
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(15)
    }
}

struct SubjectPerformanceCard: View {
    let performance: SubjectPerformance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(performance.subject)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("\(performance.problemsSolved) problems")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: Double(performance.percentage), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            Text("\(performance.percentage)%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(10)
    }
}

struct RecentActivityRow: View {
    let problem: MathProblemEntity
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(problem.wrappedProblemText)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(problem.wrappedTimestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(problem.wrappedSubject)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Data Models
struct SubjectPerformance {
    let subject: String
    let problemsSolved: Int
    let percentage: Int
}
