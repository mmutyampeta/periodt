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
    @State private var runInitialForm = false
    @State private var authenticationMessage = ""
    @State private var totalAngle: Double = 0.0
    @State private var date: Date = Date.now;
    @State private var lastRotations: Int = 0;
    @State private var cycleLen: CGFloat = 0.0;
    @State private var periodArc: CGFloat = 0.0;
    @State private var ovulationArc: CGFloat = 0.0;
    @State private var firstDay: Date = Date()
    @State private var startMainPage = false
    @State private var days : Int = 0;
    @State private var text = "";
    
    
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
                
                showInitialForm(isFaceIDApproved: $isFaceIDApproved)
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
                        self.runInitialForm = true
                        self.authenticationMessage = "Authentication Successful"
                        self.cycleLen = CGFloat(data[0].cycleLen);
                        self.periodArc = CGFloat(data[0].PeriodLen) / cycleLen
                        self.ovulationArc = 4 / cycleLen
                        self.firstDay = data[0].startDate
                    } else {
                        // Face ID validation failed or user cancelled
                        if let error = authenticationError {
                            self.authenticationMessage = "Authentication Failed: \(error.localizedDescription)"
                        } else {
                            self.authenticationMessage = "Authentication Failed\n"
                        }
                    }
                }
            }
        } else {
            // Device doesn't support biometric authentication or user hasn't set up biometric authentication
            self.authenticationMessage = "Biometric authentication not available"
        }
    }
    
    struct InitialFormView: View {
        @Binding var isFaceIDApproved: Bool
        
        @State private var isOnPeriod = false
        @State private var startedPeriodToday = false
        @State private var lastPeriodStart = Date()
        @State private var showLastPeriodStart = false
        
        var body: some View {
            VStack {
                Text("Are you on your period?")
                    .padding()
                HStack {
                    Button(action: {
                        isOnPeriod = true
                    }) {
                        Text("Yes")
                    }
                    Button(action: {
                        isOnPeriod = false
                        isFaceIDApproved = true;
                    }) {
                        Text("No")
                    }
                }
                
                if isOnPeriod {
                    Text("Did you start your period today?")
                        .padding()
                    HStack {
                        Button(action: {
                            startedPeriodToday = true
                            showLastPeriodStart = false // Reset the flag
                            isFaceIDApproved = true
                        }) {
                            Text("Yes")
                        }
                        Button(action: {
                            startedPeriodToday = false
                            showLastPeriodStart = true
                        }) {
                            Text("No")
                        }
                    }
                    
                    if showLastPeriodStart {
                        Text("When did you start your period last?")
                            .padding()
                        DatePicker("Select Date", selection: $lastPeriodStart, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .padding()
                        Button(action: {
                            // Perform actions upon form submission
                            isFaceIDApproved = true // Assuming submission implies Face ID approval
                        }) {
                            Text("Submit")
                        }
                        .padding()
            
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }

    func showInitialForm(isFaceIDApproved: Binding<Bool>) -> some View {
        return InitialFormView(isFaceIDApproved: isFaceIDApproved)
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
//                        Capsule()
//                            .frame(width:60, height:80)
//                        Capsule()
//                            .frame(width:60, height:80)
//                        Capsule()
//                            .frame(width:60, height:80)
//                        Capsule()
//                            .frame(width:60, height:80)
//                        Capsule()
//                            .frame(width:60, height:100)
//                        Capsule()
//                            .frame(width:60, height:80)
//                        Capsule()
//                            .frame(width:60, height:80)
//                        Capsule()
//                            .frame(width:60, height:80)
//                        Capsule()
//                            .frame(width:60, height:80)
//                        
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
                        .stroke(yellow, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: 0.525, to: 0.5  + ovulationArc)
                        .stroke(blue, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)
                    Circle()
                        .trim(from: ovulationArc + 0.525 + 0.025, to: 0.975)
                        .stroke(green, style: .init(lineWidth: 25, lineCap: .round))
                        .frame(width: sz, height: sz)

                }
                .rotationEffect(.degrees(-(90 + 70)))
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
                        //days = Int(date.timeIntervalSince(firstDay))
                        days = Int(Calendar.current.dateComponents([.day], from: date, to: firstDay).day!)
                        days = days % Int(cycleLen)
                        print(days)
                        var ratio = Float(Float(days) / Float(cycleLen))
                        print(ratio)
                        
                        if (days < 0) {
                            ratio = Float(ratio * -1)
                        } else {
                            ratio = 1 - ratio
                        }
                        
                        if (ratio <= Float(periodArc)) {
                            text = """
                            Red (Menstruation) (1-3/7days):
                            - Take it easy; schedule in some rest if possible
                            - Keep exercise low intensity (i.e., long walks, yoga, lifting lighter weights)
                            - Eat high proteins and lower carbs
                            """
                            //output out the red
                        } else if (ratio <= 0.5) {
                            text = """
                            Green (Follicular) (3/7-12/13th —> between period and ovulation (end of period to day 15-
                            - Look at you go! We see the pep in your step :)
                            - Today is the perfect day to try something new, brainstorm, and grind out intense work.
                            - Push it! Now is the time to push yourself physically. HIIT, lift heavier, long hikes…you name it!
                            - To maintain this energetic high, watch your processed sugars more carefully
                            """
                            //output
                        } else if (ratio <= Float(0.5 + ovulationArc)) {
                            text = """
                            Blue (Ovulation 11/12 - 15th)
                            - Your skin may be clearer, and you may feel less bloated
                            - You are creative, powerful, calm and collected
                            - You’re libido is at its highest of the month (…go on a date?)
                            - You’re an absolute unit; lift heavy, HIIT, sprinting, long-distance running
                             - Great time for teamwork and making new friends. Keep in mind you are at peak productivity
                            """
                        } else {
                           text = """
                            Yellow (15th - 30th)
                            - As this phase progresses, you might start feeling more introverted
                            - It is a great time to self-reflect, meditate, and be one with yourself
                            - Decrease exercise intensity; we recommend long walks, yoga, and lighter weight and lower rep workouts
                            - Cravings for sugar and bread are normal during this time; listening to your body and give yourself the glucose and carbs you need to have a healthier cycle and easier period next week.
                            """
                        }
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
            Text(text)
        }
    }
}

@available(iOS 17.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
