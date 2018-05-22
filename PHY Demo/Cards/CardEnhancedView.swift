//
//  CardEnhancedView.swift
//  phy-browser
//
//  Created by john on 03/10/2017.
//  Copyright © 2017 com.bkon. All rights reserved.
//

import UIKit

class CardEnhancedView: CardView, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style = .enhanced
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style = .enhanced
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style = .enhanced
        
        headerImageView = viewWithTag(1) as! UIImageView
        overlayHeaderImageView = viewWithTag(4) as! UIImageView
        titleTextLabel = viewWithTag(2) as! UILabel
        descriptionTextLabel = viewWithTag(3) as! UILabel
        favouritesButtonImageView = viewWithTag(5) as! UIImageView // 28 from bottom and right
        dividerLineImageView = viewWithTag(6) as! UIImageView // 50 from the bottom
        footerTextLabel = viewWithTag(7) as! UILabel // 13 from bottom, 24 from left
        
        self.layer.cornerRadius = contentCornerRadius
        // use our UIView extension rather than cornerRadius and masksToBounds in order to round just the top edges
        headerImageView.roundCorners([.topLeft, .topRight], radius: contentCornerRadius)
        
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
                let headerImage = touchpoint.headerImage
                let headerImageHeightScaled: CGFloat = (headerImageView.frame.size.width / headerImage!.size.width) * headerImage!.size.height
                // reset the mask
                headerImageView.layer.mask = nil
                headerImageView.image = headerImage
                // resize accordingly
                headerImageView.frame = CGRect(x: 0, y: 0, width: headerImageView.frame.size.width, height: headerImageHeightScaled)
                // reset the rounded corners
                headerImageView.roundCorners([.topLeft, .topRight], radius: 10)
                // adjust the overlay view width
                overlayHeaderImageView.frame = CGRect(x: 4, y: 4, width: headerImageView.frame.size.width - 8, height: headerImageHeightScaled > 30 ? 30 : headerImageHeightScaled)
            }
            
            if touchpoint.title != nil {
                titleTextLabel.text = touchpoint.title
                let titleHeight = titleTextLabel.text?.height(withConstrainedWidth: self.frame.size.width - (contentTitlePaddingSide * 2.0), font: titleTextLabel.font)
                // set the correctly sized frame
                titleTextLabel.frame = CGRect(x: contentTitlePaddingSide, y: headerImageView.frame.origin.y + headerImageView.frame.size.height + contentTitlePaddingTop, width: self.frame.size.width - (contentTitlePaddingSide * 2.0), height: titleHeight!)
            }
            
            if touchpoint.content != nil {
                descriptionTextLabel.text = touchpoint.content
                let descriptionHeight = descriptionTextLabel.text?.height(withConstrainedWidth: self.frame.size.width - (contentDescriptionPaddingSide * 2.0), font: descriptionTextLabel.font)
                // set the correctly sized frame
                descriptionTextLabel.frame = CGRect(x: contentDescriptionPaddingSide, y: titleTextLabel.frame.origin.y + titleTextLabel.frame.size.height + contentDescriptionPaddingTop, width: self.frame.size.width - (contentDescriptionPaddingSide * 2.0), height: descriptionHeight!)
            }
            
            if touchpoint.scanUrl != nil {
                footerTextLabel.text = touchpoint.scanUrl
            }
            
            // set the card's height now that the content has been sized
            let overallHeight = descriptionTextLabel.frame.origin.y + descriptionTextLabel.frame.size.height + contentPaddingBottom + contentPaddingFooter
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: overallHeight)
            
            // adjust the favourites button and divider line positions now that we have the height
            favouritesButtonImageView.frame = CGRect(x: frame.size.width - 28 - favouritesButtonImageView.frame.size.width, y: frame.size.height - 28 - favouritesButtonImageView.frame.size.height, width: 45, height: 45)
            dividerLineImageView.frame = CGRect(x: 0, y: self.frame.size.height - 50, width: self.frame.size.width, height: dividerLineImageView.frame.size.height)
            footerTextLabel.frame = CGRect(x: 24, y: self.frame.size.height - 13 - footerTextLabel.frame.size.height, width: footerTextLabel.frame.size.width, height: footerTextLabel.frame.size.height)
        }
    }
    
    override func enableDeveloperView() {
        hasDeveloperExtensionView = true
        developerExtensionView = CardView.cardForStyle(.developer)
        // put the view into place
        developerExtensionView.frame = CGRect(x: 0, y: headerImageView.frame.origin.y + headerImageView.frame.size.height, width: developerExtensionView.frame.size.width, height: developerExtensionView.frame.size.height)
        // and move these below the developer view
        titleTextLabel.frame = CGRect(x: contentTitlePaddingSide, y: developerExtensionView.frame.origin.y + developerExtensionView.frame.size.height + contentTitlePaddingTop, width: titleTextLabel.frame.size.width, height: titleTextLabel.frame.size.height)
        descriptionTextLabel.frame = CGRect(x: contentDescriptionPaddingSide, y: titleTextLabel.frame.origin.y + titleTextLabel.frame.size.height + contentDescriptionPaddingTop, width: descriptionTextLabel.frame.size.width, height: descriptionTextLabel.frame.size.height)
        // set the card's height now that the content has been sized
        let overallHeight = developerExtensionView.frame.size.height + descriptionTextLabel.frame.origin.y + descriptionTextLabel.frame.size.height + contentPaddingBottom + contentPaddingFooter
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: overallHeight)
        addSubview(developerExtensionView)
    }
    
    override func disableDeveloperView() {
        hasDeveloperExtensionView = false
        developerExtensionView.removeFromSuperview()
        developerExtensionView = nil
        // move these back into place
        titleTextLabel.frame = CGRect(x: contentTitlePaddingSide, y: headerImageView.frame.origin.y + headerImageView.frame.size.height + contentTitlePaddingTop, width: titleTextLabel.frame.size.width, height: titleTextLabel.frame.size.height)
        descriptionTextLabel.frame = CGRect(x: contentDescriptionPaddingSide, y: titleTextLabel.frame.origin.y + titleTextLabel.frame.size.height + contentDescriptionPaddingTop, width: descriptionTextLabel.frame.size.width, height: descriptionTextLabel.frame.size.height)
        // set the card's height now that the content has been sized
        let overallHeight = descriptionTextLabel.frame.origin.y + descriptionTextLabel.frame.size.height + contentPaddingBottom
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: overallHeight)
    }
    
}
