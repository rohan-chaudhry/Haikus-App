//
//  ContentView.swift
//  Haikus
//
// future reference - https://arkumari2000.medium.com/clicking-or-uploading-pictures-in-ios-983084ab40ed
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
                    syllableCountColor(for: textField1, maxCount: 5)
                        .frame(width: 30, alignment: .leading)
                }

                HStack {
                    TextField("Enter text 2", text: $textField2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    syllableCountColor(for: textField2, maxCount: 7)
                        .frame(width: 30, alignment: .leading)
                }

                HStack {
                    TextField("Enter text 3", text: $textField3)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    syllableCountColor(for: textField3, maxCount: 5)
                        .frame(width: 30, alignment: .leading)
                }
            }
            .padding(.top, 20)

            // Publish button
            Button(action: {
                saveImageWithText()
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

    private func saveImageWithText() {
        guard let image = selectedImage else { return }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 400))
        let combinedImage = renderer.image { context in
            // Draw the selected image
            image.draw(in: CGRect(x: 0, y: 0, width: 300, height: 200))

            // Draw the text fields below the image, format it with a rupi kaur vibe
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]

            let text1 = textField1 as NSString
            text1.draw(in: CGRect(x: 10, y: 210, width: 280, height: 20), withAttributes: textAttributes)

            let text2 = textField2 as NSString
            text2.draw(in: CGRect(x: 50, y: 240, width: 280, height: 20), withAttributes: textAttributes)

            let text3 = textField3 as NSString
            text3.draw(in: CGRect(x: 100, y: 270, width: 280, height: 20), withAttributes: textAttributes)
        }
        
        // actually save the image onto photos app
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: combinedImage)
       //  UIImageWriteToSavedPhotosAlbum(combinedImage, nil, nil, nil)

        
        /*
         // commenting out the controller to export to Photos, Messages, etc.

         // Present share sheet to save or message the image
         let activityViewController = UIActivityViewController(activityItems: [combinedImage], applicationActivities: nil)

        // Optional: Exclude specific activity types if necessary
        // activityViewController.excludedActivityTypes = [UIActivity.ActivityType.saveToCameraRoll]

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
         */
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
    private func syllableCountColor(for text: String, maxCount: Int) -> some View {
        let count = countSyllables(text)
        let color: Color = (textField1 == text || textField3 == text) && count > maxCount || textField2 == text && count > maxCount ? .orange : .gray
        return Text("\(count)").foregroundColor(color)
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
