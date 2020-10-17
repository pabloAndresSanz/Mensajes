//
//  ContentView.swift
//  Mensajes
//
//  Created by Mac on 19/09/2020.
//  Copyright © 2020 ETP. All rights reserved.
//

import SwiftUI
import XMPPFramework

struct ContentView: View  {
    @State var mensaje: String = ""
    
    var body: some View {
        let message = MessageView()
        return VStack {
            message
            HStack {
                TextField("Mensaje", text: $mensaje)
                Button(action: {
                    message.controller.sendMessage(message: self.mensaje)
                }) {
                    Image(systemName: "person.circle")
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
