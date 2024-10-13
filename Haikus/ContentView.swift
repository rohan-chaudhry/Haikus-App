//
//  ContentView.swift
//  Haikus
//
//
import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var textField1: String = ""
    @State private var textField2: String = ""
    @State private var textField3: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack {
            // Gray square with image or text
            Rectangle()
                .fill(Color.gray)
                .frame(maxWidth: UIScreen.main.bounds.width / (2/3), maxHeight: UIScreen.main.bounds.height / 3)
                .overlay(
                    Group {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit() // Keeps the aspect ratio without cropping
                        } else {
                            Text("Tap to upload image")
                                .foregroundColor(.white)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                    }
                )
                .onTapGesture {
                    isImagePickerPresented = true
                }

            // Text fields with syllable count
            VStack(spacing: 16) {
                HStack {
                    TextField("Enter text 1", text: $textField1)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Text("\(countSyllables(textField1))")
                        .frame(width: 30, alignment: .leading)
                }

                HStack {
                    TextField("Enter text 2", text: $textField2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Text("\(countSyllables(textField2))")
                        .frame(width: 30, alignment: .leading)
                }

                HStack {
                    TextField("Enter text 3", text: $textField3)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Text("\(countSyllables(textField3))")
                        .frame(width: 30, alignment: .leading)
                }
            }
            .padding(.top, 20)

            // Publish button
            Button(action: {
                // Print the content of the text fields
                print("Text Field 1: \(textField1)")
                print("Text Field 2: \(textField2)")
                print("Text Field 3: \(textField3)")
            }) {
                Text("Publish!")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker { image in
                self.selectedImage = image
                self.isImagePickerPresented = false // Dismiss the picker after selection
            }
        }
    }

    // Function to count syllables in a given string
    private func countSyllables(_ text: String) -> Int {
        let syllableCount = text
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .flatMap { $0.components(separatedBy: CharacterSet.punctuationCharacters) }
            .compactMap { $0 }
            .reduce(0) { $0 + countSyllablesInWord($1) }
        return syllableCount
    }

    private func countSyllablesInWord(_ word: String) -> Int {
        let vowels = "aeiouy"
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedWord.isEmpty else { return 0 }

        var syllableCount = 0
        var isLastCharAVowel = false

        for char in trimmedWord {
            if vowels.contains(char) {
                if !isLastCharAVowel {
                    syllableCount += 1
                }
                isLastCharAVowel = true
            } else {
                isLastCharAVowel = false
            }
        }

        // Adjust for silent 'e' at the end of the word
        if trimmedWord.hasSuffix("e") {
            syllableCount = max(syllableCount - 1, 0)
        }

        return syllableCount
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first else { return }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self?.parent.onImagePicked(image)
                        }
                    }
                }
            }
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



/*
 
 Bitter cold bites me
 Walking along the coastline
 Will warmth find cold souls
 
 
 */
