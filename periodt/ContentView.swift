//
//  ContentView.swift
//  PeriodTracker
//
//  Created by Mihir Mutyampeta on 3/3/24.
//

import SwiftUI
import LocalAuthentication
import OneFingerRotation
import SwiftData



let green = Color(red: 0.592, green: 0.847, blue: 0.616);
let blue = Color(red: 0.573, green: 0.776, blue: 0.867);
let yellow = Color(red: 0.984, green: 0.863, blue: 0.537);
let red = Color(red: 1, green: 0.361, blue: 0.447)


@available(iOS 17.0, *)
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

@available(iOS 17.0, *)
struct ContentView: View {
    @Environment(\.modelContext) var modelcontext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \userData.startDate) var data: [userData]
    

    
    @State private var isFaceIDApproved = false
    @State private var authenticationMessage = ""
    @State private var totalAngle: Double = 0.0
    @State private var date: Date = Date.now;
    @State private var lastRotations: Int = 0;
    @State private var periodArc: CGFloat = 0.0;
    @State private var ovulationArc: CGFloat = 0.0;
        
    
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
                        let cycleLen = CGFloat(data[0].cycleLen);
                        self.periodArc = CGFloat(data[0].PeriodLen) / cycleLen
                        self.ovulationArc = 4 / cycleLen
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
    
    
    @available(iOS 17.0, *)
    func renderContent() -> some View {
        // Content to be rendered after successful authentication

//        @Environment(\.modelContext) var context
//        @Environment(\.dismiss) var dismiss
        let newData = userData(startDate: Date(), cycleLen: 28, numPeriods: 0, PeriodLen: 6);
        modelcontext.insert(newData);
        
        
        dismiss();
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
                        .trim(from: 0.025, to: periodArc - 0.025)
                        .stroke(red, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: periodArc + 0.025, to: 0.475)
                        .stroke(green, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: ovulationArc + 0.525 + 0.025, to: 0.975)
                        .stroke(yellow, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: 0.525, to: 0.5  + ovulationArc)
                        .stroke(blue, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)

                }
                .valueRotationInertia(
                                    totalAngle: $totalAngle,
                                    friction: .constant(0.1),
                                    onAngleChanged: { newAngle in
                                        var rotations = Int(totalAngle / 12)
                                        
                                        if (abs(rotations - lastRotations) >= 30) {
                                            if (rotations - lastRotations < 0 ) {
                                                rotations = 1
                                                lastRotations = 0
                                            } else {
                                                rotations = -1
                                                lastRotations = 0
                                            }
                                        }
                                        if (abs(rotations - lastRotations) > 1) {
                                            if (rotations - lastRotations > 0 ) {
                                                rotations = 1
                                                lastRotations = 0
                                            } else {
                                                rotations = -1
                                                lastRotations = 0
                                            }
                                        }
                                        
                                        date = Calendar.current.date(byAdding: .day, value: (rotations - lastRotations), to: date) ?? date
                                        lastRotations = rotations
                                        totalAngle = newAngle.truncatingRemainder(dividingBy: 360)

                                        
                                    }
                                  )


                VStack {
                     Text(date.formatted(.dateTime.day()))
                         .font(.system(size: 36, weight: .bold))
                     Text(date.formatted(.dateTime.month()))
                         .font(.system(size: 50, weight: .bold))
                 }
            }
            Spacer()
        }
    }
}

@available(iOS 17.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
