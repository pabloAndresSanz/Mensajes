//
//  Mensaje.swift
//  Mensajes
//
//  Created by Mac on 12/10/2020.
//  Copyright © 2020 ETP. All rights reserved.
//

import Foundation
enum Direccion {case In, Out}
struct Mensaje : Identifiable {
    let id = UUID()
    var direccion : Direccion
    var texto: String
}
