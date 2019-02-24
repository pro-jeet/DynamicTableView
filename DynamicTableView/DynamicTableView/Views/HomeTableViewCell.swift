//
//  HomeTableViewCell.swift
//  DynamicTableView
//
//  Created by Jitesh Sharma on 21/02/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class HomeTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    let placeHolderImageName: String = "placeholder"
    let notificationIdendifier: String = "reloadCell"
    let notificationUserInfoKeyCell: String = "cell"
    
    // MARK: - Setting Mapping model Data with UI components
    var row: ItemViewModel? {
        
        didSet {
            guard let row = row else {
                return
            }
            if let emailID = row.emailID {
                emailLabel.isHidden = false
                emailLabel.text = emailID
            }
            var nameText = ""
            if let firstName = row.firstName {
                nameLabel.isHidden = false
                nameText.append(firstName)
            }
            if let lastName = row.lastName {
                nameLabel.isHidden = false
                nameText.append(" " + lastName)
            }
            nameLabel.text = nameText
            
            if let imageURL = row.imageURL {
                setImageWithImageURL(imageUrl: imageURL)
            } else {
                cellImageView.image = UIImage(named: (self.placeHolderImageName))
            }
        }
    }
    
    // MARK: - UI Components
    
    //  ImageView for Cell image
    let cellImageView:UIImageView = {
        
        let imgageView = UIImageView()
        // image will never be strecthed vertially or horizontally
        imgageView.contentMode = .scaleToFill
        imgageView.backgroundColor = .clear
        // enable autolayout
        imgageView.translatesAutoresizingMaskIntoConstraints = false
        imgageView.clipsToBounds = true
        return imgageView
    }()
    
    //  Label for Cell title
    let emailLabel: VerticalTopAlignLabel = {
        
        let label = VerticalTopAlignLabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor =  .black
        //  Setting number of lines to zero to support dynamic content.
        label.numberOfLines = 0
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //  Label for Cell Description
    let nameLabel: VerticalTopAlignLabel = {
        
        let label = VerticalTopAlignLabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor =  .gray
        //  Setting number of lines to zero to support dynamic content.
        label.numberOfLines = 0
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //  containerView for Labels
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true // this will make sure its children do not go out of the boundary
        view.backgroundColor = .clear
        return view
    }()
    
    
    // MARK: - Initialising and UI layout Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutConstraints()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutConstraints()
        layoutIfNeeded()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        containerView.addSubview(nameLabel)
        containerView.addSubview(emailLabel)
        contentView.addSubview(containerView)
        contentView.addSubview(cellImageView)
        layoutConstraints()
        
    }
    
    // Method for Adding Constraints for SubViews
    func layoutConstraints() {
        
        //Adding Constraints
        let marginGuide = contentView.layoutMarginsGuide
        
        //configure ContainerView
        
        containerView.leadingAnchor.constraint(equalTo:marginGuide.leadingAnchor, constant:0).isActive = true
        containerView.topAnchor.constraint(equalTo:marginGuide.topAnchor, constant:10).isActive = true
        containerView.bottomAnchor.constraint(equalTo:marginGuide.bottomAnchor, constant:-10).isActive = true
        containerView.trailingAnchor.constraint(equalTo: cellImageView.leadingAnchor).isActive = true
        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 85))
        
        // configure nameLabel
        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        //Configure emailLabel
        emailLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor,constant:5).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        emailLabel.bottomAnchor.constraint(equalTo:self.containerView.bottomAnchor).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        // configure ImageView
        cellImageView.topAnchor.constraint(equalTo:nameLabel.topAnchor, constant:0).isActive = true
        cellImageView.widthAnchor.constraint(equalToConstant:80).isActive = true
        cellImageView.heightAnchor.constraint(equalToConstant:80).isActive = true
        cellImageView.trailingAnchor.constraint(equalTo:marginGuide.trailingAnchor, constant:0).isActive = true
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cellImageView.image = nil
        self.nameLabel.text = nil
        self.emailLabel.text = nil
    }
}

extension HomeTableViewCell {
    
    // Method to load image from url asynchrnously in background and using placeholder till image gets loaded.
    
    func setImageWithImageURL(imageUrl: String){
        
        cellImageView.image = nil
        let url = URL(string: imageUrl)
        cellImageView.sd_setShowActivityIndicatorView(true)
        cellImageView.sd_setIndicatorStyle(.gray)
        
        cellImageView.sd_setImage(with: url, placeholderImage: UIImage(named: placeHolderImageName), options: .refreshCached, progress: nil, completed: {[weak self] (image, error, nil, url) in
            
            DispatchQueue.main.async {
                if let weekSelf = self {
                    if let _ = error {
                        weekSelf.cellImageView.image = UIImage(named: (weekSelf.placeHolderImageName))
                        weekSelf.cellImageView.setNeedsLayout()
                        
                    }
                }
            }
        })
    }
}

// Class for creating labels having vertical top alignment for texts in labels.
class VerticalTopAlignLabel: UILabel {
    
    override func drawText(in rect:CGRect) {
        guard let labelText = text else {  return super.drawText(in: rect) }
        
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedString.Key.font: font])
        var newRect = rect
        newRect.size.height = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil).size.height
        
        if numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(numberOfLines) * font.lineHeight)
        }
        
        super.drawText(in: newRect)
    }
}
