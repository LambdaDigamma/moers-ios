//
//  CoreViewFactory.swift
//  
//
//  Created by Lennart Fischer on 25.04.22.
//

import UIKit
import MapKit
#if !os(tvOS)
import WebKit
#endif

public enum CoreViewFactory {
    
    public static func locationRowView() -> LocationRowView {
        
        let locationRowView = LocationRowView(location: "")
        
        locationRowView.translatesAutoresizingMaskIntoConstraints = false
        
        return locationRowView
        
    }
    
    public static func locationInformation() -> LocationInformationView {
        
        let locationInformation = LocationInformationView()
        
        locationInformation.translatesAutoresizingMaskIntoConstraints = false
        
        return locationInformation
        
    }
    
    public static func map() -> MKMapView {
        
        let map = MKMapView()
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
        
    }
    
    public static func blankView() -> UIView {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }
    
    public static func label() -> UILabel {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }
    
    public static func scrollView() -> UIScrollView {
        
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
        
    }
    
    public static func imageView() -> UIImageView {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }
    
    public static func button() -> UIButton {
        
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
        
    }
    
    public static func roundedButton() -> UIButton {
        
        let roundedButton = button()
        
        roundedButton.layer.cornerRadius = 5
        roundedButton.clipsToBounds = true
        roundedButton.setTitle("", for: .normal)
        roundedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return roundedButton
        
    }
    
    public static func stackView() -> UIStackView {
        
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }
    
    public static func tableView(with style: UITableView.Style = .plain) -> UITableView {
        
        let tableView = UITableView(frame: .zero, style: style)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        
        return tableView
        
    }
    
#if !os(tvOS)
    
    public static func searchBar() -> UISearchBar {
        
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
        
    }
    
#endif
    
    public static func progressView() -> UIProgressView {
        
        let progressView = UIProgressView()
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
        
    }
    
    public static func collectionView(layout: UICollectionViewLayout = UICollectionViewFlowLayout()) -> UICollectionView {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
        
    }
    
    public static func blurView() -> UIVisualEffectView {
        
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        return blurView
        
    }
    
    public static func textView() -> UITextView {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
        
    }
    
#if canImport(WKWebKit)
    
    public static func webView() -> WKWebView {
        
        let webView = WKWebView()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
        
    }
    
#endif
    
//    public static func paddingLabel() -> PaddingLabel {
//
//        let paddingLabel = PaddingLabel()
//
//        paddingLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        return paddingLabel
//
//    }

    public static func separatorView() -> SeparatorView {

        let separatorView = SeparatorView()

        separatorView.translatesAutoresizingMaskIntoConstraints = false

        return separatorView

    }

    public static func detailDisclosureView() -> DetailDisclosureView {

        let detailDisclosure = DetailDisclosureView()

        detailDisclosure.translatesAutoresizingMaskIntoConstraints = false

        return detailDisclosure

    }

//    public static func pageView(viewModel: PageViewModel? = nil) -> PageView {
//
//        let pageView = PageView(viewModel: viewModel)
//
//        pageView.translatesAutoresizingMaskIntoConstraints = false
//
//        return pageView
//
//    }
//
//    public static func spinner() -> UIActivityIndicatorView {
//
//        let activityIndicator = UIActivityIndicatorView()
//
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//
//        return activityIndicator
//
//    }
//
//    public static func videoPlayerView() -> VideoPlayerView {
//
//        let videoPlayerView = VideoPlayerView()
//
//        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
//
//        return videoPlayerView
//
//    }
    
}
