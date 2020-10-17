//
//  MyDelegate.swift
//  Mensajes
//
//  Created by Mac on 12/10/2020.
//  Copyright © 2020 ETP. All rights reserved.
//

import Foundation
import XMPPFramework
import SwiftUI

class XMPPDelegate : NSObject, XMPPStreamDelegate, ObservableObject  {
    var stream:XMPPStream!
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster!
    @Published var mensajes: [Mensaje] = []
    @Published var intento: String = ""
    var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchiving: XMPPMessageArchiving?
    var jid: String
    var password: String
    var buddyJid: String
    
    
    init(jid:String,password:String,buddyJid:String) {
        self.jid=jid
        self.password=password
        self.buddyJid=buddyJid
        super.init()
        
        xmppRosterStorage.autoRemovePreviousDatabaseFile = false;
        xmppRosterStorage.autoRecreateDatabaseFile = false;
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.autoClearAllUsersAndResources = false;
        stream = XMPPStream()
        stream.addDelegate(self, delegateQueue: .main)
        xmppRoster.activate(stream)
        
        
        stream.myJID = XMPPJID(string: jid)
        
        
        do {
            print("connecting")
            try stream.connect(withTimeout: 30)
        }
        catch {
            print("catch")
            
        }
        xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
        
        xmppMessageArchiving?.clientSideMessageArchivingOnly = false
        xmppMessageArchiving?.activate(stream)
        xmppMessageArchiving?.addDelegate(self, delegateQueue: .main)
        
        
        
    }
    deinit {
        xmppMessageArchiving?.removeDelegate(self)
        xmppMessageArchiving?.deactivate()
        stream.disconnect()
        xmppRoster.deactivate()
        stream.removeDelegate(self)
    }
    @objc func sendMessage() {
        
        let senderJID = XMPPJID(string: buddyJid)
        let msg = XMPPMessage(type: "chat", to: senderJID)
        
        msg.addBody(intento)
        stream.send(msg)
    }
    
    
    func xmppStreamWillConnect(sender: XMPPStream!) {
        print("will connect")
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("timeout:")
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("connected")
        
        do {
            try sender.authenticate(withPassword: password)
        }
        catch {
            print("catch")
            
        }
        
    }
    
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("auth done")
        RecibedMessageArchiving()
        sender.send(XMPPPresence())
    }
    
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("dint not auth")
        print(error)
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        print(presence ?? "presence")
        let presenceType = presence.type
        let username = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        
        if presenceFromUser != username  {
            if presenceType == "available" {
                print("available")
            }
            else if presenceType == "subscribe" {
                self.xmppRoster.subscribePresence(toUser: presence.from!)
            }
            else {
                print("presence type"); print(presenceType ?? "presenceType" )
            }
        }
        
    }
    
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        if let msg = message.body {
            intento = ""
            mensajes.append(Mensaje(direccion: Direccion.Out,texto: msg))
        }
        print("sent")
    }
    
    private func xmppStream(_ sender: XMPPStream, didFailToSendIQ iq: XMPPIQ!, error: NSError!) {
        print("1 xmppStream error")
    }
    
    func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
        print("2 xmppStream error")
    }
    
    private func xmppStream(_ sender: XMPPStream, didFailToSendMessage message: XMPPMessage!, error: NSError!) {
        print("fail")
    }
    
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        if let msg = message.body {
            mensajes.append(Mensaje(direccion: Direccion.In,texto: msg))
        }
        print(message)
    }
    
    func RecibedMessageArchiving() {
        
        let JabberIDFriend = buddyJid   //id friend chat, example test1@example.com
        
        
        let moc = xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "bareJidStr like %@ "
        let predicate = NSPredicate(format: predicateFormat, JabberIDFriend)
        
        request.predicate = predicate
        request.entity = entityDescription
        
        //jabberID id del usuario, cliente
        var jabberIDCliente = jid
        
        do {
            let results = try moc?.fetch(request)
            
            for message: XMPPMessageArchiving_Message_CoreDataObject? in results as? [XMPPMessageArchiving_Message_CoreDataObject?] ?? [] {
                
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                } catch _ {
                    element = nil
                }
                
                let body: String
                let sender: String
                let date: NSDate
                let isIncomings: Bool
                if message?.body != nil {
                    body = (message?.body)!
                } else {
                    body = ""
                }
                
                
                
                if element.attributeStringValue(forName: "to") == JabberIDFriend {
                    sender = jabberIDCliente
                    isIncomings = false
                    
                } else {
                    sender = "test2@example.com"
                    isIncomings = true
                    
                }
                
                
                var m: [AnyHashable : Any] = [:]
                m["msg"] = message?.body
                
                print("body", message?.body)
                
                print("test", element.attributeStringValue(forName: "to"))
                print("test2", element.attributeStringValue(forName: "body"))
                if let texto=message?.body {
                    if (isIncomings) {
                        mensajes.append(Mensaje(direccion: Direccion.In,texto: texto))
                    }
                    else {
                        mensajes.append(Mensaje(direccion: Direccion.Out,texto: texto))
                    }
                }
            }
        } catch  {
            print("\(error)")
        }
        
    }
}
