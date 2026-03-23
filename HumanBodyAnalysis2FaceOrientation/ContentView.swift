//
//  ContentView.swift
//  HumanBodyAnalysis2FaceOrientation
//
//  Created by Quanpeng Yang on 3/22/26.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var faceOrientation: String = "Calculating..."
    let imageName = "faceleft" // The name of your image in Assets

    var body: some View {
        VStack {
            // Display the image
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
            } else {
                Text("Image '\(imageName)' not found in Assets")
                    .foregroundColor(.red)
            }

            // Display the orientation data
            Text(faceOrientation)
                .font(.system(.body, design: .monospaced))
                .padding()
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding()
        .task {
            await detectFaceOrientation()
        }
    }

    func detectFaceOrientation() async {
        // 1. Load from Assets as cgImage
        guard let uiImage = UIImage(named: imageName),
              let cgImage = uiImage.cgImage else {
            faceOrientation = "Error: Could not load image"
            return
        }

        do {
            let request = DetectFaceRectanglesRequest()
            
            // 2. Perform the request
            let observations = try await request.perform(on: cgImage, orientation: .up)

            if let observation = observations.first {
                // 3. Convert measurements to degrees
                let pitch = observation.pitch.converted(to: .degrees).value
                let yaw = observation.yaw.converted(to: .degrees).value
                let roll = observation.roll.converted(to: .degrees).value

                // Format the text output
                var text = ""
                text += "Pitch: \(Int(pitch))°\n"
                text += "Yaw:   \(Int(yaw))°\n"
                text += "Roll:  \(Int(roll))°"
                
                faceOrientation = text
            } else {
                faceOrientation = "No faces detected."
            }
        } catch {
            faceOrientation = "Error: \(error.localizedDescription)"
            print("Error performing the request: \(error)")
        }
    }
}
