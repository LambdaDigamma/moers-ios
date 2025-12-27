//
//  PulleyViewController+UIScrollViewDelegate.swift
//  CityOS
//
//  Created by Lennart Fischer on 27.12.25.
//


import UIKit

extension PulleyViewController: UIScrollViewDelegate {

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        
        if scrollView == drawerScrollView {
            // Find the closest anchor point and snap there.
            var collapsedHeight:CGFloat = kPulleyDefaultCollapsedHeight
            var partialRevealHeight:CGFloat = kPulleyDefaultPartialRevealHeight
            
            if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
                collapsedHeight = drawerVCCompliant.collapsedDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultCollapsedHeight
                partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultPartialRevealHeight
            }

            var drawerStops: [CGFloat] = [CGFloat]()
            var currentDrawerPositionStop: CGFloat = 0.0
            
            if supportedPositions.contains(.open) {
                drawerStops.append(heightOfOpenDrawer)
                
                if drawerPosition == .open {
                    currentDrawerPositionStop = drawerStops.last!
                }
                
            }
            
            if supportedPositions.contains(.partiallyRevealed) {
                
                drawerStops.append(partialRevealHeight)
                
                if drawerPosition == .partiallyRevealed {
                    currentDrawerPositionStop = drawerStops.last!
                }
                
            }
            
            if supportedPositions.contains(.collapsed) {
                drawerStops.append(collapsedHeight)
                
                if drawerPosition == .collapsed {
                    currentDrawerPositionStop = drawerStops.last!
                }
            }
            
            let lowestStop = drawerStops.min() ?? 0
            
            let distanceFromBottomOfView = lowestStop + lastDragTargetContentOffset.y
            
            var currentClosestStop = lowestStop
            
            for currentStop in drawerStops {
                if abs(currentStop - distanceFromBottomOfView) < abs(currentClosestStop - distanceFromBottomOfView) {
                    currentClosestStop = currentStop
                }
            }
            
            var closestValidDrawerPosition: PulleyPosition = drawerPosition
            
            if abs(Float(currentClosestStop - heightOfOpenDrawer)) <= Float.ulpOfOne && supportedPositions.contains(.open) {
                closestValidDrawerPosition = .open
            } else if abs(Float(currentClosestStop - collapsedHeight)) <= Float.ulpOfOne && supportedPositions.contains(.collapsed) {
                closestValidDrawerPosition = .collapsed
            } else if supportedPositions.contains(.partiallyRevealed) {
                closestValidDrawerPosition = .partiallyRevealed
            }
            
            let snapModeToUse: PulleySnapMode = closestValidDrawerPosition == drawerPosition ? snapMode : .nearestPosition
            
            switch snapModeToUse {
                
            case .nearestPosition:
                
                setDrawerPosition(position: closestValidDrawerPosition, animated: true)
                
            case .nearestPositionUnlessExceeded(let threshold):
                
                let distance = currentDrawerPositionStop - distanceFromBottomOfView
                
                var positionToSnapTo: PulleyPosition = drawerPosition

                if abs(distance) > threshold
                {
                    if distance < 0
                    {
                        let orderedSupportedDrawerPositions = supportedPositions.sorted(by: { $0.rawValue < $1.rawValue }).filter({ $0 != .closed })

                        for position in orderedSupportedDrawerPositions
                        {
                            if position.rawValue > drawerPosition.rawValue
                            {
                                positionToSnapTo = position
                                break
                            }
                        }
                    }
                    else
                    {
                        let orderedSupportedDrawerPositions = supportedPositions.sorted(by: { $0.rawValue > $1.rawValue }).filter({ $0 != .closed })
                        
                        for position in orderedSupportedDrawerPositions
                        {
                            if position.rawValue < drawerPosition.rawValue
                            {
                                positionToSnapTo = position
                                break
                            }
                        }
                    }
                }
                
                setDrawerPosition(position: positionToSnapTo, animated: true)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == drawerScrollView {
            self.isChangingDrawerPosition = true
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        prepareFeedbackGenerator()

        if scrollView == drawerScrollView
        {
            lastDragTargetContentOffset = targetContentOffset.pointee
            
            // Halt intertia
            targetContentOffset.pointee = scrollView.contentOffset
            self.isChangingDrawerPosition = false
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == drawerScrollView
        {
            let partialRevealHeight: CGFloat = (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.partialRevealDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultPartialRevealHeight

            let lowestStop = getStopList().min() ?? 0
            
            if (scrollView.contentOffset.y - pulleySafeAreaInsets.bottom) > partialRevealHeight - lowestStop && supportedPositions.contains(.open)
            {
                // Calculate percentage between partial and full reveal
                let fullRevealHeight = heightOfOpenDrawer
                let progress: CGFloat
                if fullRevealHeight == partialRevealHeight {
                    progress = 1.0
                } else {
                    progress = (scrollView.contentOffset.y - (partialRevealHeight - lowestStop)) / (fullRevealHeight - (partialRevealHeight))
                }

                delegate?.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: pulleySafeAreaInsets.bottom)
                (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: pulleySafeAreaInsets.bottom)
                (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: pulleySafeAreaInsets.bottom)
                
                backgroundDimmingView.alpha = progress * backgroundDimmingOpacity
                
                backgroundDimmingView.isUserInteractionEnabled = true
            }
            else
            {
                if backgroundDimmingView.alpha >= 0.001
                {
                    backgroundDimmingView.alpha = 0.0
                    
                    delegate?.makeUIAdjustmentsForFullscreen?(progress: 0.0, bottomSafeArea: pulleySafeAreaInsets.bottom)
                    (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0, bottomSafeArea: pulleySafeAreaInsets.bottom)
                    (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0, bottomSafeArea: pulleySafeAreaInsets.bottom)
                    
                    backgroundDimmingView.isUserInteractionEnabled = false
                }
            }
            
            delegate?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
            (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
            (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
            
            // Move backgroundDimmingView to avoid drawer background beeing darkened
            backgroundDimmingView.frame = backgroundDimmingViewFrameForDrawerPosition(scrollView.contentOffset.y + lowestStop)
            
            syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode()
        }
    }
}
