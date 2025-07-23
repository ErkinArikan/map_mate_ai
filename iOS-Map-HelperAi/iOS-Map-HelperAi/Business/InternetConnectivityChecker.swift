//
//  InternetConnectivityChecker.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.12.2024.
//


import Foundation
import Network
import SwiftUI


class InternetConnectivityChecker: ObservableObject {
    let monitor = NWPathMonitor()
    let queue =  DispatchQueue(label:"NetworkMonitor")
    @Published var isConnected = false
    @Published var showNotification = false
    @Published var wasDisconnected = false
    
    
    
    func startMonitoring(){
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async{
                let currentStatus = path.status == .satisfied
                if self.isConnected != currentStatus {
                    if currentStatus {
                        if self.wasDisconnected{
                            self.showNotification = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation{
                                    self.showNotification = false
                                }
                            }
                        }
                    }else{
                        self.showNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            withAnimation{
                                self.showNotification = false
                            }
                        }
//                        self.wasDisconnected
                    }
                    self.isConnected = currentStatus
                }
                
                
            }
        }
        monitor.start(queue: queue)
    }
}
