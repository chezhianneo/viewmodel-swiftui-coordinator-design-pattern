//
//  DetailView.swift
//  movie
//
//  Created by Elan Arulraj on 7/6/25.
//

import SwiftUI


struct DetailView: View {
    @State private var typedText = ""  // The text to display (revealed character by character)
    @State private var currentIndex = 0 // Index to keep track of which character to show
    @State private var fullText = "Hello! How can I assist you today?"
    
    // Timer to update the text character by character
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack {
            // Display the typed text with the typewriter effect
            Text(typedText)
                .font(.title)
                .padding()
                .animation(.easeInOut, value: 0.2)
                    // Add animation for smoothness
            Spacer()
            
            // Button to start typing animation
            Button("Start Typing") {
                startTypingAnimation()
            }
            .padding()
            
            // Button to override the text (simulate  changing message)
            Button("Override Text") {
                // Override the text with new content
                overrideText(newText: "New message coming in!")
            }
            .padding()
        }
        .onAppear {
            startTypingAnimation() // Automatically start typing animation when the view appears
        }
        .navigationTitle("Chat Simulation")
    }
    
    // Function to start the typing animation
    func startTypingAnimation() {
        typedText = ""  // Reset the typed text
        currentIndex = 0  // Reset the index to start from the beginning
        
        // Stop any previous timer to prevent multiple animations running at once
        timer?.invalidate()
        
        // Set up a timer to reveal text one character at a time
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if currentIndex < fullText.count {
                // Append the next character to the text
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                typedText += String(fullText[index])
                currentIndex += 1
            } else {
                // Stop the timer once the full text is revealed
                timer.invalidate()
            }
        }
    }
        
    // Function to override the text with a new string
    func overrideText(newText: String) {
        fullText = newText  // Update the fullText with new content
        startTypingAnimation()  // Start the typing animation with the new content
    }
}
