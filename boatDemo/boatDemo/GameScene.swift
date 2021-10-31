//
//  GameScene.swift
//  boatDemo
//
//  Created by Dust Liu on 2021/9/12.
//

import SpriteKit
import GameplayKit
import SwiftSocket


struct keyChain {
//    static let elapsedTime = "ElapsedTime"
    static let longestRentTime = "LongestRentTime"
    static let morningRentNum = "MRentingNumber"
    static let morningAverageNum = "MAverageNumber"
    static let afternoonRentNum = "ARentingNumber"
    static let afternoonAverageNum = "AAverageNumber"
    static let rentList = "RentList"
    static let line1 = "Line1Boat"
    static let line2 = "Line2Boat"
    static let line3 = "Line3Boat"
    static let line4 = "Line4Boat"
}

struct rentInfo: Codable {
    var boatIndex: Int?
    var elapsedTime: Date?
    var startTime: Date?
    var endTime: Date?
//    static func save()
}

struct rentInfoCache {
    static let key = keyChain.rentList
    static func save(_ value: [rentInfo]!) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    static func get() -> [rentInfo]! {
        var userData: [rentInfo]!
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            userData = try? PropertyListDecoder().decode([rentInfo].self, from: data)
            return userData!
        }
        else {
            return userData
        }
    }
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

func initData() {
    print("initData")
    UserDefaults.standard.set(0, forKey: keyChain.morningRentNum)
    UserDefaults.standard.set(0, forKey: keyChain.afternoonRentNum)
    UserDefaults.standard.set(0, forKey: keyChain.morningAverageNum)
    UserDefaults.standard.set(0, forKey: keyChain.afternoonAverageNum)
    UserDefaults.standard.set(0, forKey: keyChain.longestRentTime)
    UserDefaults.standard.set([0,1,2], forKey: keyChain.line1)
    UserDefaults.standard.set([3,4,5], forKey: keyChain.line2)
    UserDefaults.standard.set([], forKey: keyChain.line3)
    UserDefaults.standard.set([], forKey: keyChain.line4)
    rentInfoCache.save([])
//    var list = UserDefaults.standard.array(forKey: keyChain.line1)!
////    print(list.count)
//    list = UserDefaults.standard.array(forKey: keyChain.line2)!
////    print(list.count)
//    list = UserDefaults.standard.array(forKey: keyChain.line3)!
////    print(list.count)
//    list = UserDefaults.standard.array(forKey: keyChain.line4)!
//    print(list.count)
    
//    var averageTime = UserDefaults.standard.double(forKey: keyChain.morningAverageNum)
////    print("MaverageTime = \(averageTime)")
//    averageTime = UserDefaults.standard.double(forKey: keyChain.afternoonAverageNum)
//    print("AaverageTime = \(averageTime)")
}


class GameScene: SKScene{
    let boatNum = 6
    var background : SKSpriteNode?
    var boat = [SKSpriteNode](repeating: SKSpriteNode(), count: 6)
    var number = [SKLabelNode](repeating: SKLabelNode(), count: 6)
    var wave: [SKSpriteNode] = []
    var Num01: SKLabelNode?
    var Num02: SKLabelNode?
    static var line1: Int = UserDefaults.standard.array(forKey: keyChain.line1)!.count
    static var line2: Int = UserDefaults.standard.array(forKey: keyChain.line2)!.count
    static var line3: Int = UserDefaults.standard.array(forKey: keyChain.line3)!.count
    static var line4: Int = UserDefaults.standard.array(forKey: keyChain.line4)!.count
    var availableNum: Int = 0
    var rentedNum: Int = 0
    var toBeConfirmed: [SKSpriteNode] = []
    let dataStand = UserDefaults.standard
    var clock: SKLabelNode?
    var updateTime: Double = 0
    var cheakTime: Double = 0
    
    var socketServer: MyTcpSocketServer?
    var socketClient:TCPClient?
    var textView: UITextView!

    
    
    override func didMove(to view: SKView) {
        self.availableNum = self.boatNum - self.rentedNum
        initData()
        setBackground()
        socketServer = MyTcpSocketServer()
        socketServer?.start()
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
//        print("emmm")
        if rentInfoCache.get() != nil {
//            print("get")
            let rentList = rentInfoCache.get()!
            let lastRent = rentList.last?.startTime
//            print(lastRent)
            if dateformatter.string(from: lastRent ?? Date()) != dateformatter.string(from: Date()){
//                print("run")
                initData()
//                setInitBoat()
                restoreBoat()
            }
            else {
                restoreBoat()
            }
        }
        else {
            restoreBoat()
        }

        
        setSign()
        setWave()
        addClock()

        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        self.physicsWorld.contactDelegate = self

    }
    
//    MARK: ---------------------- 初始化 ----------------------
    
    func setBackground() {
        self.background = SKSpriteNode(imageNamed: "background7.jpg")
        self.background?.size = CGSize(width: frame.width * 1.5, height: frame.height)
        self.background?.position = CGPoint(x: frame.width * 0.25, y: frame.height * 0.5)
        self.background?.zPosition = 1
        self.addChild(self.background!)
    }


    
    func updateClock() {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss"
        let timeText = dateformatter.string(from: Date())
        self.clock?.text = timeText
    }
    
    func addClock() {
        self.clock = SKLabelNode(fontNamed: "Baloo")
        self.clock?.fontColor = .black
        self.clock?.fontSize = 20
        self.clock?.position = CGPoint(x: frame.width * 0.85, y: frame.height * 0.9)
        self.clock?.zPosition = 1
        self.addChild(self.clock!)
        updateClock()
    }
    
    
    
    func updateLineNum() {
        GameScene.line1 = UserDefaults.standard.array(forKey: keyChain.line1)!.count
        GameScene.line2 = UserDefaults.standard.array(forKey: keyChain.line2)!.count
        GameScene.line3 = UserDefaults.standard.array(forKey: keyChain.line3)!.count
        GameScene.line4 = UserDefaults.standard.array(forKey: keyChain.line4)!.count
        self.availableNum = GameScene.line1 + GameScene.line2
        self.rentedNum = GameScene.line3 + GameScene.line4
    }
    
    
    func restoreBoat() {
        let mask = SKTexture(imageNamed: "boatMask01")
        for i in 1...4 {
//            print("Line\(i)")
            
            if dataStand.array(forKey: "Line1Boat") == nil {
                initData()
            }
            
            let lineList = dataStand.array(forKey: "Line\(i)Boat") as! Array<Int>
            var count = 0
            for num in lineList{
//                print(num)
                let availabeBoatModel = SKSpriteNode(imageNamed: "boat2.png")
                availabeBoatModel.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.05)
                let rentedBoatModel = SKSpriteNode(imageNamed: "person2.png")
                rentedBoatModel.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.08)
                self.boat.remove(at: num)
                
                if i == 1 {
                    self.boat.insert(availabeBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.8)
                    self.boat[num].name = "line1"
                    
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .white
                    self.number.insert(tmpLable, at: num)
                }
                else if i == 2 {
                    self.boat.insert(availabeBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.7)
                    self.boat[num].name = "line2"
                    
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .white
                    self.number.insert(tmpLable, at: num)
                }
                else if i == 3 {
                    self.boat.insert(rentedBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.35)
                    self.boat[num].name = "line3"
                    
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .white
                    self.number.insert(tmpLable, at: num)
                }
                else {
                    self.boat.insert(rentedBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.25)
                    self.boat[num].name = "line4"
                    
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .white
                    self.number.insert(tmpLable, at: num)
                }
                count += 1
                self.boat[num].zPosition = 5
                self.number[num].zPosition = 1
                
                self.addChild(self.boat[num])
                self.number[num].verticalAlignmentMode = .center
                self.number[num].horizontalAlignmentMode = .right
                self.boat[num].addChild(self.number[num])
                
                self.boat[num].physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                self.boat[num].physicsBody?.affectedByGravity = true
                
            }
            
        }
//        print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
        
        
    }
    
    
    
    func setInitBoat() {
        let mask = SKTexture(imageNamed: "boatMask01")
        self.boat.removeAll()
        for i in 0...(self.boatNum - 1) {
            let availabeBoatModel = SKSpriteNode(imageNamed: "boat2.png")
            self.boat.append(availabeBoatModel)
            self.boat[i].size = CGSize(width: frame.width * 0.25, height: frame.height * 0.05)
            if i < 3 {
                self.boat[i].position = CGPoint(x: frame.width * (0.22 + CGFloat(i) * 0.3 ), y: frame.height * 0.8)
                GameScene.line1 += 1
                self.boat[i].name = "line1"
                
            }
            else{
                self.boat[i].position = CGPoint(x: frame.width * (0.22 + CGFloat(i - 3) * 0.3 ), y: frame.height * 0.7)
                GameScene.line2 += 1
                self.boat[i].name = "line2"
            }
            self.boat[i].zPosition = 5
            
            
            self.addChild(self.boat[i])
            
            
            self.boat[i].physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
            self.boat[i].physicsBody?.affectedByGravity = true
            
        }
    }
    
    
    
    func setSign() {
        let lable01 = SKLabelNode(fontNamed: "Baloo")
        lable01.fontColor = .black
        lable01.fontSize = 25
        lable01.text = "Available Boat:"
        lable01.position = CGPoint(x: frame.width * 0.3, y: frame.height * 0.86)
        lable01.zPosition = 8
        
        let lable02 = SKLabelNode(fontNamed: "Baloo")
        lable02.fontColor = .black
        lable02.fontSize = 25
        lable02.text = "Rented Boat:"
        lable02.position = CGPoint(x: frame.width * 0.3, y: frame.height * 0.48)
        lable02.zPosition = 8
        
        self.availableNum = GameScene.line1 + GameScene.line2
        self.rentedNum = GameScene.line3 + GameScene.line4
//        print("setSign: line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
        
        self.Num01 = SKLabelNode(fontNamed: "Baloo")
        self.Num01?.fontColor = .black
        self.Num01?.fontSize = 25
        self.Num01?.text = "\(self.availableNum)"
        self.Num01?.position = CGPoint(x: frame.width * 0.58, y: frame.height * 0.86)
        self.Num01?.zPosition = 8
        
        self.Num02 = SKLabelNode(fontNamed: "Baloo")
        self.Num02?.fontColor = .black
        self.Num02?.fontSize = 25
        self.Num02?.text = "\(self.rentedNum)"
        self.Num02?.position = CGPoint(x: frame.width * 0.58, y: frame.height * 0.48)
        self.Num02?.zPosition = 8
        
        
        self.addChild(lable01)
        self.addChild(lable02)
        self.addChild(self.Num01!)
        self.addChild(self.Num02!)
    }
    
    
    func setWave() {
        let mask = SKTexture(imageNamed: "waveMask2.png")
        for i in 0...3 {
            let waveModel = SKSpriteNode(imageNamed: "bottom.png")
            self.wave.append(waveModel)
            if i < 2{
                self.wave[i].position = CGPoint(x: frame.width * 0.9, y: frame.height * (0.75 - 0.14 * CGFloat(i)))
            }else{
                self.wave[i].position = CGPoint(x: frame.width * 0.9, y: frame.height * (0.35 - 0.15 * CGFloat(i-2)))
            }
            
            self.wave[i].zPosition = 0
            self.addChild(self.wave[i])
            self.wave[i].physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 2, height: frame.height * 0.15))
            self.wave[i].physicsBody?.affectedByGravity = false
            self.wave[i].physicsBody?.allowsRotation = false
            self.wave[i].physicsBody?.isDynamic = false
            self.wave[i].physicsBody?.friction = 0.02

        }
        
        
    }
    
    
//    MARK: ---------------------- 交互 ----------------------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
//        print("boat num = \(self.boat.count)")
        
        if var sp = atPoint(location) as? SKSpriteNode{
//            SKAction  选定船，闪烁（6s）等待再次确认
            let readyAction = SKAction.repeat(SKAction.sequence(
                [SKAction.colorize(with: .black, colorBlendFactor: 0.4, duration: 0.2),
                 SKAction.wait(forDuration: 0.2),
                 SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)]), count: 10)
            
//            SKAction  一定时间后未确认的船对象，自动取消选定
            let delete = SKAction.run {
                if let index = self.toBeConfirmed.firstIndex(of: sp){
//                    self.toBeConfirmed.remove(at: index)
                    self.toBeConfirmed.remove(at: index)
//                    print("ojbk")
                }
            }
            
//            使用船下标作为key
            var num = 0
            if let index = self.boat.firstIndex(of: sp){
                num = index
//                print("key = \(num)")
            }
            
//            获取时间戳
//            let  timeInterval: TimeInterval  = DateInterval.timeIntervalSince1970
//            let  timeStamp =  Int (timeInterval)
            let timeStamp = Date().timeIntervalSince1970
//            print("时间戳 = \(timeStamp)")
            
            
            
//            MARK: ---- toBeConfirmed 数组中包含 sp (确认订单) ----
            if (self.toBeConfirmed.contains(sp)){
//                print("success")
                sp.removeAllActions()
                sp.colorBlendFactor = 0
                
                
//                移出 toBeConfirmed
                if let index = self.toBeConfirmed.firstIndex(of: sp){
                    self.toBeConfirmed.remove(at: index)
//                    print("ojbk")
                }
                

                if sp.name == "line1" {
                    processClientSocket(num: num)
//                    print("rent")
//                    更新数字
                    var lineList = dataStand.array(forKey: keyChain.line1) as! Array<Int>
                    
                    if lineList.contains(num) {
                        if let index = lineList.firstIndex(of: num){
                            lineList.remove(at: index)
                        }
                    }
                    dataStand.set(lineList, forKey: keyChain.line1)
                    
                    
//                    销毁原精灵
                    sp.removeFromParent()
                    self.boat.remove(at: num)
                    
//                    创建新精灵
                    sp = SKSpriteNode(imageNamed: "person2.png")
                    sp.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.08)
//                    GameScene.line1 -= 1             // 该行 精灵个数 减一
                    
                    
                    self.number[num].removeFromParent()
                    self.number.remove(at: num)
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .black
                    self.number.insert(tmpLable, at: num)
                    self.number[num].zPosition = 1
                    self.number[num].verticalAlignmentMode = .center
                    self.number[num].horizontalAlignmentMode = .right
                    
//                    判断放在第几行
                    if (GameScene.line3 < 3){
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 0.35)
//                        GameScene.line3 += 1
                        lineList = dataStand.array(forKey: keyChain.line3) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line3)
                        sp.name = "line3"
                        
                    }
                    else{
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 0.25)
//                        GameScene.line4 += 1
                        lineList = dataStand.array(forKey: keyChain.line4) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line4)
                        sp.name = "line4"
                    }
                    
                    
                    
                    
                    sp.zPosition = 5
                    self.addChild(sp)
                    self.boat.insert(sp, at: num)
                    self.boat[num].addChild(self.number[num])
                    
                    
//                    创建物理体
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
//                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
                }
                
                else if sp.name == "line2" {
                    processClientSocket(num: num)
//                    print("rent")
                    
                    var lineList = dataStand.array(forKey: keyChain.line2) as! Array<Int>
                    if lineList.contains(num) {
                        if let index = lineList.firstIndex(of: num){
                            lineList.remove(at: index)
                        }
                    }
                    dataStand.set(lineList, forKey: keyChain.line2)
                    

                    
                    sp.removeFromParent()
                    self.boat.remove(at: num)
                    
                    sp = SKSpriteNode(imageNamed: "person2.png")
                    sp.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.08)
                    
                    
                    self.number[num].removeFromParent()
                    self.number.remove(at: num)
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .black
                    self.number.insert(tmpLable, at: num)
                    self.number[num].zPosition = 1
                    self.number[num].verticalAlignmentMode = .center
                    self.number[num].horizontalAlignmentMode = .right

                    
                    if (GameScene.line3 < 3){
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 0.35)
                        lineList = dataStand.array(forKey: keyChain.line3) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line3)
                        sp.name = "line3"
                        
                    }
                    else{
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 0.25)
//                        GameScene.line4 += 1
                        lineList = dataStand.array(forKey: keyChain.line4) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line4)
                        sp.name = "line4"
                    }
                    
//                    self.Num02?.text = "\(rentedNum)"
                    
                    
                    sp.zPosition = 5
                    self.addChild(sp)
                    self.boat.insert(sp, at: num)
                    self.boat[num].addChild(self.number[num])
                    
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
//                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
                }
                
//                MARK: ---> 写入开始时间 <---
                self.dataStand.set(timeStamp, forKey: "\(num)")
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                let tmp1: Date = Date(timeIntervalSince1970: timeStamp)
                
//                print("开始时间 = \(dateformatter.string(from: tmp1))")
                
                
            }
            
//            MARK: ---- toBeConfirmed 数组中不包含 sp (创建订单 或 结束订单) ----
            else{
                
//                MARK: ----> 创建订单 <----
                if (sp.name == "line1" || sp.name == "line2"){
                    sp.run(SKAction.repeat(SKAction.sequence([readyAction,delete]),count: 1))       // 运行待确认动画（6s闪烁）
                    self.toBeConfirmed.append(sp)                                                   // 加入到待确认状态
                }
                
//                MARK: ----> 结束订单 <----
                else if sp.name == "line3"{
                    for client in socketServer!.clients{
                        if client.rentBoatNum == num{
                            client.removeme()
                        }
                    }
//                    print("givenBack")
//                    更新数字
                    
                    var lineList = dataStand.array(forKey: keyChain.line3) as! Array<Int>
//                    lineList.remove(at:num)
                    if lineList.contains(num) {
//                        lineList.re
                        if let index = lineList.firstIndex(of: num){
                            lineList.remove(at: index)
                        }
                    }
                    
                    dataStand.set(lineList, forKey: keyChain.line3)
//                    self.Num02?.text = "\(self.rentedNum)"
                    
//                    self.rentedNum -= 1
//                    self.availableNum += 1
//                    self.Num01?.text = "\(self.availableNum)"
//                    self.Num02?.text = "\(self.rentedNum)"
                    
//                    销毁 原子精灵
                    sp.removeFromParent()
                    self.boat.remove(at: num)
                    

                    
                    sp = SKSpriteNode(imageNamed: "boat2.png")
                    sp.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.05)
//                    GameScene.line3 -= 1
                    
                    self.number[num].removeFromParent()
                    self.number.remove(at: num)
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .white
                    self.number.insert(tmpLable, at: num)
                    self.number[num].zPosition = 1
                    self.number[num].verticalAlignmentMode = .center
                    self.number[num].horizontalAlignmentMode = .right
                    
                    if (GameScene.line1 < 3){
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 1)
//                        GameScene.line1 += 1
                        lineList = dataStand.array(forKey: keyChain.line1) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line1)
                        
                        sp.name = "line1"
                    }
                    else{
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 0.7)
//                        GameScene.line2 += 1
                        lineList = dataStand.array(forKey: keyChain.line2) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line2)
                        sp.name = "line2"
                    }
                    
//                    self.Num01?.text = "\(availableNum)"
                    
                    
                    sp.zPosition = 5
                    self.addChild(sp)
                    self.boat.insert(sp, at: num)
                    self.boat[num].addChild(self.number[num])
                    
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
//                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
//                    MARK: -- 数据写入 --
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tmp1: Date = Date(timeIntervalSince1970: timeStamp)
                    
//                    print("停止时间 = \(dateformatter.string(from: tmp1))")
                    
                    let startTime: Date = Date(timeIntervalSince1970: self.dataStand.double(forKey: "\(num)"))
                    let endTime: Date = Date(timeIntervalSince1970: timeStamp)
                    
//                    print("start = \(dateformatter.string(from: startTime)); end = \(dateformatter.string(from: endTime))")
                    
                    let elapsedStamp = timeStamp - self.dataStand.double(forKey: "\(num)")
                    let elapsedTime: Date = Date(timeIntervalSince1970: elapsedStamp)
                    

//                    print("elapsedTime = \(dateformatter.string(from: elapsedTime))")
                    
                    
//                    MARK: ---- 数据 ----
                    let thisRent = rentInfo(boatIndex: num, elapsedTime: elapsedTime, startTime: startTime, endTime: endTime)
                    
                    
                    
                    if (rentInfoCache.get() == nil){
                        rentInfoCache.save([thisRent])
                    }
                    else{
                        var updateList = rentInfoCache.get()!
                        updateList.append(thisRent)
                        rentInfoCache.save(updateList)
                    }
                    
                    
                    let cal = Calendar.current
//
//                    let second = cal.component(.second, from: elapsedTime)
//                    let minute = cal.component(.minute, from: elapsedTime)
//                    let hour = cal.component(.hour, from: elapsedTime)

//                    print("\(hour):\(minute):\(second)")
                    
//                    print("hour = \(cal.component(.hour, from: Date(timeIntervalSince1970: timeStamp)))")
                    
                    let longestTime = self.dataStand.double(forKey: keyChain.longestRentTime)
                    if longestTime < elapsedStamp {
                        self.dataStand.set(elapsedStamp, forKey: keyChain.longestRentTime)
                    }
                    
//                    上午
                    if cal.component(.hour, from: Date(timeIntervalSince1970: timeStamp)) < 12 {
                        let rentNum = self.dataStand.integer(forKey: keyChain.morningRentNum) + 1
                        self.dataStand.set(rentNum, forKey: keyChain.morningRentNum)
                        
                        var averageTime = self.dataStand.double(forKey: keyChain.morningAverageNum)
                        if averageTime == 0 {
                            self.dataStand.set(elapsedStamp, forKey: keyChain.morningAverageNum)
                        }
                        else{
                            averageTime = (averageTime * Double(rentNum - 1) + elapsedStamp) / Double(rentNum)
                            self.dataStand.set(averageTime, forKey: keyChain.morningAverageNum)
                        }
//                        print("Morning")
//                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.morningAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
                    }
//                    下午
                    else {
                        let rentNum = self.dataStand.integer(forKey: keyChain.afternoonRentNum) + 1
                        self.dataStand.set(rentNum, forKey: keyChain.afternoonRentNum)
                        
                        var averageTime = self.dataStand.double(forKey: keyChain.afternoonAverageNum)
//                        print("averageTime = \(averageTime)")
                        if averageTime == 0 {
                            self.dataStand.set(elapsedStamp, forKey: keyChain.afternoonAverageNum)
                        }
                        else{
                            averageTime = (averageTime * Double(rentNum - 1) + elapsedStamp) / Double(rentNum)
//                            print("after/2: \(averageTime)")
                            self.dataStand.set(averageTime, forKey: keyChain.afternoonAverageNum)
                        }
                        
//                        print("Afternoon")
//                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.afternoonAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
                    }
                    
                }
                
                else if sp.name == "line4"{
                    for client in socketServer!.clients{
                        if client.rentBoatNum == num{
                            client.removeme()
                        }
                    }
                    
                    var lineList = dataStand.array(forKey: keyChain.line4) as! Array<Int>
                    if lineList.contains(num) {
//                        lineList.re
                        if let index = lineList.firstIndex(of: num){
                            lineList.remove(at: index)
                        }
                    }
                    
                    dataStand.set(lineList, forKey: keyChain.line4)
//                    self.Num02?.text = "\(self.rentedNum)"
                    
//                    self.rentedNum -= 1
//                    self.availableNum += 1
//                    self.Num01?.text = "\(self.availableNum)"
//                    self.Num02?.text = "\(self.rentedNum)"
                    
                    sp.removeFromParent()
                    self.boat.remove(at: num)
                    
                    
                    sp = SKSpriteNode(imageNamed: "boat2.png")
                    sp.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.05)
//                    GameScene.line4 -= 1
                    self.number[num].removeFromParent()
                    self.number.remove(at: num)
                    let tmpLable = SKLabelNode(text: "⛵️Boat \(num)")
                    tmpLable.fontName = "Baloo"
                    tmpLable.fontSize = 14
                    tmpLable.fontColor = .white
                    self.number.insert(tmpLable, at: num)
                    self.number[num].zPosition = 1
                    self.number[num].verticalAlignmentMode = .center
                    self.number[num].horizontalAlignmentMode = .right
                    
                    if (GameScene.line1 < 3){
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 1)
                        GameScene.line1 += 1
                        lineList = dataStand.array(forKey: keyChain.line1) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line1)
                        
                        sp.name = "line1"
                    }
                    else{
                        sp.position = CGPoint(x: frame.width * 1.2, y: frame.height * 0.7)
//                        GameScene.line2 += 1
                        lineList = dataStand.array(forKey: keyChain.line2) as! Array<Int>
                        lineList.append(num)
                        dataStand.set(lineList, forKey: keyChain.line2)
                        
                        sp.name = "line2"
                    }

//                    self.Num01?.text = "\(availableNum)"
                    
                    
                    sp.zPosition = 5
                    self.addChild(sp)
                    self.boat.insert(sp, at: num)
                    self.boat[num].addChild(self.number[num])
                    
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
//                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
//                    MARK: -- 数据写入 --
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tmp1: Date = Date(timeIntervalSince1970: timeStamp)
                    
//                    print("停止时间 = \(dateformatter.string(from: tmp1))")
                    
                    let startTime: Date = Date(timeIntervalSince1970: self.dataStand.double(forKey: "\(num)"))
                    let endTime: Date = Date(timeIntervalSince1970: timeStamp)
                    
//                    print("start = \(dateformatter.string(from: startTime)); end = \(dateformatter.string(from: endTime))")
                    
                    let elapsedStamp = timeStamp - self.dataStand.double(forKey: "\(num)")
                    let elapsedTime: Date = Date(timeIntervalSince1970: elapsedStamp)
                    

//                    print("elapsedTime = \(dateformatter.string(from: elapsedTime))")
                    
                    
//                    MARK: ---- 数据 ----
                    let thisRent = rentInfo(boatIndex: num, elapsedTime: elapsedTime, startTime: startTime, endTime: endTime)
                    
                    if (rentInfoCache.get() == nil){
                        rentInfoCache.save([thisRent])
                    }
                    else{
                        var updateList = rentInfoCache.get()!
                        updateList.append(thisRent)
                        rentInfoCache.save(updateList)
                    }
                        
                    let cal = Calendar.current

//                    let second = cal.component(.second, from: elapsedTime)
//                    let minute = cal.component(.minute, from: elapsedTime)
//                    let hour = cal.component(.hour, from: elapsedTime)

//                    print("\(hour):\(minute):\(second)")
                    
//                    print("hour = \(cal.component(.hour, from: Date(timeIntervalSince1970: timeStamp)))")
                    
                    let longestTime = self.dataStand.double(forKey: keyChain.longestRentTime)
                    if longestTime < elapsedStamp {
                        self.dataStand.set(elapsedStamp, forKey: keyChain.longestRentTime)
                    }
                    
//                    上午
                    if cal.component(.hour, from: Date(timeIntervalSince1970: timeStamp)) < 12 {
                        let rentNum = self.dataStand.integer(forKey: keyChain.morningRentNum) + 1
                        self.dataStand.set(rentNum, forKey: keyChain.morningRentNum)
                        
                        var averageTime = self.dataStand.double(forKey: keyChain.morningAverageNum)
                        if averageTime == 0 {
                            self.dataStand.set(elapsedStamp, forKey: keyChain.morningAverageNum)
                        }
                        else{
                            averageTime = (averageTime * Double(rentNum - 1) + elapsedStamp) / Double(rentNum)
                            self.dataStand.set(averageTime, forKey: keyChain.morningAverageNum)
                        }
//                        print("Morning")
//                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.morningAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
                    }
//                    下午
                    else {
                        let rentNum = self.dataStand.integer(forKey: keyChain.afternoonRentNum) + 1
                        self.dataStand.set(rentNum, forKey: keyChain.afternoonRentNum)
                        
                        var averageTime = self.dataStand.double(forKey: keyChain.afternoonAverageNum)
                        
                        if averageTime == 0 {
                            self.dataStand.set(elapsedStamp, forKey: keyChain.afternoonAverageNum)
                        }
                        else{
                            averageTime = (averageTime * Double(rentNum - 1) + elapsedStamp) / Double(rentNum)
                            self.dataStand.set(averageTime, forKey: keyChain.afternoonAverageNum)
                        }
                        
//                        print("Afternoon")
//                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.afternoonAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
                    }
                    
//                    let tmp = rentInfoCache.get()!
//                    print("========================")
//                    for t in tmp{
////                        print("num = \(String(describing: t.boatIndex!)) elapsedTime = \(t.elapsedTime!)")
////                        print(t.boatIndex!)
//
////                        print(t)
////                        print("-----------------------")
//                    }
                    
                }
            }
        }
    }
    
//    func sendMessage() {
//        let postInfo: [String: String] = [
//            "number": "boat3",
//            "states": "live"
//        ]
//
//        AF.request("http://127.0.0.1:5000/states", method: .post, parameters: postInfo, encoder: JSONParameterEncoder.default).response { response in
//            debugPrint(response)
//        }
//
//    }
//
//
//
    
    
    //初始化客户端，并连接服务器
    func processClientSocket(num: Int){
        socketClient=TCPClient(address: "localhost", port: 8080)
         
        DispatchQueue.global(qos: .background).async {
            //用于读取并解析服务端发来的消息
            func readmsg()->[String:Any]?{
                //read 4 byte int as type
                if let data=self.socketClient!.read(4){
                    if data.count==4{
                        let ndata=NSData(bytes: data, length: data.count)
                        var len:Int32=0
                        ndata.getBytes(&len, length: data.count)
                        if let buff=self.socketClient!.read(Int(len)){
                            let msgd = Data(bytes: buff, count: buff.count)
                            if let msgi = try? JSONSerialization.jsonObject(with: msgd,
                                                        options: .mutableContainers) {
                                return msgi as? [String:Any]
                            }
                        }
                    }
                }
                return nil
            }
             
            //连接服务器
            switch self.socketClient!.connect(timeout: 5) {
                case .success:
                    DispatchQueue.main.async {
                        self.alert(msg: "connect success", after: {}
                        )
                    }
                     
                    //发送用户名给服务器（这里使用随机生成的）
                let msgtosend=["cmd":"nickname","nickname":"游客\(Int(arc4random()%1000))","boatNum":"\(num)"]
                    self.sendMessage(msgtosend: msgtosend)
                     
                    //不断接收服务器发来的消息
                    while true{
                        if let msg=readmsg(){
                            DispatchQueue.main.async {
                                self.processMessage(msg: msg)
                            }
                        }else{
                            DispatchQueue.main.async {
                                //self.disconnect()
                            }
                            //break
                        }
                    }
                
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.alert(msg: error.localizedDescription,after: {}
                        )
                    }
            }
        }
    }
    
    //发送消息
    func sendMessage(msgtosend:[String:String]){
        let msgdata=try? JSONSerialization.data(withJSONObject: msgtosend,
                                                options: .prettyPrinted)
        var len:Int32=Int32(msgdata!.count)
        let data = Data(bytes: &len, count: 4)
        _ = self.socketClient!.send(data: data)
        _ = self.socketClient!.send(data:msgdata!)
    }
     
    //处理服务器返回的消息
    func processMessage(msg:[String:Any]){
        let cmd:String=msg["cmd"] as! String
        switch(cmd){
        case "msg":
            self.textView.text = self.textView.text +
                (msg["from"] as! String) + ": " + (msg["content"] as! String) + "\n"
        default:
//            print(msg)
            break
        }
    }
     
    //弹出消息框
    func alert(msg:String,after:()->(Void)){
        let alertController = UIAlertController(title: "",
                                                message: msg,
                                                preferredStyle: .alert)
//        self.present(alertController, animated: true, completion: nil)

        //1.5秒后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            alertController.dismiss(animated: false, completion: nil)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime - updateTime >= 1{
            updateTime = currentTime
            updateClock()
        }
        
        if currentTime - cheakTime >= 5{
            cheakTime = currentTime
            socketServer!.requirCheck()
        }

    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
//        print("发生碰撞")
    }
}
