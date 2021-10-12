//
//  GameScene.swift
//  boatDemo
//
//  Created by Dust Liu on 2021/9/12.
//

import SpriteKit
import GameplayKit

struct keyChain {
//    static let elapsedTime = "ElapsedTime"
    static let longestRentTime = "LongestRentTime"
    static let morningRentNum = "MRentingNumber"
    static let morningAverageNum = "MAverageNumber"
    static let afternoonRentNum = "ARentingNumber"
    static let afternoonAverageNum = "AAverageNumber"
    static let rentList = "RentList"
//    static let availableBoat = "AvaliableBoat"
//    static let rentedBoat = "RentedBoat"
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
    var list = UserDefaults.standard.array(forKey: keyChain.line1)!
    print(list.count)
    list = UserDefaults.standard.array(forKey: keyChain.line2)!
    print(list.count)
    list = UserDefaults.standard.array(forKey: keyChain.line3)!
    print(list.count)
    list = UserDefaults.standard.array(forKey: keyChain.line4)!
    print(list.count)
    
    var averageTime = UserDefaults.standard.double(forKey: keyChain.morningAverageNum)
    print("MaverageTime = \(averageTime)")
    averageTime = UserDefaults.standard.double(forKey: keyChain.afternoonAverageNum)
    print("AaverageTime = \(averageTime)")
}



class GameScene: SKScene{
    let boatNum = 6
    var background : SKSpriteNode?
    var boat = [SKSpriteNode](repeating: SKSpriteNode(), count: 6)
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
//    var rentList: [rentInfo] = []
    

    
    
    
    override func didMove(to view: SKView) {
//        self.availableNum = self.boatNum - self.rentedNum
//        initData()
        setBackground()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        print("emmm")
        if rentInfoCache.get() != nil {
            print("get")
            let rentList = rentInfoCache.get()!
            let lastRent = rentList.last?.startTime
//            print(lastRent)
            if dateformatter.string(from: lastRent ?? Date()) != dateformatter.string(from: Date()){
                print("run")
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
//        restoreBoat()
//        setInitBoat()
        setSign()
        setWave()
        addClock()
//        view.showsPhysics = true
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        self.physicsWorld.contactDelegate = self
        
//        initData()
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
//        self.clock?.text = timeText
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
            print("Line\(i)")
            
            if dataStand.array(forKey: "Line1Boat") == nil {
                initData()
            }
            
            let lineList = dataStand.array(forKey: "Line\(i)Boat") as! Array<Int>
            var count = 0
            for num in lineList{
                print(num)
                let availabeBoatModel = SKSpriteNode(imageNamed: "boat2.png")
                availabeBoatModel.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.05)
                let rentedBoatModel = SKSpriteNode(imageNamed: "person2.png")
                rentedBoatModel.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.08)
//                print("new finish")
                self.boat.remove(at: num)
//                self.boat.insert(availabeBoatModel, at: num)
//                print("insert finish")
//                self.boat[num].size = CGSize(width: frame.width * 0.25, height: frame.height * 0.05)
//                print("size finish")
                
                if i == 1 {
//                    print("ruin")
                    self.boat.insert(availabeBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.8)
                    self.boat[num].name = "line1"
                }
                else if i == 2 {
                    self.boat.insert(availabeBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.7)
                    self.boat[num].name = "line2"
                }
                else if i == 3 {
                    self.boat.insert(rentedBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.35)
                    self.boat[num].name = "line3"
                }
                else {
                    self.boat.insert(rentedBoatModel, at: num)
                    self.boat[num].position = CGPoint(x: frame.width * (0.22 + CGFloat(count) * 0.3 ), y: frame.height * 0.25)
                    self.boat[num].name = "line4"
                }
                count += 1
                self.boat[num].zPosition = 5
                self.addChild(self.boat[num])
                self.boat[num].physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                self.boat[num].physicsBody?.affectedByGravity = true
                
            }
            
        }
        print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
        
        
    }
    
    
    
    func setInitBoat() {
        let mask = SKTexture(imageNamed: "boatMask01")
        self.boat.removeAll()
        for i in 0...(self.boatNum - 1) {
            let availabeBoatModel = SKSpriteNode(imageNamed: "boat2.png")
            self.boat.append(availabeBoatModel)
            self.boat[i].size = CGSize(width: frame.width * 0.25, height: frame.height * 0.05)
//            self.boat[i].name = "\(i)"
            
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
//            print("line1 = \(self.line1)  line2 = \(self.line2)")
            
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
        print("setSign: line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
        
        self.Num01 = SKLabelNode(fontNamed: "Baloo")
        self.Num01?.fontColor = .black
        self.Num01?.fontSize = 25
//        self.availableNum =
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
        print("boat num = \(self.boat.count)")
        
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
                print("key = \(num)")
            }
            
//            获取时间戳
//            let  timeInterval: TimeInterval  = DateInterval.timeIntervalSince1970
//            let  timeStamp =  Int (timeInterval)
            let timeStamp = Date().timeIntervalSince1970
            print("时间戳 = \(timeStamp)")
            
            
            
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
                    print("rent")
//                    更新数字
                    var lineList = dataStand.array(forKey: keyChain.line1) as! Array<Int>
                    
//                    lineList.remove(at: num)
                    if lineList.contains(num) {
//                        lineList.re
                        if let index = lineList.firstIndex(of: num){
                            lineList.remove(at: index)
                        }
                    }
//                    print("LineList = \(lineList.count)")
                    dataStand.set(lineList, forKey: keyChain.line1)
                    
//                    availableNum =
                    
                    
//                    self.rentedNum += 1
//                    self.Num02?.text = "\(self.rentedNum)"
                    
//                    销毁原精灵
                    sp.removeFromParent()
                    self.boat.remove(at: num)
                    
//                    创建新精灵
                    sp = SKSpriteNode(imageNamed: "person2.png")
                    sp.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.08)
//                    GameScene.line1 -= 1             // 该行 精灵个数 减一

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
                    
//                    创建物理体
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
                }
                
                else if sp.name == "line2" {
                    print("rent")
//                    self.availableNum -= 1
//                    self.rentedNum += 1
//                    self.Num01?.text = "\(self.availableNum)"
//                    self.Num02?.text = "\(self.rentedNum)"
                    
                    var lineList = dataStand.array(forKey: keyChain.line2) as! Array<Int>
//                    print("after var \(lineList.count)")
                    if lineList.contains(num) {
//                        lineList.re
                        if let index = lineList.firstIndex(of: num){
                            lineList.remove(at: index)
                        }
                    }
//                    lineList.remove(at:num)
//                    print("after remove \(lineList.count)")
                    dataStand.set(lineList, forKey: keyChain.line2)
                    
                    
//                    self.Num01?.text = "\(self.availableNum)"
                    
                    sp.removeFromParent()
                    self.boat.remove(at: num)
                    
                    sp = SKSpriteNode(imageNamed: "person2.png")
                    sp.size = CGSize(width: frame.width * 0.25, height: frame.height * 0.08)
//                    GameScene.line2 -= 1
                    
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
                    
//                    self.Num02?.text = "\(rentedNum)"
                    
                    
                    sp.zPosition = 5
                    self.addChild(sp)
                    self.boat.insert(sp, at: num)
                    
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
                }
                
//                MARK: ---> 写入开始时间 <---
                self.dataStand.set(timeStamp, forKey: "\(num)")
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let tmp1: Date = Date(timeIntervalSince1970: timeStamp)
                
                print("开始时间 = \(dateformatter.string(from: tmp1))")
                
                
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
                    print("givenBack")
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
                    
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
//                    MARK: -- 数据写入 --
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tmp1: Date = Date(timeIntervalSince1970: timeStamp)
                    
                    print("停止时间 = \(dateformatter.string(from: tmp1))")
                    
                    let startTime: Date = Date(timeIntervalSince1970: self.dataStand.double(forKey: "\(num)"))
                    let endTime: Date = Date(timeIntervalSince1970: timeStamp)
                    
                    print("start = \(dateformatter.string(from: startTime)); end = \(dateformatter.string(from: endTime))")
                    
                    let elapsedStamp = timeStamp - self.dataStand.double(forKey: "\(num)")
                    let elapsedTime: Date = Date(timeIntervalSince1970: elapsedStamp)
                    

                    print("elapsedTime = \(dateformatter.string(from: elapsedTime))")
                    
                    
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

                    let second = cal.component(.second, from: elapsedTime)
                    let minute = cal.component(.minute, from: elapsedTime)
                    let hour = cal.component(.hour, from: elapsedTime)

                    print("\(hour):\(minute):\(second)")
                    
                    print("hour = \(cal.component(.hour, from: Date(timeIntervalSince1970: timeStamp)))")
                    
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
                        print("Morning")
                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.morningAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
                    }
//                    下午
                    else {
                        let rentNum = self.dataStand.integer(forKey: keyChain.afternoonRentNum) + 1
                        self.dataStand.set(rentNum, forKey: keyChain.afternoonRentNum)
                        
                        var averageTime = self.dataStand.double(forKey: keyChain.afternoonAverageNum)
                        print("averageTime = \(averageTime)")
                        if averageTime == 0 {
                            self.dataStand.set(elapsedStamp, forKey: keyChain.afternoonAverageNum)
                        }
                        else{
                            averageTime = (averageTime * Double(rentNum - 1) + elapsedStamp) / Double(rentNum)
                            print("after/2: \(averageTime)")
                            self.dataStand.set(averageTime, forKey: keyChain.afternoonAverageNum)
                        }
                        
                        print("Afternoon")
                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.afternoonAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
                    }
                    
                }
                
                else if sp.name == "line4"{
//                    print("givenBack")
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
                    
                    let mask = SKTexture(imageNamed: "boatMask01")
                    sp.physicsBody = SKPhysicsBody(texture: mask, size: CGSize(width: frame.width * 0.3, height: frame.height * 0.1))
                    sp.physicsBody?.affectedByGravity = true
                    
                    updateLineNum()
                    self.Num01?.text = "\(self.availableNum)"
                    self.Num02?.text = "\(rentedNum)"
                    print("line1 = \(GameScene.line1) line2 = \(GameScene.line2) line3 = \(GameScene.line3) line4 = \(GameScene.line4)")
                    
//                    MARK: -- 数据写入 --
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tmp1: Date = Date(timeIntervalSince1970: timeStamp)
                    
                    print("停止时间 = \(dateformatter.string(from: tmp1))")
                    
                    let startTime: Date = Date(timeIntervalSince1970: self.dataStand.double(forKey: "\(num)"))
                    let endTime: Date = Date(timeIntervalSince1970: timeStamp)
                    
                    print("start = \(dateformatter.string(from: startTime)); end = \(dateformatter.string(from: endTime))")
                    
                    let elapsedStamp = timeStamp - self.dataStand.double(forKey: "\(num)")
                    let elapsedTime: Date = Date(timeIntervalSince1970: elapsedStamp)
                    

                    print("elapsedTime = \(dateformatter.string(from: elapsedTime))")
                    
                    
//                    MARK: ---- 数据 ----
                    let thisRent = rentInfo(boatIndex: num, elapsedTime: elapsedTime, startTime: startTime, endTime: endTime)
//                    print("run")
//                    print("thisRent  \(thisRent)")
//                    var rentArray = [thisRent]
//                    rentArray.append(thisRent)
//                    print("=========")
//                    print("rentArray = \(rentArray)")
//                    print("=========")
                    
                    

                    
//                    var updateList = self.dataStand.object(forKey: keyChain.rentList) as! Array<rentInfo>
                    
                    if (rentInfoCache.get() == nil){
                        rentInfoCache.save([thisRent])
                    }
                    else{
                        var updateList = rentInfoCache.get()!
                        updateList.append(thisRent)
                        rentInfoCache.save(updateList)
                    }
                    
//                    self.dataStand.set(updateList, forKey: keyChain.rentList)
                    
//                    print(updateList as! Array)
                    
                    
                    
                    
                    let cal = Calendar.current

                    let second = cal.component(.second, from: elapsedTime)
                    let minute = cal.component(.minute, from: elapsedTime)
                    let hour = cal.component(.hour, from: elapsedTime)

                    print("\(hour):\(minute):\(second)")
                    
                    print("hour = \(cal.component(.hour, from: Date(timeIntervalSince1970: timeStamp)))")
                    
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
                        print("Morning")
                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.morningAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
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
                        
                        print("Afternoon")
                        print("rentNum = \(rentNum)  averageTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.afternoonAverageNum))))  longestTime = \(dateformatter.string(from: Date(timeIntervalSince1970: self.dataStand.double(forKey: keyChain.longestRentTime))))")
                    }
                    
                    let tmp = rentInfoCache.get()!
                    print("========================")
                    for t in tmp{
                        print("num = \(String(describing: t.boatIndex!)) elapsedTime = \(t.elapsedTime!)")
//                        print(t.boatIndex!)
                        
//                        print(t)
                        print("-----------------------")
                    }
                    
                }
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        print(currentTime)
        if currentTime - updateTime >= 1{
            updateTime = currentTime
            updateClock()
        }

//        let dateformatter = DateFormatter()
//        dateformatter.dateFormat = "yyyy-MM-dd"
//        let cal = Calendar.current
//
//        if rentInfoCache.get() != nil {
//            let rentList = rentInfoCache.get()!
//            let lastRent = rentList.last?.startTime
////            print(lastRent)
//            if dateformatter.string(from: lastRent ?? Date()) != dateformatter.string(from: Date()){
//                print("run")
//                initData()
////                restoreBoat()
//            }
//
//
//
//        }

//        let year = cal.component(.year, from: Date())
//        let month = cal.component(.month, from: Date())
//        let day = cal.component(.day, from: Date())
//        let second = cal.component(.second, from: Date())
//        let minute = cal.component(.minute, from: Date())
//        let hour = cal.component(.hour, from: Date())
        
//        if (second == 0 && minute == 0 && hour == 0) {
//            initData()
//        }

    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
//        print("发生碰撞")
    }
}
