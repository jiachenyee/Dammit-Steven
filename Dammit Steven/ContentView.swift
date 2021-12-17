//
//  ContentView.swift
//  Dammit Steven
//
//  Created by Jia Chen Yee on 17/12/21.
//

import SwiftUI
import Network

struct ContentView: View {
    
    @State var output = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let password = "<#fill in your password in this very secure field#>"
    let originalDeviceName = "<#your mac's original host name#>"
    
    var body: some View {
        ScrollView {
            Text(output)
                .font(.system(.body, design: .monospaced))
        }
        .padding()
        .onReceive(timer) { input in
            if let deviceName = Host.current().localizedName, deviceName != originalDeviceName {
                output += shell("echo \(password) | sudo -S scutil --set ComputerName \(originalDeviceName)").0 ?? ""
            }
        }
    }
    
    func shell(_ command: String) -> (String?, Int32) {
        let task = Process()
        
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        task.waitUntilExit()
        
        return (output, task.terminationStatus)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
