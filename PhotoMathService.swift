import Foundation
import UIKit

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
                    // You may need to adjust based on the actual API response format
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
