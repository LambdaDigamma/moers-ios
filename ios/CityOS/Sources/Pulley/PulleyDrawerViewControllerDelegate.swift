//
//  PulleyDrawerViewControllerDelegate.swift
//  CityOS
//
//  Created by Lennart Fischer on 27.12.25.
//


import UIKit

/**
 *  View controllers in the drawer can implement this to receive changes in state or provide values for the different drawer positions.
 */
@objc public protocol PulleyDrawerViewControllerDelegate: PulleyDelegate {
    
    /**
     *  Provide the collapsed drawer height for Pulley. Pulley does NOT automatically handle safe areas for you, however: bottom safe area is provided for your convenience in computing a value to return.
     */
    @objc optional func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    
    /**
     *  Provide the partialReveal drawer height for Pulley. Pulley does NOT automatically handle safe areas for you, however: bottom safe area is provided for your convenience in computing a value to return.
     */
    @objc optional func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    
    /**
     *  Return the support drawer positions for your drawer.
     */
    @objc optional func supportedDrawerPositions() -> [PulleyPosition]
}