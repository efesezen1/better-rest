//
//  ContentView.swift
//  better-rest
//
//  Created by Efe Sezen on 24.12.2024.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount:Double = 8
    @State private var wakeUp = Date.now
    @State private var coffeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section{
                    
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                    .labelsHidden()
                Stepper("Desired amount of sleep: \(sleepAmount.formatted())", value:$sleepAmount, in: 0...12, step:0.25)
                Stepper("\(coffeAmount) cup(s)", value:$coffeAmount,in:1...20)
                
            }
            .navigationTitle("BetterRest")
            .toolbar{
                Button("Calculate", action:calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .padding()
    }
    func calculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 3600
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
