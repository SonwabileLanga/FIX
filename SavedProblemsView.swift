import SwiftUI
import CoreData

struct SavedProblemsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MathProblemEntity.timestamp, ascending: false)],
        animation: .default)
    private var savedProblems: FetchedResults<MathProblemEntity>
    
    var body: some View {
        NavigationView {
            List {
                if savedProblems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No saved problems yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Take photos of math problems to see them here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(savedProblems) { problem in
                        NavigationLink(destination: ProblemDetailView(problem: problem)) {
                            SavedProblemRow(problem: problem)
                        }
                    }
                    .onDelete(perform: deleteProblems)
                }
            }
            .navigationTitle("Saved Problems")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func deleteProblems(offsets: IndexSet) {
        withAnimation {
            offsets.map { savedProblems[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting problem: \(error)")
            }
        }
    }
}

struct SavedProblemRow: View {
    let problem: MathProblemEntity
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageData = problem.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "doc.text")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(problem.wrappedProblemText)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(problem.wrappedSubject)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Text(problem.wrappedTimestamp, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(problem.wrappedDifficulty)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

struct ProblemDetailView: View {
    let problem: MathProblemEntity
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Problem image
                if let imageData = problem.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                
                // Problem details
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Problem Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                        }
                    }
                    
                    DetailRow(title: "Subject", value: problem.wrappedSubject)
                    DetailRow(title: "Difficulty", value: problem.wrappedDifficulty)
                    DetailRow(title: "Date", value: problem.wrappedTimestamp.formatted(date: .long, time: .short))
                    
                    Divider()
                    
                    Text("Solution")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(problem.wrappedSolution)
                        .font(.body)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(15)
            }
            .padding()
        }
        .navigationTitle("Problem Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [problem.wrappedSolution])
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
