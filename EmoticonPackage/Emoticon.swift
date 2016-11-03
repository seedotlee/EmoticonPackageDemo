//
//  EmoticonPackage.swift
//  EmoticonPackageDemo
//
//  Created by Kevin on 11/3/16.
//  Copyright © 2016 SeeLee. All rights reserved.
//

import UIKit

/// 表情包模型
class EmoticonPackage: NSObject
{
    
    // 表情包对应的文件夹名称
    var id: String?
    
    // 表情包名称
    var group_name_cn: String?
    // 分组图片类型 0：png，1：gif
    var group_type: Int = 0

    var row:Int = 3
    
    var col:Int = 7
    
    var canDelete:Bool = true
    // 表情模型数组
    var emoticons = [Emoticon]()
    
    // 计算当前package的总页数
    var pagenumbers:Int {
        
        get {
            
            return emoticons.count / (row * col)
        }
    }
    
    var currentPageIndex:Int {
        get {
            
            return 0
        }
    }
    
    /// 字典转模型
    init(id: String)
    {
        self.id = id
        super.init()
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    // 获取Emoticons.bundle的路径
    static let bundlePath = Bundle.main.path(forResource: "Emoticons", ofType: "bundle")!
    
    /// 静态属性,保存表情包模型数据, 只会加载一次
    static let packages = EmoticonPackage.loadPackages()
    
    // 加载表情包
    static func loadPackages() -> [EmoticonPackage] {
        // 获取 emoticons.plist的路径
        let plistPath =  (bundlePath as NSString).appendingPathComponent("emoticons.plist")
        
        // 获取 emoticons.plist 内容
        let emoticonsDict = NSDictionary(contentsOfFile: plistPath)!
        
        // 获取表情包文件夹名称
        let packageArr = emoticonsDict["packages"] as! [[String: AnyObject]]
        
        // 存放表情包模型的数组
        var packages = [EmoticonPackage]()
        
//        // 创建 `最近` 表情包
//        let recentPackage = EmoticonPackage(id: "")
//        
//        // 设置表情包名称
//        recentPackage.group_name_cn = "最近"
//        
//        // 追加空表情和一个删除按钮
//        recentPackage.appendEmptyEmoticon()
//        
//        // 添加到表情包
//        packages.append(recentPackage)
        
        // 遍历获取每一个表情包文件名称
        for dict in packageArr {
            // 获取id
            let id = dict["id"] as! String
            
            // 创建表情包
            let package = EmoticonPackage(id: id)
            
            // 根据当前表情包模型,加载表情包名称和所有的表情模型
            package.loadEmoticon()
            
            packages.append(package)
        }
        
        // 返回加载到的表情包模型
        return packages
    }
    
    /// 根据当前表情包模型,加载表情包名称和所有的表情模型
    func loadEmoticon() {
        
        let infoPlist = EmoticonPackage.bundlePath + "/\(id!)" + "/emotion_info.plist"
        
        // 把infoPlist的内容加载到内存
        let infoDict = NSDictionary(contentsOfFile: infoPlist)!
        
        // 获取到表情包名称
        group_name_cn = infoDict["group_name_cn"] as? String
        
        row = infoDict["row"] as? Int ?? 3
        
        col = infoDict["col"] as? Int ?? 7
        
        group_type = infoDict["group_type"] as? Int ?? 0

        canDelete = infoDict["canDelete"] as? Bool ?? true

        // 获取表情包里面的所有表情模型
        let emoticonArr = infoDict["emoticons"] as! [[String: AnyObject]]
        
        // 记录
        var index = 0
        
        // 遍历 emoticonArr 数组,生成表情模型
        for dict in emoticonArr
        {
            let emoticon = Emoticon(id: id!, dict: dict)
            emoticons.append(emoticon)
            
            index += 1
            
            //添加删除按钮
            if index == (row * col - 1) && canDelete
            {
                // 创建删除按钮
                let removeEmoticon = Emoticon(removeEmoticon: true)
                
                // 添加到表情模型数组
                emoticons.append(removeEmoticon)
                
                // 清空index
                index = 0
            }
        }
        
        //填充空白按钮
        appendEmptyEmoticon(row,col:col,canDelete:canDelete)
    }
    
    /// 填充空白按钮,并在最后添加一个删除按钮
    func appendEmptyEmoticon(_ row:Int = 3,col:Int = 7,canDelete:Bool = true) {
        
        let count = emoticons.count % (row * col)
        
        if count > 0 || emoticons.count == 0 {
            
            // 追加按钮
            for _ in count..<(row * col - 1) {
                // 创建空白按钮模型
                let emptyEmoticon = Emoticon(removeEmoticon: false)
                // 添加到表情模型数组
                emoticons.append(emptyEmoticon)
            }
            
            if canDelete {
                
                emoticons.append(Emoticon(removeEmoticon: true))

            } else {
                
                // 创建空白按钮模型
                let emptyEmoticon = Emoticon(removeEmoticon: false)
                // 添加到表情模型数组
                emoticons.append(emptyEmoticon)
            }
            
        }
    }
    
    /*
     最近表情包,永远都只有10个表情,而且最后一个是删除按钮,表情需要按使用次数,多的排在前面
     */
    static func addFavorate(_ emoticon: Emoticon) {
        // 如果是删除按钮不需要添加
        if emoticon.removeEmoticon {
            return
        }
        
        // 如果是空白按钮不需要添加
        if emoticon.pngPath == nil && emoticon.emoji == nil {
            return
        }
        //使用次数
        emoticon.times += 1
        
        var recentEmoticons = packages[0].emoticons
        
        // 先移除删除按钮
        let removeEmoticon = recentEmoticons.removeLast()
        
        // 判断重复添加
        let contains = recentEmoticons.contains(emoticon)
        
        // 不重复才需要添加
        if !contains {
            // 添加表情模型
            recentEmoticons.append(emoticon)
        }
        
        // 排序
        recentEmoticons = recentEmoticons.sorted { (e1, e2) -> Bool in
            // 使用次数多得排在前面
            return e1.times > e2.times
        }
        
        if !contains {
            // 移除最后一个
            recentEmoticons.removeLast()
        }
        
        // 将删除按钮添加回去
        recentEmoticons.append(removeEmoticon)
        
        // 赋值数组
        packages[0].emoticons = recentEmoticons
    }
    
    /**
     根据文字查找emoj对象
     
     - parameter chs:
     
     - returns:
     */
    static func findEmoticon(_ chs:String) -> Emoticon? {
        
        for package in packages {
            
            for emoticon in package.emoticons {
                
                if emoticon.chs == chs {
                    return emoticon
                }
                
            }
            
        }
        
        return nil
    }
}

/// 表情模型
class Emoticon: NSObject {
    // 表情包文件夹名称
    var id: String?
    
    // 表情传输名称
    var chs: String?
    
    // 表情对应的图片
    var png: String? {
        didSet
        {
            if let id = id ,let png = png , !png.isEmpty && !id.isEmpty {
                // 计算图片的完整路径
                pngPath = EmoticonPackage.bundlePath + "/\(id)" + "/\(png)"
            }

        }
    }
    
    // 表情对应的图片
    var gif: String? {
        didSet
        {
            if let id = id ,let gif = gif , !gif.isEmpty && !id.isEmpty {
                // 计算图片的完整路径
                gifPath = EmoticonPackage.bundlePath + "/\(id)" + "/\(gif)"
            }
        }
    }
    
    // 图片类型
    var type: String?
    // 图片的完整路径
    var pngPath: String?
    // gif完整路径
    var gifPath: String?
    
    // code emoji的16进制字符串
    var code: String? {
        didSet {
            // 扫描
            let scanner = Scanner(string: code!)
            
            var result: UInt32 = 0
            
            // 将结果赋值给result
            scanner.scanHexInt32(&result)
            
            let char = Character(UnicodeScalar(result)!)
            
            // 将code转成emoji表情
            emoji = "\(char)"
        }
    }
    
    // emoji表情
    var emoji: String?
    
    // 使用次数
    var times = 0
    
    // false表示空表情, true表示删除按钮
    var removeEmoticon = false
    // 构造方法
    init(removeEmoticon: Bool) {
        self.removeEmoticon = removeEmoticon
        
        super.init()
    }
    
    /// 字典转模型
    init(id: String, dict: [String: AnyObject]) {
        self.id = id
        
        super.init()
        // KVC字典转模型
        setValuesForKeys(dict)
    }
    
    // kvc找不到对应的属性-空实现
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
}
