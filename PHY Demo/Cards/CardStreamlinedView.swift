//
//  CardStreamlinedView.swift
//  phy-browser
//
//  Created by john on 03/10/2017.
//  Copyright © 2017 com.bkon. All rights reserved.
//

import UIKit

class CardStreamlinedView: CardView, UIGestureRecognizerDelegate {
    
    var contentBackgroundView: UIView!
    
    override var contentTitlePaddingSide: CGFloat { return 20 }
    override var contentTitlePaddingBottom: CGFloat { return 0 }
    override var contentTitlePaddingTop: CGFloat { return 20 }
    
    override var contentDescriptionPaddingSide: CGFloat { return 20 }
    override var contentDescriptionPaddingBottom: CGFloat { return 22 }
    override var contentDescriptionPaddingTop: CGFloat { return 8 }
    
    var contentBackgroundDefaultWidth: CGFloat = 200
    var contentBackgroundDefaultHeight: CGFloat = 365

    override init(frame: CGRect) {
        super.init(frame: frame)
        style = .streamlined
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style = .streamlined
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style = .streamlined
        
        headerImageView = viewWithTag(1) as! UIImageView
        titleTextLabel = viewWithTag(2) as! UILabel
        descriptionTextLabel = viewWithTag(3) as! UILabel
        contentBackgroundView = viewWithTag(4)
        
        self.layer.cornerRadius = contentCornerRadius
        // use our UIView extension rather than cornerRadius and masksToBounds in order to round certain edges
        headerImageView.roundCorners([.topLeft, .bottomLeft], radius: contentCornerRadius)
        contentBackgroundView.roundCorners([.topRight, .bottomRight, .bottomLeft], radius: contentCornerRadius)
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(CardEnhancedView.handleTap))
        //tap.delegate = self
        //addGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        NotificationCenter.default.post(name:Notification.Name(rawValue: "CardTapped"),
                                        object: nil,
                                        userInfo: ["card": self])
    }
    
    override func updateContent() {
        if touchpoint != nil {
            
            if touchpoint.headerImage != nil {
                // reset the mask
                headerImageView.layer.mask = nil
                headerImageView.image = touchpoint.headerImage
                // correct size and location
                headerImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                // reset the rounded corners
                headerImageView.roundCorners([.topLeft, .bottomLeft], radius: 10)
            }
            
            // setup the background view with default positions
            contentBackgroundView.frame = CGRect(x: headerImageView.frame.size.width, y: 0, width: contentBackgroundDefaultWidth, height: contentBackgroundDefaultHeight)
            contentBackgroundView.layer.mask = nil
            
            if touchpoint.title != nil {
                titleTextLabel.text = touchpoint.title
                let titleHeight = titleTextLabel.text?.height(withConstrainedWidth: contentBackgroundView.frame.size.width - (contentTitlePaddingSide * 2.0), font: titleTextLabel.font)
                // set the correctly sized frame
                titleTextLabel.frame = CGRect(x: contentBackgroundView.frame.origin.x + contentTitlePaddingSide, y: contentTitlePaddingTop, width: contentBackgroundView.frame.size.width - (contentTitlePaddingSide * 2.0), height: titleHeight!)
            }
            
            if touchpoint.content != nil {
                descriptionTextLabel.text = touchpoint.content
                let descriptionHeight = descriptionTextLabel.text?.height(withConstrainedWidth: contentBackgroundView.frame.size.width - (contentDescriptionPaddingSide * 2.0), font: descriptionTextLabel.font)
                // set the correctly sized frame
                descriptionTextLabel.frame = CGRect(x: contentBackgroundView.frame.origin.x + contentDescriptionPaddingSide, y: titleTextLabel.frame.origin.y + titleTextLabel.frame.size.height + contentDescriptionPaddingTop, width: contentBackgroundView.frame.size.width - (contentDescriptionPaddingSide * 2.0), height: descriptionHeight!)
            }
            // set the card's height now that the content has been sized
            let overallHeight = descriptionTextLabel.frame.origin.y + descriptionTextLabel.frame.size.height + contentPaddingBottom
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: overallHeight)
            contentBackgroundView.frame = CGRect(x: headerImageView.frame.size.width, y: 0, width: contentBackgroundView.frame.size.width, height: overallHeight)
            contentBackgroundView.roundCorners([.topRight, .bottomRight, .bottomLeft], radius: contentCornerRadius)
        }
    }
}
