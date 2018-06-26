//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Paul Michael Reilly on 6/22/18.
//  Copyright © 2018 Paul Michael Reilly. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }

    var resignationHandler: (() -> Void)?

    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
