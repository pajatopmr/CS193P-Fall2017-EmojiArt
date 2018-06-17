//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Paul Michael Reilly on 6/17/18.
//  Copyright © 2018 Paul Michael Reilly. All rights reserved.
//

import UIKit

class EmojiArtView: UIView
{

    var backgroundImage: UIImage? { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }

}
