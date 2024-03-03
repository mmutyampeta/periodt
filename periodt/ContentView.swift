//
//  ContentView.swift
//  PeriodTracker
//
//  Created by Mihir Mutyampeta on 3/3/24.
//

import SwiftUI
import LocalAuthentication
import OneFingerRotation

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

struct ContentView: View {
    @State private var isFaceIDApproved = false
    @State private var authenticationMessage = ""
    @State private var totalAngle: Double = 0.0

    var sz: CGFloat = 250
    
    var body: some View {
        VStack {
            if isFaceIDApproved {
                // Render content if Face ID is approved
                renderContent()
            } else {
                Text("Please wait while we authenticate your identity...")
                    .padding()
                    .onAppear {
                        authenticateWithFaceID()
                    }
                
                
                // Button to initiate authentication
//                Button(action: {
//                    authenticateWithFaceID()
//                }) {
//                    Text("Log In")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding()
//
                //Display authentication message
                Text(authenticationMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }.navigationTitle("Welcome to Periodt!")
    }

    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID to access your account"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Face ID validation successful
                        self.isFaceIDApproved = true
                        self.authenticationMessage = "Authentication Successful"
                    } else {
                        // Face ID validation failed or user cancelled
                        if let error = authenticationError {
                            self.authenticationMessage = "Authentication Failed: \(error.localizedDescription)"
                        } else {
                            self.authenticationMessage = "Authentication Failed"
                        }
                    }
                }
            }
        } else {
            // Device doesn't support biometric authentication or user hasn't set up biometric authentication
            self.authenticationMessage = "Biometric authentication not available"
        }
    }

    func renderContent() -> some View {
        // Content to be rendered after successful authentication
        let date = Date()
        
        return VStack {
            Spacer()
                .frame(height: 10)
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: VerticalAlignment.bottom, spacing: 10) {
                        Capsule()
                            .frame(width:60, height:80)
                        Capsule()
                            .frame(width:60, height:80)
                        Capsule()
                            .frame(width:60, height:80)
                        Capsule()
                            .frame(width:60, height:80)
                        Capsule()
                            .frame(width:60, height:100)
                        Capsule()
                            .frame(width:60, height:80)
                        Capsule()
                            .frame(width:60, height:80)
                        Capsule()
                            .frame(width:60, height:80)
                        Capsule()
                            .frame(width:60, height:80)
                        
                    }
                    .frame(width: geometry.size.width)
                }
            }.frame(height: 0)
            Spacer()

            Triangle()
                .frame(width: 30, height: 20)
                .offset(y: 12.5)
                .zIndex(2)
            ZStack {
                ZStack {
                    Circle()
                        .trim(from: 0.0, to: 0.12)
                        .stroke(Color.red, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: 0.165, to: 0.55)
                        .stroke(Color.green, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: 0.595, to: 0.75)
                        .stroke(Color.yellow, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: 0.795, to: 0.955)
                        .stroke(Color.brown, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                }
                .valueRotationInertia(
                    totalAngle: $totalAngle,
                    friction: .constant(0.05),
                    onAngleChanged: { newAngle in
                        totalAngle = newAngle
                    }
                  )


                VStack {
                    Text("23")
                        .font(.system(size: 36, weight: .bold))
                    Text("Aug")
                        .font(.system(size: 50, weight: .bold))
                }
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
