import SwiftUI
import Speech
import AVFoundation

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
            // Language Selection
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
            
            // Voice Input Display
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
            
            // Recognized Text
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
            
            // Control Button
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
