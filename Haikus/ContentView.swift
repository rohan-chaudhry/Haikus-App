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

    var body: some View {
        VStack {
            // Gray square --> img container
            Rectangle()
                .fill(Color.gray)
                .frame(
                    maxWidth: UIScreen.main.bounds.width / (3/5),
                    maxHeight: UIScreen.main.bounds.height / 3,
                    alignment: .center
                )
                .overlay(
                                   Text("Tap to upload image")
                                       .foregroundColor(.white)
                                       .font(.headline)
                                       .multilineTextAlignment(.center)
                               )
            
            // Text fields for haiku lines
            VStack(spacing: 16) {
                TextField("Enter text 1", text: $textField1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 50)
                
                TextField("Enter text 2", text: $textField2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 50)
                
                TextField("Enter text 3", text: $textField3)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 50)
            }
            // TODO: add syllable count next to each line, gray text color; if over 5/7/5, then become burnt orange
            
            .padding(.top, 10)

            // Publish button
            Button(action: {
                // Action for publish button
                print("\(textField1)\n\(textField2)\n\(textField3)")

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
