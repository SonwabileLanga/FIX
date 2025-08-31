import Foundation
import CoreData

struct MathProblem: Identifiable, Codable {
    let id = UUID()
    let problemText: String
    let solution: String
    let imageData: Data?
    let timestamp: Date
    let difficulty: String
    let subject: String
    
    init(problemText: String, solution: String, imageData: Data? = nil, difficulty: String = "Medium", subject: String = "General") {
        self.problemText = problemText
        self.solution = solution
        self.imageData = imageData
        self.timestamp = Date()
        self.difficulty = difficulty
        self.subject = subject
    }
}

// Core Data Entity
extension MathProblemEntity {
    var wrappedProblemText: String {
        problemText ?? "Unknown Problem"
    }
    
    var wrappedSolution: String {
        solution ?? "No solution available"
    }
    
    var wrappedDifficulty: String {
        difficulty ?? "Medium"
    }
    
    var wrappedSubject: String {
        subject ?? "General"
    }
    
    var wrappedTimestamp: Date {
        timestamp ?? Date()
    }
}
