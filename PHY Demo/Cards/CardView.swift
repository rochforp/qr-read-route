//
//  CardView.swift
//  phy-browser
//
//  Created by john on 03/10/2017.
//  Copyright © 2017 com.bkon. All rights reserved.
//

import UIKit

enum CardStyle {
    case enhanced
    case streamlined
    case streamlined_favourite
    case text
    case developer
    case undefined
}

enum CardType {
    case beacons
    case qr
    case nfc
    case favourites
    case undefined
}

class CardView: UIView {
    
    var style: CardStyle = .undefined
    var type: CardType = .undefined
    
    var touchpoint: Touchpoint! {
        didSet {
            touchpointUpdated()
        }
    }
    
    var headerImageView: UIImageView!
    var overlayHeaderImageView: UIImageView!
    var titleTextLabel: UILabel!
    var descriptionTextLabel: UILabel!
    var favouritesButtonImageView: UIImageView!
    var dividerLineImageView: UIImageView!
    var footerTextLabel: UILabel!
    
    var contentHeaderImage: UIImage?
    var contentTitle: String?
    var contentDescription: String?
    
    var contentHeaderImageView: UIImageView?
    var contentTitleView: UITextView?
    var contentDescriptionView: UITextView?
    var favouriteButton: UIButton?
    
    var contentTitlePaddingSide: CGFloat { return 24 }
    var contentTitlePaddingBottom: CGFloat { return 0 }
    var contentTitlePaddingTop: CGFloat { return 12 }
    
    var contentDescriptionPaddingSide: CGFloat { return 24 }
    var contentDescriptionPaddingBottom: CGFloat { return 22 }
    var contentDescriptionPaddingTop: CGFloat { return 12 }
    var contentPaddingFooter: CGFloat { return 50 }
    
    var contentPaddingTop: CGFloat { return 12 }
    var contentPaddingBottom: CGFloat { return 32 }
    
    var contentCornerRadius: CGFloat { return 12 }
    
    var developerExtensionView: CardView!
    var hasDeveloperExtensionView = false
    
    var isPHYPlatform = true
    
    var associatedDate: Date!
    
    var swipeRightGestureRecogniser: UISwipeGestureRecognizer?
    var swipeLeftGestureRecogniser: UISwipeGestureRecognizer?
    
    var panX: CGFloat = 0.0
    var panY: CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func cardForStyle(_ type: CardStyle) -> CardView { // , frame: CGRect
        if type == .enhanced {
            let enhancedView = UINib(nibName: "CardEnhancedView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardEnhancedView
            return enhancedView
            //return CardEnhancedView(frame: frame)
        }
        else if type == .streamlined {
            let streamlinedView = UINib(nibName: "CardStreamlinedView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardStreamlinedView
            return streamlinedView
            //return CardStreamlinedView(frame: frame)
        }
        else if type == .streamlined_favourite {
            let streamlinedFavouriteView = UINib(nibName: "CardStreamlinedFavouriteView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardStreamlinedFavouriteView
            return streamlinedFavouriteView
        }
        /*else if type == .text {
            return CardTextView(frame: frame)
        }*/
        else if type == .developer {
            let developerView = UINib(nibName: "CardDevExtensionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardDevExtensionView
            return developerView
        }
        return CardEnhancedView()
    }
    
    class func defaultWidthForCardStyle(_ type: CardStyle) -> CGFloat {
        var cardWidth: CGFloat = 0
        if type == .enhanced {
            cardWidth = 300
        }
        else if type == .streamlined {
            cardWidth = 300
        }
        else if type == .streamlined_favourite {
            cardWidth = 300
        }
        else if type == .text {
            cardWidth = 300
         }
        else if type == .developer {
            cardWidth = 300
        }
        return cardWidth
    }
    
    func touchpointUpdated() {
        updateContent()
    }
    
    func updateContent() {}
    
    func enableDeveloperView() {}
    func disableDeveloperView() {}

    func removeItself() {
        removeFromSuperview()
    }
    
    func moveTo(point: CGPoint, animate: Bool) {
        if animate == true {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.3,
                           options: .curveEaseOut,
                           animations: {
                                self.frame.origin = point
                            },
                           completion: nil)
        }
        else {
            self.frame.origin = point
        }
    }
 
}

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}
