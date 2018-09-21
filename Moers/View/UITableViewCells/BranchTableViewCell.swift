//
//  BranchTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class BranchTableViewCell: UITableViewCell {

    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(BranchCollectionViewCell.self, forCellWithReuseIdentifier: "branchCell")
        collectionView.backgroundColor = UIColor.white
        
        return collectionView
        
    }()
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let cellWidth: CGFloat = 100
    private let cellHeight: CGFloat = 80
    
    public var branches: [Branch] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var onSelect: ((Branch) -> (Void))?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.collectionView.backgroundColor = theme.backgroundColor
        }
        
        self.addSubview(collectionView)
        
        setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
                           collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}

extension BranchTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return branches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "branchCell", for: indexPath) as! BranchCollectionViewCell
        
        cell.titleLabel.text = branches[indexPath.item].name
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let branchCell = cell as? BranchCollectionViewCell else { return }
        
        branchCell.buttonView.layer.cornerRadius = 52 / 2
        branchCell.buttonView.backgroundColor = AppColor.yellow
        branchCell.buttonView.layer.borderColor = UIColor.black.cgColor
        branchCell.buttonView.layer.borderWidth = 1
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let width = collectionView.frame.width - (itemsPerRow * cellWidth)
        
        return width / (itemsPerRow - 1)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        onSelect?(branches[indexPath.item])
        
    }
    
}
