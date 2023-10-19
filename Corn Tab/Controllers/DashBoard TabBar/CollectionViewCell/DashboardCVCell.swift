//
//  DashboardCVCell.swift
//  Corn Tab
//
//  Created by StarsDev on 14/07/2023.
//

import UIKit

class DashboardCVCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!{
        didSet {
            cellView.layer.borderWidth = 1.0
            cellView.layer.borderColor = #colorLiteral(red: 0.8596192002, green: 0.3426481783, blue: 0.2044148147, alpha: 1)
        }
    }
}
