import SwiftUI
import PencilKit

struct HandwritingView: View {
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var drawingData: Data?
    @State private var recognizedText = ""
    @State private var isProcessing = false
    @Binding var problemText: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
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
            
            // Canvas
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 5)
                
                CanvasView(canvasView: $canvasView, toolPicker: $toolPicker)
                    .frame(height: 300)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            
            // Tool Controls
            HStack(spacing: 20) {
                Button("Clear Canvas") {
                    canvasView.drawing = PKDrawing()
                }
                .buttonStyle(.bordered)
                
                Button("Undo") {
                    if canvasView.drawing.bounds.isEmpty == false {
                        canvasView.drawing = PKDrawing()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(canvasView.drawing.bounds.isEmpty)
            }
            
            // Recognition Button
            Button(action: recognizeHandwriting) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "text.viewfinder")
                    }
                    Text(isProcessing ? "Processing..." : "Recognize Math")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(isProcessing ? Color.gray : Color.blue)
                .cornerRadius(15)
            }
            .disabled(isProcessing)
            
            // Recognized Text Display
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
        .onAppear {
            setupCanvas()
        }
    }
    
    private func setupCanvas() {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    private func recognizeHandwriting() {
        isProcessing = true
        
        // Convert drawing to image
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 2.0)
        
        // For now, we'll simulate recognition
        // In a real app, you'd send this to a handwriting recognition API
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.simulateRecognition(image: image)
        }
    }
    
    private func simulateRecognition(image: UIImage) {
        // Simulate different math problems based on drawing complexity
        let drawingBounds = canvasView.drawing.bounds
        let area = drawingBounds.width * drawingBounds.height
        
        var simulatedText = ""
        
        if area < 1000 {
            simulatedText = "x + 5 = 10"
        } else if area < 5000 {
            simulatedText = "2x² + 3x + 1 = 0"
        } else if area < 10000 {
            simulatedText = "∫(x² + 2x)dx"
        } else {
            simulatedText = "sin(θ) + cos(θ) = 1"
        }
        
        recognizedText = simulatedText
        isProcessing = false
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update view if needed
    }
}

// MARK: - PKDrawing Extension
extension PKDrawing {
    func image(from rect: CGRect, scale: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(rect)
            
            let drawingImage = self.image(from: rect, scale: scale)
            drawingImage.draw(in: rect)
        }
    }
}
