//
//  CardDevExtensionView.swift
//  phy-browser
//
//  Created by john on 03/10/2017.
//  Copyright © 2017 com.bkon. All rights reserved.
//

import UIKit

class CardDevExtensionView: CardView {
    
    var descriptionTextView: UITextView!
    
    override var contentPaddingBottom: CGFloat { return 24 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style = .developer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style = .developer
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        style = .developer
        
        titleTextLabel = viewWithTag(6) as! UILabel
        descriptionTextView = viewWithTag(7) as! UITextView
        // we don't need no padding
        let padding = descriptionTextView.textContainer.lineFragmentPadding
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(0, -padding, 0, -padding)
    }
    
    override func updateContent() {
        if touchpoint != nil {
            
            let robotoLightAttributes: [NSAttributedStringKey: Any] = [.font: UIFont(name: "Roboto-Light", size: 13)!, .foregroundColor: UIColor.white]
            let robotoBoldAttributes: [NSAttributedStringKey: Any] = [.font: UIFont(name: "Roboto-Bold", size: 13)!, .foregroundColor: UIColor.white]
            let developerContent = NSMutableAttributedString()
            
            descriptionTextView.font = UIFont(name: "Roboto-Bold", size: 13)!
            
            developerContent.append(NSAttributedString(string: "Touchpoint Type: ", attributes: robotoBoldAttributes))
            developerContent.append(NSAttributedString(string: touchpoint.type.rawValue + "\r\n", attributes: robotoLightAttributes))
            
            if touchpoint.rssi != nil {
                developerContent.append(NSAttributedString(string: "RSSI: ", attributes: robotoBoldAttributes))
                developerContent.append(NSAttributedString(string: touchpoint.rssi, attributes: robotoLightAttributes))
            }
            if touchpoint.txPower != nil {
                developerContent.append(NSAttributedString(string: " TX Power: ", attributes: robotoBoldAttributes))
                developerContent.append(NSAttributedString(string: touchpoint.txPower + "\r\n", attributes: robotoLightAttributes))
            }
            if touchpoint.scanUrl != nil {
                developerContent.append(NSAttributedString(string: "Scan URL: ", attributes: robotoBoldAttributes))
                developerContent.append(NSAttributedString(string: touchpoint.scanUrl + "\r\n", attributes: robotoLightAttributes))
            }
            if touchpoint.destinationUrl != nil {
                developerContent.append(NSAttributedString(string: "Destination URL: ", attributes: robotoBoldAttributes))
                developerContent.append(NSAttributedString(string: touchpoint.destinationUrl, attributes: robotoLightAttributes))
            }
            
            descriptionTextView.attributedText = developerContent
            let descriptionHeight = descriptionTextView.text?.height(withConstrainedWidth: self.frame.size.width - (contentDescriptionPaddingSide * 2.0), font: UIFont(name: "Roboto-Bold", size: 13)!)
            
            // set the text view's height now that we have the text
            descriptionTextView.frame = CGRect(x: descriptionTextView.frame.origin.x, y: descriptionTextView.frame.origin.y, width: self.frame.size.width - (contentDescriptionPaddingSide * 2.0), height: descriptionHeight!)
            
            // set the card's height now that the content has been sized
            let overallHeight = descriptionTextView.frame.origin.y + descriptionTextView.frame.size.height + contentPaddingBottom
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: overallHeight)
        }
    }
}
