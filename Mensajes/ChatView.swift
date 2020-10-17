import SwiftUI

struct ChatView: View {
    @ObservedObject var delegate = XMPPDelegate(jid: "<USER ID>", password: "<USER PASSWORD>", buddyJid: "<BUDDY ID>" )
    
    var body: some View {
        return (
            VStack {
                List(self.delegate.mensajes) { mensaje in
                    if mensaje.direccion == Direccion.In {
                        ContentMessageView(mensaje: mensaje)
                    }
                    else {
                        HStack {
                            Spacer()
                            ContentMessageView(mensaje: mensaje)
                        }
                    }
                }.onAppear { UITableView.appearance().separatorStyle = .none
                }
                
                HStack {
                    TextField("Mensaje...", text: $delegate.intento)
                      .textFieldStyle(RoundedBorderTextFieldStyle())
                      .frame(minHeight: CGFloat(30))
                    Button(action: {
                        self.delegate.sendMessage()
                    }) {
                        Image(systemName: "play")
                     }
                }.frame(minHeight: CGFloat(50)).padding()

            }
        )
    }
}

struct ContentMessageView: View {
    var mensaje : Mensaje
    
    var body: some View {
        Text(mensaje.texto)
            .padding(10)
            .foregroundColor(mensaje.direccion == Direccion.Out ? Color.white : Color.black)
            .background(mensaje.direccion == Direccion.Out ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
            .cornerRadius(10)
    }
}

