//
//  MyTcpSocketServer.swift
//  SwiftSocket iOS
//
//  Created by Dust Liu on 2021/10/26.
//  Copyright © 2021 swift. All rights reserved.
//

//import Foundation
import UIKit
import SwiftSocket
 
//服务器端口
var serverport:Int32 = 8080
 
//客户端管理类（便于服务端管理所有连接的客户端）
class ChatUser:NSObject{
    var tcpClient:TCPClient?
    var username:String=""
    var socketServer:MyTcpSocketServer?
    var rentBoatNum = -1
     
    //解析收到的消息
    func readMsg()->[String:Any]?{
        //read 4 byte int as type
        if let data=self.tcpClient!.read(4){
            if data.count==4{
                let ndata = NSData(bytes: data, length: data.count)
                var len:Int32=0
                ndata.getBytes(&len, length: data.count)
                if let buff=self.tcpClient!.read(Int(len)){
                    let msgd = Data(bytes: buff, count: buff.count)
                    let msgi = (try! JSONSerialization.jsonObject(with: msgd,
                                options: .mutableContainers)) as! [String:Any]
                    return msgi
                }
            }
        }
        return nil
    }
     
    //循环接收消息
    func messageloop(){
        while true{
            if let msg=self.readMsg(){
                self.processMsg(msg: msg)
            }else{
                self.removeme()
                break
            }
        }
    }
     
    //处理收到的消息
    func processMsg(msg:[String:Any]){
        if msg["cmd"] as! String=="nickname"{
            self.username=msg["nickname"] as! String
            self.rentBoatNum = Int((msg["boatNum"] as! NSString).floatValue)
        }
        self.socketServer!.processUserMsg(user: self, msg: msg)
    }
     
    //发送消息
    func sendMsg(msg:[String:Any]){
        let jsondata=try? JSONSerialization.data(withJSONObject: msg,
                                                 options:.prettyPrinted)
        var len:Int32=Int32(jsondata!.count)
         
        let data = Data(bytes: &len, count: 4)
        _ = self.tcpClient!.send(data: data)
        _ = self.tcpClient!.send(data: jsondata!)
    }
    
    func sentCheckMsg() -> String{
        return "I'm ok"
    }
     
    //移除该客户端
    func removeme(){
        self.socketServer!.removeUser(u: self)
    }
     
    //关闭连接
    func kill(){
        self.tcpClient!.close()
    }
}
 
//服务端类
class MyTcpSocketServer: NSObject {
    var clients:[ChatUser]=[]
    var server:TCPServer=TCPServer(address: "127.0.0.1", port: serverport)
    var serverRuning:Bool=false
     
    //启动服务
    func start() {
        _ = server.listen()
        self.serverRuning=true
         
        DispatchQueue.global(qos: .background).async {
            while self.serverRuning{
                let client=self.server.accept()
                if let c=client{
                    DispatchQueue.global(qos: .background).async {
                        self.handleClient(c: c)
                    }
                }
            }
        }
         
        self.log(msg: "server started...")
    }
    
    //停止服务
    func stop() {
        self.serverRuning=false
        self.server.close()
        //forth close all client socket
        for c:ChatUser in self.clients{
            c.kill()
        }
        self.log(msg: "server stoped...")
    }
     
    //处理连接的客户端
    func handleClient(c:TCPClient){
        self.log(msg: "new client from:\t"+c.address)
        let u=ChatUser()
        u.tcpClient=c
        clients.append(u)
        u.socketServer=self
        u.messageloop()
    }
    
//    func sentCheckMsg(user:ChatUser, msg:String){
//        self.log(msg: "\(user.username)\t"+msg)
//    }
    func requirCheck(){
        if !clients.isEmpty {
            print("======================")
        }
        for client in clients {
            self.log(msg: "Are you ok \(client.username) ?")
            self.log(msg: "\(client.username): \(client.sentCheckMsg())")
        }
        
    }
     
    //处理各消息命令
    func processUserMsg(user:ChatUser, msg:[String:Any]){
        self.log(msg: "\(user.username)\trent boat num: \(user.rentBoatNum)\t[\(user.tcpClient!.address)]\tcmd:"+(msg["cmd"] as! String))
        //boardcast message
        var msgtosend=[String:String]()
        let cmd = msg["cmd"] as! String
        if cmd=="nickname"{
            msgtosend["cmd"]="join"
            msgtosend["nickname"]=user.username
            msgtosend["addr"]=user.tcpClient!.address
        }else if(cmd=="msg"){
            msgtosend["cmd"]="msg"
            msgtosend["from"]=user.username
            msgtosend["content"]=(msg["content"] as! String)
        }else if(cmd=="leave"){
            msgtosend["cmd"]="leave"
            msgtosend["nickname"]=user.username
            msgtosend["addr"]=user.tcpClient!.address
        }
        for user:ChatUser in self.clients{
            //if u~=user{
            user.sendMsg(msg: msgtosend)
            //}
        }
    }
    
     
    //移除用户
    func removeUser(u:ChatUser){
        self.log(msg: "remove user\(u.tcpClient!.address)")
        if let possibleIndex=self.clients.index(of: u){
            self.clients.remove(at: possibleIndex)
            self.processUserMsg(user: u, msg: ["cmd":"leave"])
        }
    }
     
    //日志打印
    func log(msg:String){
        print(msg)
    }
}
