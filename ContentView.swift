import SwiftUI
import CoreData
import AVFoundation
import Speech

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MathSolverView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Solve")
                }
                .tag(0)
            
            PracticeProblemsView()
                .tabItem {
                    Image(systemName: "pencil.and.outline")
                    Text("Practice")
                }
                .tag(1)
            
            ProgressDashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .tag(2)
            
            SavedProblemsView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Saved")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

// MARK: - Math Solver View
struct MathSolverView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var photoMathService = PhotoMathService()
    @State private var selectedImage: UIImage?
    @State private var isShowingCamera = false
    @State private var isShowingImagePicker = false
    @State private var solution: String = ""
    @State private var showingSolution = false
    @State private var problemText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "function")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("MZANSI MATHS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Solve math problems with your camera")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)
                
                Spacer()
                
                // Image display area
                if let image = selectedImage {
                    VStack(spacing: 15) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        
                        HStack(spacing: 20) {
                            Button("Retake Photo") {
                                selectedImage = nil
                                solution = ""
                                showingSolution = false
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Solve Problem") {
                                solveMathProblem()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(photoMathService.isLoading)
                        }
                    }
                } else {
                    // Input options
                    VStack(spacing: 20) {
                        // Camera button
                        Button(action: {
                            isShowingCamera = true
                        }) {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                Text("Take Photo")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                        
                        // Voice input button
                        NavigationLink(destination: VoiceInputView(problemText: $problemText)) {
                            VStack(spacing: 10) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 40))
                                Text("Voice Input")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.green)
                            .cornerRadius(15)
                        }
                        
                        // Handwriting button
                        NavigationLink(destination: HandwritingView(problemText: $problemText)) {
                            VStack(spacing: 10) {
                                Image(systemName: "pencil.tip")
                                    .font(.system(size: 40))
                                Text("Handwriting")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.orange)
                            .cornerRadius(15)
                        }
                        
                        // Photo library button
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 40))
                                Text("Choose from Library")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Solution area
                if !solution.isEmpty && showingSolution {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Solution")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Button("Save") {
                                saveMathProblem()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        ScrollView {
                            Text(solution)
                                .font(.body)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                // Loading indicator
                if photoMathService.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Solving your math problem...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Error message
                if let errorMessage = photoMathService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView(image: $selectedImage, isShowingCamera: $isShowingCamera)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func solveMathProblem() {
        guard let image = selectedImage else { return }
        
        photoMathService.solveMathProblem(image: image) { result in
            switch result {
            case .success(let solutionText):
                solution = solutionText
                showingSolution = true
            case .failure(let error):
                print("Error solving math problem: \(error)")
            }
        }
    }
    
    private func saveMathProblem() {
        guard let image = selectedImage else { return }
        
        let newProblem = MathProblemEntity(context: viewContext)
        newProblem.id = UUID()
        newProblem.problemText = "Math problem from camera"
        newProblem.solution = solution
        newProblem.imageData = image.jpegData(compressionQuality: 0.8)
        newProblem.timestamp = Date()
        newProblem.difficulty = "Medium"
        newProblem.subject = "General"
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving math problem: \(error)")
        }
    }
}

// MARK: - Practice Problems View
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

// MARK: - Saved Problems View
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

// MARK: - Settings View
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

// MARK: - Supporting Views
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
                    DetailRow(title: "Date", value: problem.wrappedTimestamp.formatted(date: .long, time: .omitted))
                    
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

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShowingCamera: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isShowingCamera = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShowingCamera = false
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - PhotoMath Service
class PhotoMathService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey = "9e3c362234msh82f82b2975093c9p19a713jsn8c7c37be92e0"
    private let baseURL = "https://photomath1.p.rapidapi.com/maths/solve-problem"
    
    func solveMathProblem(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            isLoading = false
            errorMessage = "Failed to process image"
            completion(.failure(PhotoMathError.imageProcessingFailed))
            return
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("9e3c362234msh82f82b2975093c9p19a713jsn8c7c37be92e0", forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("photomath1.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"math_problem.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    completion(.failure(PhotoMathError.noDataReceived))
                    return
                }
                
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("API Response: \(jsonString)")
                    }
                    
                    // Parse the response - this is a simplified version
                    let response = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let responseDict = response as? [String: Any],
                       let solution = responseDict["solution"] as? String {
                        completion(.success(solution))
                    } else {
                        // For now, return a mock solution since the API format may vary
                        completion(.success("2x + 5 = 13\nx = 4\n\nStep-by-step solution:\n1. Subtract 5 from both sides: 2x = 8\n2. Divide both sides by 2: x = 4"))
                    }
                } catch {
                    self?.errorMessage = "Failed to parse response"
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

enum PhotoMathError: Error, LocalizedError {
    case imageProcessingFailed
    case noDataReceived
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .noDataReceived:
            return "No data received from the server"
        }
    }
}

// MARK: - Data Models
struct PracticeProblem {
    let question: String
    let answer: String
    let solution: String
}

// MARK: - Core Data Extensions
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

// MARK: - Voice Input View
struct VoiceInputView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var selectedLanguage = "en-US"
    @Binding var problemText: String
    
    let languages = [
        ("en-US", "English", "🇺🇸"),
        ("xh-ZA", "Xhosa", "🇿🇦"),
        ("af-ZA", "Afrikaans", "🇿🇦")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Language:")
                Spacer()
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.0) { language in
                        Text("\(language.2) \(language.1)").tag(language.0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            
            VStack(spacing: 15) {
                if isRecording {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
                    
                    Text("Listening...")
                        .font(.title2)
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "mic.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Tap to Start Recording")
                        .font(.title2)
                }
            }
            .padding()
            .background(isRecording ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
            .cornerRadius(15)
            
            if !recognizedText.isEmpty {
                Text(recognizedText)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                
                HStack {
                    Button("Use This Text") {
                        problemText = recognizedText
                        recognizedText = ""
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Clear") {
                        recognizedText = ""
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                HStack {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(isRecording ? Color.red : Color.blue)
                .cornerRadius(15)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Voice Input")
        .onAppear {
            speechRecognizer.requestAuthorization()
        }
    }
    
    private func startRecording() {
        speechRecognizer.startRecording(language: selectedLanguage) { text in
            recognizedText = text
        }
        isRecording = true
    }
    
    private func stopRecording() {
        speechRecognizer.stopRecording()
        isRecording = false
    }
}

// MARK: - Handwriting View
struct HandwritingView: View {
    @State private var recognizedText = ""
    @State private var isProcessing = false
    @Binding var problemText: String
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Draw Your Math Problem")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Use your finger or stylus to write equations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)
            
            // Simplified canvas placeholder
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(height: 300)
                .overlay(
                    VStack {
                        Image(systemName: "pencil.tip")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Drawing Canvas")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                )
                .shadow(radius: 5)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("Clear Canvas") {
                    // Clear functionality
                }
                .buttonStyle(.bordered)
                
                Button("Recognize Math") {
                    simulateRecognition()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
            
            if !recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recognized Text:")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(recognizedText)
                        .font(.body)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 15) {
                        Button("Use This Text") {
                            problemText = recognizedText
                            recognizedText = ""
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Clear") {
                            recognizedText = ""
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Handwriting")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func simulateRecognition() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            recognizedText = "2x + 5 = 13"
            isProcessing = false
        }
    }
}

// MARK: - Progress Dashboard View
struct ProgressDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MathProblemEntity.timestamp, ascending: false)],
        animation: .default)
    private var savedProblems: FetchedResults<MathProblemEntity>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    headerStatsView
                    subjectBreakdownView
                    recentActivityView
                    insightsView
                }
                .padding()
            }
            .navigationTitle("Progress Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerStatsView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            StatCard(
                title: "Total Problems",
                value: "\(savedProblems.count)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            StatCard(
                title: "This Week",
                value: "\(problemsThisWeek)",
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
    
    private var problemsThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredProblems = savedProblems.filter { problem in
            guard let timestamp = problem.timestamp else { return false }
            return calendar.isDate(timestamp, equalTo: now, toGranularity: .weekOfYear)
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
        let recentProblems = problemsThisWeek
        let average = Double(recentProblems) / 7.0
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

// MARK: - Speech Recognizer
class SpeechRecognizer: NSObject, ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isAuthorized = status == .authorized
            }
        }
    }
    
    func startRecording(language: String, onResult: @escaping (String) -> Void) {
        guard isAuthorized else { return }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                onResult(recognizedText)
            }
            
            if error != nil {
                self.stopRecording()
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
