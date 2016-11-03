//
//  ViewController.swift
//  EmoticonPackageDemo
//
//  Created by Kevin on 11/3/16.
//  Copyright © 2016 SeeLee. All rights reserved.
//

import UIKit
import EmoticonPackage

class ViewController: UIViewController {
    
    private lazy var textView:UITextView = {
        let tv = UITextView(frame: CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: 100))
        return tv
    }()
    
    private lazy var button:UIButton = {
        let bt = UIButton(frame: CGRect(x: 50, y: 130, width: SCREEN_WIDTH - 100, height: 40))
        bt.setTitle("隐藏Emoticon", for: UIControlState.normal)
        bt.setTitle("显示Emoticon", for: UIControlState.selected)
        bt.setTitleColor(UIColor.white, for: UIControlState.normal)
        bt.setTitleColor(UIColor.white, for: UIControlState.selected)
        bt.backgroundColor = UIColor.gray
        bt.addTarget(self, action: #selector(ViewController.buttonClick(_:)), for: UIControlEvents.touchUpInside)
        return bt
    }()

    private lazy var emoticonVC: EmoticonViewController = EmoticonViewController(textView: self.textView)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(textView)
        self.view.addSubview(button)
        setupEmoticon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonClick(_ sender:AnyObject) {
    
        if self.button.isSelected {
            showEmoticon()
        } else {
            closeEmoticon()
        }
    }
    
    private func setupEmoticon() {
        
        self.emoticonVC.sendGifEmoticon = { [weak self] emoticon in
            guard let weak = self else {return}

            if let text = emoticon.chs {
                print("gif emoticon:\(text)")
            }
        }
        
        self.emoticonVC.sendMessage = { [weak self] in
            
            guard let weak = self else {return}
            
            if let tempText = weak.textView.text {
                print("send:\(tempText)")
            }
            
        }
        
        self.addChildViewController(self.emoticonVC)
        self.view.addSubview(self.emoticonVC.view)
        
        self.emoticonVC.view.frame = CGRect(x: 0, y: self.view.frame.height - self.emoticonVC.viewHeight, width: self.view.frame.width, height: self.emoticonVC.viewHeight)
    }
    
    
    func showEmoticon() {
        
        self.emoticonVC.view.isHidden = false
        self.button.isSelected = false
        
        UIView.animate(withDuration: 0.2,
        animations: {
                                    
            let center = self.emoticonVC.view.center
            self.emoticonVC.view.center = CGPoint(x:center.x, y:self.view.frame.height - self.emoticonVC.viewHeight*0.5)
            
        },
        completion: { result in
        })
        
    }
    
    func closeEmoticon() {
        
        self.button.isSelected = true

        UIView.animate(withDuration: 0.2,
        animations: {
                                    
            let center = self.emoticonVC.view.center
            self.emoticonVC.view.center = CGPoint(x:center.x, y:self.view.frame.height + self.emoticonVC.viewHeight)
            
        },
        completion: { result in
            self.emoticonVC.view.isHidden = true
        })
        
    }

}

