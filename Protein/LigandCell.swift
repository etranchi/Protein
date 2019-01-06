//
//  LigandCell.swift
//  Protein
//
//  Created by Etienne Tranchier on 06/01/2019.
//  Copyright © 2019 Etienne Tranchier. All rights reserved.
//

import UIKit

class LigandCell: UITableViewCell {

    var ligand : String? {
        didSet {
            setupView()
        }
    }
    
    let name : UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    
    
    func setupView() {
        
        backgroundColor = UIColor.clear
        addSubview(name)
        name.text = ligand!
        NSLayoutConstraint.activate([
            name.centerYAnchor.constraint(equalTo: centerYAnchor),
            name.widthAnchor.constraint(equalTo: widthAnchor),
            name.heightAnchor.constraint(equalToConstant: 50),
            name.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
