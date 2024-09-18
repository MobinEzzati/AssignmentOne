//
//  CollectionViewCell.swift
//  AssignmentOne
//
//  Created by Mobin  Ezzati  on 9/1/24.
//

import Foundation


protocol CollectionViewCellDelegate: AnyObject {
    func didTapFavoriteButton(at index: IndexPath)
    func removeFromFavList(at index: IndexPath)
    
}


class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var CityName: UILabel! // Connected in Interface Builder
    weak var delegate: CollectionViewCellDelegate? // Declare a weak delegate
    var indexPath: IndexPath? // Keep track of the cell's index

    override func awakeFromNib() {
        super.awakeFromNib()
        CityName.text = "Default City Name"
        // Make sure all constraints are properly set in the storyboard or XIB.
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // No need to modify translatesAutoresizingMaskIntoConstraints
    }
    
    @IBAction func makeItFavorite(_ sender: UIButton) {
        if sender.currentImage == UIImage(systemName: "star") {
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            guard let indexPath = indexPath else { return }
            delegate?.didTapFavoriteButton(at: indexPath)
        } else {
            sender.setImage(UIImage(systemName: "star"), for: .normal)
            guard let indexPath = indexPath else { return }
            delegate?.removeFromFavList(at: indexPath)
        }
    }
}

