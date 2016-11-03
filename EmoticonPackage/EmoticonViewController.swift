//
//  EmoticonPageControllerView.swift
//  EmoticonPackageDemo
//
//  Created by Kevin on 11/3/16.
//  Copyright © 2016 SeeLee. All rights reserved.
//

import UIKit
import SnapKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
///屏幕与iPhone6的比例
let SCREENSCALE: CGFloat = SCREEN_WIDTH / CGFloat(375)

protocol EmoticonDelegate:class {
    
    func insertEmoticon(_ emoticon: Emoticon)
}

class EmoticonPageControllerView: UIView {
    
    fileprivate lazy var pageControl: UIPageControl = UIPageControl()
    
    var pageIndex:Int = 0{
        didSet {
            self.pageControl.currentPage = pageIndex
        }
    }
    
    var numberOfpages:Int = 0{
        didSet {
            self.pageControl.numberOfPages = numberOfpages
        }
    }

    init () {
        super.init(frame: CGRect.zero)
        self.prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func prepareUI() {
        
        self.addSubview(self.pageControl)
        self.backgroundColor = UIColor.clear
        self.pageControl.isEnabled = false
    }

    
    func setupPage(_ pages:Int) {
        
        self.pageControl.numberOfPages = pages
        
        self.pageControl.snp.remakeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(self)
        }

    }
}

class EmoticonToolButton:UIButton {

    override var intrinsicContentSize : CGSize {
        get {
            let size = super.intrinsicContentSize
            
            let newSize = CGSize(width:size.width + 30, height:size.height)
            
            return newSize
        }
    }
}

class EmoticonToolBar:UIView {

    lazy var mainScrollView:UIScrollView = UIScrollView()
    
    lazy var sendButton:UIButton = UIButton()
    
    fileprivate let baseTag = 1000
    fileprivate var selectedButton: UIButton?
    
    fileprivate var packages:[EmoticonPackage] = Array<EmoticonPackage>()
    
    var sendMessage:(()->())?

    var packageSwitch:((_ indexPath:IndexPath)->())?

    init(pg:[EmoticonPackage]) {
        
        super.init(frame: CGRect.zero)
        self.packages = pg
        self.prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func prepareUI() {
    
        self.backgroundColor = UIColor.white
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
    }
    
    // 准备UI
    func setupToolBar() {
        
        self.addSubview(self.mainScrollView)
        self.addSubview(sendButton)
        
        sendButton.setTitle("发送", for: UIControlState.normal)
        
        sendButton.backgroundColor = UIColor.blue
        sendButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
//        sendButton.backgroundColor = UIColor.clearColor()
//        sendButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Disabled)

        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(EmoticonToolBar.sendMessage(_:)), for: UIControlEvents.touchUpInside)

//        sendButton.enabled = true
        
        let verticalLine = UIView()
        verticalLine.backgroundColor = UIColor.gray
        self.addSubview(verticalLine)
        
        verticalLine.snp.makeConstraints { (make) in
            make.width.equalTo(1)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(sendButton.snp.left)
        }
        
        mainScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.left.equalTo(mainScrollView.snp.right)
            make.width.equalTo(70)
        }
        
        
        var items = [EmoticonToolButton]()
        // 按钮的tag
        var index = baseTag
        
        var lastBtn:EmoticonToolButton?
        // 获取表情包模型的名称
        for package in packages {

            // 获取每个表情包的名称
            let title = package.group_name_cn
            // 创建按钮
            let button = EmoticonToolButton()
            
            // 设置文字
            button.setTitle(title, for: UIControlState.normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            // 设置颜色
            button.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            button.setTitleColor(UIColor.darkGray, for: UIControlState.highlighted)
            button.setTitleColor(UIColor.darkGray, for: UIControlState.selected)
            button.backgroundColor = UIColor.white

            // 添加点击事件
            button.addTarget(self, action: #selector(EmoticonToolBar.itemClick(_:)), for: UIControlEvents.touchUpInside)
            // 设置tag
            button.tag = index
            
            // 最近按钮默认高亮
            if index == baseTag {
                switchSelectedButton(button)
            }
            
            // 添加item到数组
            items.append(button)
                        
            mainScrollView.addSubview(button)
            
            if let last = lastBtn {
                
                button.snp.makeConstraints({ (make) in
                    make.top.equalTo(mainScrollView)
                    make.left.equalTo(last.snp.right)
                    make.bottom.equalTo(mainScrollView)
//                    make.width.equalTo(60)
                    make.height.equalTo(mainScrollView)
                    
                    if (index - baseTag) >= packages.count - 1 {
                        make.right.equalTo(mainScrollView)
                    }
                })
            
            } else {
                //如果为第一个按钮
                button.snp.makeConstraints({ (make) in
                    make.top.equalTo(mainScrollView)
                    make.left.equalTo(mainScrollView)
                    make.bottom.equalTo(mainScrollView)
//                    make.width.equalTo(60)
                    make.height.equalTo(mainScrollView)
                })
            
            }
            
            lastBtn = button
            index += 1

        }
        
    }
    
    
    /**
     切换选中的按钮,让按钮高亮
     
     - parameter button: 要选中的按钮
     */
    fileprivate func switchSelectedButton(_ button: UIButton) {
        // 恢复原有
        selectedButton?.isSelected = false
        
        // 按钮选中
        button.isSelected = true
        
        // 赋值
        selectedButton = button
    }
    
    func itemClick(_ button: UIButton) {
        // 切换到对应的表情包的第一页表情
        let indexPath = IndexPath(item: 0, section: button.tag - baseTag)
        self.packageSwitch?(indexPath)
        
        switchSelectedButton(button)
    }
    
    func sendMessage(_ button: UIButton) {
        sendMessage?()
    }
    
    
}

class EmoticonViewController: UIViewController {
    
    // MARK: 属性
    
    weak var textView: EmoticonDelegate?
    
    fileprivate let ReuseIdentifier = "EmoticonCell"
    
    fileprivate let ReuseGifIdentifier = "EmoticonGifCell"

    /// 按钮的tag起始值
    fileprivate let baseTag = 1000
    
    /// 所有表情包模型
    fileprivate var packages:[EmoticonPackage] = Array<EmoticonPackage>()
    
    
    fileprivate let toolBarHeight:CGFloat = 37 * SCREENSCALE
    
    fileprivate let pageControllerHeight:CGFloat = 20
    
    fileprivate let planeHeight:CGFloat = 180 * SCREENSCALE
    
    typealias SendGifEmoticon = ((_ emoticon:Emoticon)->())
    
    var sendGifEmoticon:SendGifEmoticon?
    var sendMessage:(()->())?
    var ignoreGroup:[String]?
    
    //视图高度
    var viewHeight:CGFloat {
        
        get {
            return toolBarHeight + pageControllerHeight + planeHeight
        }
    }
    
    /// 构造方法
    init(textView: EmoticonDelegate) {
        self.textView = textView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.packages = preparePackages(ignoreGroup)
        prepareUI()
    }
    
    fileprivate func preparePackages(_ ig:[String]?) -> [EmoticonPackage] {
        
        let pk = EmoticonPackage.packages
        
        guard let ignore = ig else {
            return pk
        }
        
        var pkNew:[EmoticonPackage] = Array<EmoticonPackage>()
        
        for p in pk {
            // 判断是否忽略
            if let id = p.id , ignore.contains(id) {
                continue
            }
            pkNew.append(p)
        }
        
        return pkNew
    }
    
    // 准备UI
    fileprivate func prepareUI() {
        // 添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        view.addSubview(pageController)
        self.view.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        
        // 添加约束
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        toolBar.snp.makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(toolBarHeight)
        }
        
        pageController.snp.makeConstraints { (make) in
            make.bottom.equalTo(toolBar.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(pageControllerHeight)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.bottom.equalTo(pageController.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(planeHeight)
        }
        
        // 设置toolBar内容
        toolBar.setupToolBar()
        toolBar.packageSwitch = { [weak self] indexPath in
            
            guard let weak = self else {return}
            weak.collectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
            weak.pageController.numberOfpages = weak.packages[indexPath.section].pagenumbers
            weak.pageController.pageIndex = 0
        }
        toolBar.sendMessage = { [weak self] in
            guard let weak = self else {return}
            weak.sendMessage?()
        }
        
        var pages = 0
        if packages.count > 0 {
            pages = packages[0].pagenumbers
        }
        pageController.setupPage(pages)
        
        // 设置collectionView
        setupCollectionView()
    }

//    /**
//     切换选中的按钮,让按钮高亮
//     
//     - parameter button: 要选中的按钮
//     */
    fileprivate func switchSelectedButton(_ button: UIButton) {
        toolBar.switchSelectedButton(button)
    }
    
    
    /// 设置collectionView
    fileprivate func setupCollectionView() {
        // 设置背景
        collectionView.backgroundColor = UIColor.clear//UIColor(hex: 0xededed)
        
        // 注册cell
        collectionView.register(EmocitonCell.self, forCellWithReuseIdentifier: ReuseIdentifier)
        
        collectionView.register(EmocitonGifCell.self, forCellWithReuseIdentifier: ReuseGifIdentifier)
        
        // 数据源和代理
        collectionView.dataSource = self
        
        // 设置代理
        collectionView.delegate = self
    }
    
    // MARK: - 懒加载
    /// collectionView
    fileprivate lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmoticonLayout())
    
    /// toolBar
    fileprivate lazy var toolBar: EmoticonToolBar = EmoticonToolBar(pg:self.packages)
    
    fileprivate lazy var pageController: EmoticonPageControllerView = EmoticonPageControllerView()

}

// 自定义流水布局
class EmoticonLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        // collectionView水平滚动
        scrollDirection = UICollectionViewScrollDirection.horizontal
        //间距
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        // 取消弹簧效果
        collectionView?.bounces = false
        // 取消滚动条
        collectionView?.showsHorizontalScrollIndicator = false
        // 分页
        collectionView?.isPagingEnabled = true
    }
}

//MARK: - 代理
extension EmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let package = packages[(indexPath as NSIndexPath).section]
        
        return CGSize(width: collectionView.bounds.width / CGFloat(package.col), height: collectionView.bounds.height / CGFloat(package.row))
        
    }
    
    // 返回组
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    // 每一组
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 获取到每一组对应的表情包模型
        let package = packages[section]
        return package.emoticons.count
    }
    
    // 返回cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 获取表情包里面的表情
        let package = packages[(indexPath as NSIndexPath).section]
        
        let index = calculateRealIndex(indexPath)
        
        let emoticon = package.emoticons[index]

        if let _ = emoticon.gifPath , emoticon.type == "1" {
            
            let gifCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseGifIdentifier, for: indexPath) as! EmocitonGifCell
            // 设置cell的模型
            gifCell.emoticon = emoticon
            
            return gifCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier, for: indexPath) as! EmocitonCell
    
        // 设置cell的模型
        cell.emoticon = emoticon
        
        return cell
    }
    
    
    fileprivate func calculateRealIndex(_ indexPath: IndexPath) -> Int {
        
        let package = packages[(indexPath as NSIndexPath).section]

        let page = (indexPath as NSIndexPath).item / (package.col * package.row)
        
        let itemIdx = (indexPath as NSIndexPath).item - (package.col * package.row) * page
        
        // 横纵取反
        let row = itemIdx % package.row
        let col = itemIdx / package.row
        
        let index = row * package.col + col + (package.col * package.row) * page
        
        return index
    }
    
    // 监听collectionView停止滚动
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let items = collectionView.indexPathsForVisibleItems.sorted(by: { (old, new) -> Bool in
            
            return ((old as NSIndexPath).compare(new) == .orderedDescending)

        })

        let indexPath = items.first!
        
        // 按钮的tag是从1000(baseTag)开始的.
        let button = toolBar.viewWithTag((indexPath as NSIndexPath).section + baseTag) as! UIButton
        
        switchSelectedButton(button)
        
        self.pageController.numberOfpages = packages[(indexPath as NSIndexPath).section].pagenumbers
        
        let row = packages[(indexPath as NSIndexPath).section].row
        let col = packages[(indexPath as NSIndexPath).section].col

        let index = (indexPath as NSIndexPath).row / (row * col)
        
        self.pageController.pageIndex = index

    }
    
    /// cell被点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = calculateRealIndex(indexPath)
        
        let emoticon = packages[(indexPath as NSIndexPath).section].emoticons[index]

        
        if let _ = emoticon.gifPath , emoticon.type == "1" {
        
            self.sendGifEmoticon?(emoticon)
            return
        }
        
        // 插入表情
        textView?.insertEmoticon(emoticon)
//                // 最近表情列表不需要排序
//                if indexPath.section != 0
//                {
//                    // 添加到最近表情
//                    EmoticonPackage.addFavorate(emoticon)
//                }
        
    }
    
}

class EmocitonGifCell: EmocitonCell {
    
    override func prepareUI() {
        // 添加子控件
        contentView.addSubview(emoticonButton)
        
        //        emoticonButton.frame = CGRectInset(bounds, 6, 6)
        
        emoticonButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        emoticonButton.layer.masksToBounds = true
        // 禁止按钮可以和用户交互
        emoticonButton.isUserInteractionEnabled = false
        
        emoticonButton.snp.remakeConstraints { (make) in
            //                    make.center.equalTo(self)
            make.edges.equalTo(UIEdgeInsetsMake(10, 10, 10, 10))
        }
        
    }

}

// 自定义表情键盘的cell
class EmocitonCell: UICollectionViewCell {
    var emoticon: Emoticon? {
        didSet
        {
            
            // 如果是删除按钮,显示删除按钮图片
            let deletePath = EmoticonPackage.bundlePath + "/compose_emotion_delete.imageset/compose_emotion_delete.png"
            
            if emoticon!.removeEmoticon {
                emoticonButton.setImage(UIImage(contentsOfFile:deletePath), for: UIControlState())
                return
            }
            
            // 有png 略缩图优先使用png（gif也一样）
            if let pngPath = emoticon?.pngPath , !pngPath.isEmpty {
                
                emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.pngPath!), for: UIControlState())
                
                return
            }
            
            if let gifPath = emoticon?.gifPath , !gifPath.isEmpty && emoticon?.type == "1" {
                emoticonButton.setImage(UIImage(contentsOfFile: gifPath), for: UIControlState())
                
                return
            }
            

            
            if let emoji = emoticon?.emoji , !emoji.isEmpty {
                emoticonButton.setTitle(emoticon?.emoji, for: UIControlState())
                return
            }
            
            emoticonButton.setImage(nil, for: UIControlState())
  
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    // 准备UI
    fileprivate func prepareUI() {
        // 添加子控件
        contentView.addSubview(emoticonButton)
        
//        emoticonButton.frame = CGRectInset(bounds, 6, 6)
        
        emoticonButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        emoticonButton.layer.masksToBounds = true
        // 禁止按钮可以和用户交互
        emoticonButton.isUserInteractionEnabled = false
        
        emoticonButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(32)
            make.height.equalTo(32)
//            make.edges.equalTo(EdgeInsetsMake(5, left: 5, bottom: -5, right: -5))
        }
        
    }
    
    /// 按钮
    fileprivate lazy var emoticonButton = UIButton()
    
}
