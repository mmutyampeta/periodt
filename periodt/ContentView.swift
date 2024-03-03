//
//  ContentView.swift
//  PeriodTracker
//
//  Created by Mihir Mutyampeta on 3/3/24.
//

import SwiftUI

struct ContentView: View {
    var sz: CGFloat = 250;
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.12)
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
            VStack {
                Text("23")
                    .font(.system(size: 42, weight: .bold))
                Text("Aug")
                    .font(.system(size: 50, weight: .bold))
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
