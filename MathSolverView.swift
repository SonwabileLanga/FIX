import SwiftUI
import CoreData

struct MathSolverView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var photoMathService = PhotoMathService()
    @State private var selectedImage: UIImage?
    @State private var isShowingCamera = false
    @State private var isShowingImagePicker = false
    @State private var solution: String = ""
    @State private var showingSolution = false
    
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
                    // Camera buttons
                    VStack(spacing: 20) {
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
            // Show success message or navigate to saved problems
        } catch {
            print("Error saving math problem: \(error)")
        }
    }
}

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
