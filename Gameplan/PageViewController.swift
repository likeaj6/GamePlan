//
//  PageViewController.swift
//  flare.io
//
//  Created by Jason Jin on 11/30/16.
//  Copyright © 2016 Jason Jin. All rights reserved.
//

import UIKit
import CoreLocation

class EventCreationPageViewController: UIPageViewController {
    var eventDetails: [String] = []
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newEventCreationViewController(number: 1),
                self.newEventCreationViewController(number: 2),
                self.newEventCreationViewController(number: 3)]
    }()
    
    private func newEventCreationViewController(number: NSInteger) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "EventCreationPage\(number)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        //NotificationCenter.default.addObserver(self, selector: #selector(EventCreationPageViewController.setEventDetails(uid:coordinate:)), name: NSNotification.Name(rawValue: "saveEventLocally"), object: nil)
    }
    func setEventDetails() -> [String] {
        for vc in orderedViewControllers {
            eventDetails += vc.returnDetails()
        }
        print("\(eventDetails)")
        return eventDetails
    }
}

// MARK: UIPageViewControllerDataSource

extension EventCreationPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
}
