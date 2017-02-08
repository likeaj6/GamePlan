//
//  EventDetailViewController.swift
//  Gameplan
//
//  Created by Jason Jin on 1/19/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    lazy var lblTitle:UILabel = {
        let ln = UILabel(frame: CGRect(x: 0, y: 90, width: self.width, height: self.labelHeight))
        ln.numberOfLines = 1
        ln.adjustsFontSizeToFitWidth = true
        ln.clipsToBounds = true
        ln.backgroundColor = .clear
        ln.textColor = .black
        ln.textAlignment = NSTextAlignment.center
        return ln
    }()
    
    lazy var lblLocation:UILabel = {
        let la  = UILabel(frame: CGRect(x: 0, y: 135, width: self.width, height: self.labelHeight))
        la.numberOfLines = 1
        la.adjustsFontSizeToFitWidth = true
        la.clipsToBounds = true
        la.backgroundColor = .clear
        la.textColor = .black
        la.textAlignment = NSTextAlignment.center
        return la
    }()
    
    lazy var lblDescription: UILabel = {
        let c = UILabel(frame: CGRect(x: 0, y: 180, width: self.width, height: self.labelHeight))
        c.numberOfLines = 1
        c.adjustsFontSizeToFitWidth = true
        c.clipsToBounds = true
        c.backgroundColor = .clear
        c.textColor = .black
        c.textAlignment = NSTextAlignment.center
        return c
    }()
    
    var navHeight:CGFloat { return 0.0 }
    var width:CGFloat { return self.view.bounds.size.width }
    var halfHeight:CGFloat { return (self.height - self.navHeight)/2 }
    var height:CGFloat { return self.view.bounds.size.height}
    var labelHeight:CGFloat { return 40.0 }
    
    
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.lblTitle)
        self.view.addSubview(self.lblLocation)
        self.view.addSubview(self.lblDescription)
        
        
    }
}
