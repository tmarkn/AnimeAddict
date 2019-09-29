//
//  CustomCell.swift
//  AnimeAddict
//
//  Created by Tony Mark on 4/15/19.
//  Copyright © 2019 Tony Mark. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    var mal_id: Int?
    var title: String?
    var mainImage: UIImage?
    var watching_status: Int?
    var score: Int?
    var watched_episodes: Int?
    var total_episodes: Int?
    var tags: String?
    
    var messageView: UITextField = {
        var textView = UITextField()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.font = UIFont(name: "HiraginoSans-W6", size: 14)
        return textView
    }()
    
    var mainImageView: UIImageView = {
        var imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFill
        imageview.layer.masksToBounds = true
        return imageview
    }()
    
    var plusButton: UIButton = {
        var button = pbutton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setTitle("+1", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .gray
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    var epCount: UITextField = {
        var epCView = UITextField()
        epCView.translatesAutoresizingMaskIntoConstraints = false
        epCView.isUserInteractionEnabled = false
        epCView.backgroundColor = .black
        epCView.textColor = .white
        epCView.font = UIFont(name: "HiraginoSans-W6", size: 10)
        return epCView
    }()
    
    var fullButton: UIButton = {
        var button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(fullView), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = cellColor
        self.addSubview(mainImageView)
        self.addSubview(messageView)
        self.addSubview(plusButton)
        self.addSubview(epCount)
        self.addSubview(fullButton)
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.layer.borderColor = bgColor.cgColor
        self.layer.borderWidth = 3
        
        mainImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mainImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        plusButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
        plusButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        plusButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
 
        messageView.leftAnchor.constraint(equalTo: self.mainImageView.rightAnchor, constant: 8).isActive = true
        messageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -60).isActive = true
        messageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 25).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        epCount.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        epCount.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        epCount.bottomAnchor.constraint(equalTo: self.plusButton.topAnchor).isActive = true
        epCount.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        fullButton.leftAnchor.constraint(equalTo: self.mainImageView.rightAnchor, constant: 8).isActive = true
        fullButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -60).isActive = true
        fullButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        fullButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let title = title {
            messageView.text = title
        }
        if let image = mainImage {
            mainImageView.image = image
        }
        if let watched = watched_episodes {
            if let total = total_episodes {
                epCount.text = String(format: "%d/%d", watched, total)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) jas not been implemented")
    }
    
    @objc func fullView(_ sender: UIButton) {
        let newImageView = UIImageView(image: mainImage)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        superview?.addSubview(newImageView)
        newImageView.frame = (superview?.superview?.bounds)!
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        newImageView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {newImageView.alpha = 1.0})
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {sender.view?.alpha = 0.0}) { (done:Bool) in
            sender.view?.removeFromSuperview()
        }
    }
    
    @objc func closeView(){
        
    }
    
    @objc func doUpdate(){
        
    }
}

class pbutton: UIButton{
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
        backgroundColor = .white
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
        backgroundColor = .gray
        super.touchesEnded(touches, with: event)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
        backgroundColor = .white
        super.touchesCancelled(touches, with: event)
    }
    
}
