import SwiftUI

struct PracticeProblemsView: View {
    @State private var selectedSubject = "Algebra"
    @State private var selectedDifficulty = "Easy"
    @State private var currentProblem: PracticeProblem?
    @State private var userAnswer = ""
    @State private var showingSolution = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var totalAttempts = 0
    
    let subjects = ["Algebra", "Geometry", "Calculus", "Trigonometry", "Statistics"]
    let difficulties = ["Easy", "Medium", "Hard"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header with score
                VStack(spacing: 10) {
                    Text("Practice Problems")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(totalAttempts)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Attempts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 20)
                
                // Subject and difficulty pickers
                HStack(spacing: 20) {
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(subjects, id: \.self) { subject in
                            Text(subject).tag(subject)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Text(difficulty).tag(difficulty)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Generate new problem button
                Button(action: generateNewProblem) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Generate New Problem")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                
                Spacer()
                
                // Problem display
                if let problem = currentProblem {
                    VStack(spacing: 20) {
                        Text("Problem")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(problem.question)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(15)
                        
                        if !showingSolution {
                            VStack(spacing: 15) {
                                TextField("Enter your answer", text: $userAnswer)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                
                                Button("Submit Answer") {
                                    checkAnswer()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(userAnswer.isEmpty)
                            }
                        } else {
                            VStack(spacing: 15) {
                                HStack {
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isCorrect ? .green : .red)
                                        .font(.title)
                                    
                                    Text(isCorrect ? "Correct!" : "Incorrect")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(isCorrect ? .green : .red)
                                }
                                
                                if !isCorrect {
                                    Text("Correct answer: \(problem.answer)")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Solution:")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(problem.solution)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(20)
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No problem generated yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Select a subject and difficulty, then generate a problem to start practicing!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 50)
                }
                
                Spacer()
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func generateNewProblem() {
        currentProblem = generateProblem(subject: selectedSubject, difficulty: selectedDifficulty)
        userAnswer = ""
        showingSolution = false
    }
    
    private func checkAnswer() {
        guard let problem = currentProblem else { return }
        
        let userAnswerDouble = Double(userAnswer) ?? 0
        let correctAnswer = Double(problem.answer) ?? 0
        
        isCorrect = abs(userAnswerDouble - correctAnswer) < 0.01
        
        if isCorrect {
            score += getScoreForDifficulty(selectedDifficulty)
        }
        
        totalAttempts += 1
        showingSolution = true
    }
    
    private func getScoreForDifficulty(_ difficulty: String) -> Int {
        switch difficulty {
        case "Easy": return 1
        case "Medium": return 2
        case "Hard": return 3
        default: return 1
        }
    }
    
    private func generateProblem(subject: String, difficulty: String) -> PracticeProblem {
        // Sample problems - in a real app, you'd have a database of problems
        let problems: [PracticeProblem] = [
            PracticeProblem(
                question: "Solve for x: 2x + 5 = 13",
                answer: "4",
                solution: "1. Subtract 5 from both sides: 2x = 8\n2. Divide both sides by 2: x = 4"
            ),
            PracticeProblem(
                question: "Find the area of a circle with radius 5",
                answer: "78.54",
                solution: "Area = πr² = π(5)² = 25π ≈ 78.54"
            ),
            PracticeProblem(
                question: "What is the derivative of x²?",
                answer: "2x",
                solution: "Using the power rule: d/dx(xⁿ) = nxⁿ⁻¹\nSo d/dx(x²) = 2x²⁻¹ = 2x"
            ),
            PracticeProblem(
                question: "Find sin(30°)",
                answer: "0.5",
                solution: "sin(30°) = 1/2 = 0.5\nThis is a standard trigonometric value."
            ),
            PracticeProblem(
                question: "Calculate the mean of: 2, 4, 6, 8, 10",
                answer: "6",
                solution: "Mean = (2+4+6+8+10)/5 = 30/5 = 6"
            )
        ]
        
        return problems.randomElement() ?? problems[0]
    }
}

struct PracticeProblem {
    let question: String
    let answer: String
    let solution: String
}
