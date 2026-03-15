//
//  DrawerViewController+PullyDrawer.swift
//  moers festival
//
//  Created by Lennart Fischer on 25.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import Pulley

extension DrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        
        let height = drawer.mapViewController.map.frame.height
        
        if drawer.currentDisplayMode == .panel {
            return height - 49.0 - 16.0 - 16.0 - 64.0 - 50.0 - 16.0
        }
        
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        
        if drawer.currentDisplayMode == .panel {
            
            self.gripperView.isHidden = true
            
            return [PulleyPosition.partiallyRevealed]
        }
        
        return PulleyPosition.all
        
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
        
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
        }
        
        if drawer.currentDisplayMode == .panel {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeparatorView.isHidden = drawer.drawerPosition == .collapsed
        } else {
            topSeparatorView.isHidden = false
            bottomSeparatorView.isHidden = true
        }
        
    }
    
}
