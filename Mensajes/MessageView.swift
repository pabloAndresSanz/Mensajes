//
//  MessageView.swift
//  Mensajes
//
//  Created by Mac on 19/09/2020.
//  Copyright © 2020 ETP. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// 1.
struct MessageView : UIViewControllerRepresentable  {
    var controller : MessageViewController
    init() {
        controller = MessageViewController()
    }
    // 2.
    func makeUIViewController(context: Context) -> MessageViewController {
        return controller
    }
    
    // 3.
    func updateUIViewController(_ uiViewController: MessageViewController, context: Context) {
        
    }
}

