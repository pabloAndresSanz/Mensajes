//
//  ContentViewController.swift
//  Mensajes
//
//  Created by Mac on 19/09/2020.
//  Copyright © 2020 ETP. All rights reserved.
//

import Foundation
import UIKit
import XMPPFramework

class MessageViewController: UIViewController, XMPPStreamDelegate {

    var stream:XMPPStream!
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)

        stream = XMPPStream()
        //stream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        stream.addDelegate(self, delegateQueue: .main)
        stream.hostName = "apps.gylgroup.com"
        xmppRoster.activate(stream)
        

        stream.myJID = XMPPJID(string: "mamoroso.gylgroup.com@apps.gylgroup.com")
        
        
        do {
            print("connecting")
            try stream.connect(withTimeout: 30)
        }
        catch {
            print("catch")
            
        }
        
        
        let button = UIButton()
        button.backgroundColor = UIColor.blue
        button.frame = CGRect(x:90, y:100, width:300, height:40)
        button.setTitle("SendMessage", for: .normal)
        button.addTarget(self, action: #selector(self.sendMessage), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    @objc func sendMessage(message : String) {

        let senderJID = XMPPJID(string: "cperez.gylgroup.com@apps.gylgroup.com")
        let msg = XMPPMessage(type: "chat", to: senderJID)
        
        msg.addBody(message)
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
            try sender.authenticate(withPassword: "xmpp_pass")
        }
        catch {
            print("catch")
            
        }

    }
    
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("auth done")
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print(message)
    }
}

